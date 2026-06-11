package com.dopamine120.platform_bridge

import android.app.Activity
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.os.Process
import android.provider.Settings
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.ByteArrayOutputStream
import java.time.Instant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** Android implementation of the platform_bridge channel protocol. */
class PlatformBridgePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var pendingHealthResult: Result? = null
    private var pendingHealthPermissions: Set<String> = emptySet()

    companion object {
        private const val HEALTH_PERMISSION_REQUEST = 41702
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "platform_bridge")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "support" -> result.success(
                mapOf(
                    "canList" to true,
                    "canBlock" to true,
                    "canReadHealth" to HealthReader.isAvailable(context),
                    "platform" to "android",
                )
            )
            "requestBlockingAccess" -> requestBlockingAccess(result)
            "requestHealthAccess" -> requestHealthAccess(call, result)
            "pickApps" -> pickApps(result)
            "setBlocking" -> setBlocking(call, result)
            "isBlocking" -> result.success(
                mapOf(
                    "blocking" to
                        (BlockedAppsStore.isEnabled(context) && isAccessibilityEnabled())
                )
            )
            "readHealth" -> readHealth(call, result)
            else -> result.notImplemented()
        }
    }

    // --- blocking access ---

    private fun hasUsageAccess(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            context.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isAccessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        val service = "${context.packageName}/${AppBlockerService::class.java.name}"
        return enabled.split(':').any { it.equals(service, ignoreCase = true) }
    }

    /** Both grants are user-driven settings toggles, so this deep-links to
     *  whichever screen is still missing and reports denied until both are on. */
    private fun requestBlockingAccess(result: Result) {
        val usage = hasUsageAccess()
        val accessibility = isAccessibilityEnabled()
        if (usage && accessibility) {
            result.success(mapOf("result" to "granted"))
            return
        }
        val action = if (!usage) {
            Settings.ACTION_USAGE_ACCESS_SETTINGS
        } else {
            Settings.ACTION_ACCESSIBILITY_SETTINGS
        }
        try {
            val launcher: Context = activity ?: context
            launcher.startActivity(
                Intent(action).apply {
                    if (launcher !is Activity) addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            )
        } catch (_: Exception) {
            // Settings screen missing on this device; nothing more we can do.
        }
        result.success(mapOf("result" to "denied"))
    }

    // --- app listing ---

    private fun pickApps(result: Result) {
        scope.launch {
            val apps = withContext(Dispatchers.IO) { installedApps() }
            result.success(mapOf("apps" to apps, "categoryCount" to 0))
        }
    }

    private fun installedApps(): List<Map<String, Any?>> {
        val pm = context.packageManager
        val launchIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(launchIntent, 0)
            .map { it.activityInfo.applicationInfo }
            .distinctBy { it.packageName }
            .filter { info ->
                info.packageName != context.packageName &&
                    (info.flags and ApplicationInfo.FLAG_SYSTEM == 0 ||
                        info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0)
            }
            .sortedBy { pm.getApplicationLabel(it).toString().lowercase() }
            .map { info ->
                mapOf(
                    "id" to info.packageName,
                    "name" to pm.getApplicationLabel(info).toString(),
                    "icon" to iconPngBytes(pm, info),
                )
            }
    }

    private fun iconPngBytes(pm: PackageManager, info: ApplicationInfo): ByteArray? {
        return try {
            val drawable = pm.getApplicationIcon(info)
            val size = 96
            val bitmap = if (drawable is BitmapDrawable) {
                Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
            } else {
                Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888).also {
                    val canvas = Canvas(it)
                    drawable.setBounds(0, 0, size, size)
                    drawable.draw(canvas)
                }
            }
            ByteArrayOutputStream().use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                out.toByteArray()
            }
        } catch (_: Exception) {
            null
        }
    }

    // --- blocking ---

    private fun setBlocking(call: MethodCall, result: Result) {
        val selection = call.argument<Map<String, Any?>>("selection")
        val enabled = call.argument<Boolean>("enabled") ?: false
        @Suppress("UNCHECKED_CAST")
        val apps = selection?.get("apps") as? List<Map<String, Any?>> ?: emptyList()
        val packages = apps.mapNotNull { it["id"] as? String }.toSet()
        BlockedAppsStore.setBlocking(context, packages, enabled)
        result.success(null)
    }

    // --- health ---

    private fun requestHealthAccess(call: MethodCall, result: Result) {
        val metrics = call.argument<List<String>>("metrics") ?: emptyList()
        if (!HealthReader.isAvailable(context)) {
            result.success(mapOf("result" to "unsupported"))
            return
        }
        val permissions = HealthReader.permissionsFor(metrics)
        if (permissions.isEmpty()) {
            result.success(mapOf("result" to "unsupported"))
            return
        }
        scope.launch {
            try {
                val client = HealthConnectClient.getOrCreate(context)
                val granted = client.permissionController.getGrantedPermissions()
                if (granted.containsAll(permissions)) {
                    result.success(mapOf("result" to "granted"))
                    return@launch
                }
                val currentActivity = activity
                if (currentActivity == null || pendingHealthResult != null) {
                    result.success(mapOf("result" to "denied"))
                    return@launch
                }
                pendingHealthResult = result
                pendingHealthPermissions = permissions
                if (android.os.Build.VERSION.SDK_INT >= 34) {
                    // Android 14+: Health Connect permissions are plain
                    // runtime permissions.
                    currentActivity.requestPermissions(
                        permissions.toTypedArray(),
                        HEALTH_PERMISSION_REQUEST,
                    )
                } else {
                    // Older Androids route through the Health Connect app.
                    val contract =
                        PermissionController.createRequestPermissionResultContract()
                    currentActivity.startActivityForResult(
                        contract.createIntent(currentActivity, permissions),
                        HEALTH_PERMISSION_REQUEST,
                    )
                }
            } catch (e: Exception) {
                android.util.Log.w("PlatformBridge", "requestHealthAccess failed", e)
                pendingHealthResult = null
                result.success(mapOf("result" to "unsupported"))
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != HEALTH_PERMISSION_REQUEST) return false
        finishHealthRequest()
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != HEALTH_PERMISSION_REQUEST) return false
        finishHealthRequest()
        return true
    }

    /** Re-checks granted permissions after either request flow finishes. */
    private fun finishHealthRequest() {
        val result = pendingHealthResult ?: return
        pendingHealthResult = null
        scope.launch {
            val granted = try {
                HealthConnectClient.getOrCreate(context)
                    .permissionController.getGrantedPermissions()
            } catch (_: Exception) {
                emptySet()
            }
            val verdict =
                if (granted.containsAll(pendingHealthPermissions)) "granted" else "denied"
            result.success(mapOf("result" to verdict))
        }
    }

    private fun readHealth(call: MethodCall, result: Result) {
        val metrics = call.argument<List<String>>("metrics") ?: emptyList()
        val start = call.argument<Number>("start")?.toLong() ?: 0L
        val end = call.argument<Number>("end")?.toLong() ?: System.currentTimeMillis()
        if (!HealthReader.isAvailable(context)) {
            result.success(mapOf("values" to metrics.associateWith { null }))
            return
        }
        scope.launch {
            val values = try {
                HealthReader(context).read(
                    metrics,
                    Instant.ofEpochMilli(start),
                    Instant.ofEpochMilli(end),
                )
            } catch (e: Exception) {
                android.util.Log.w("PlatformBridge", "readHealth failed", e)
                metrics.associateWith { null }
            }
            result.success(mapOf("values" to values))
        }
    }

    // --- ActivityAware ---

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
    }
}

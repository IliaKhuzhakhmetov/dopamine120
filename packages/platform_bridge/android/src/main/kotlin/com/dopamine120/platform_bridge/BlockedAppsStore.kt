package com.dopamine120.platform_bridge

import android.content.Context

/**
 * SharedPreferences-backed blocking state, shared between the plugin
 * (which writes it from Dart) and [AppBlockerService] (which reads it on
 * every foreground change).
 */
object BlockedAppsStore {
    private const val PREFS = "platform_bridge_blocking"
    private const val KEY_PACKAGES = "blocked_packages"
    private const val KEY_ENABLED = "blocking_enabled"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun setBlocking(context: Context, packages: Set<String>, enabled: Boolean) {
        prefs(context).edit()
            .putStringSet(KEY_PACKAGES, packages)
            .putBoolean(KEY_ENABLED, enabled && packages.isNotEmpty())
            .apply()
    }

    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENABLED, false)

    fun blockedPackages(context: Context): Set<String> =
        prefs(context).getStringSet(KEY_PACKAGES, emptySet()) ?: emptySet()
}

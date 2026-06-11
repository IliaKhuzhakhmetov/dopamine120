package com.dopamine120.platform_bridge

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/**
 * Minimal blocking stub: when a blocked package reaches the foreground while
 * blocking is enabled, send the user to the home screen.
 *
 * This is deliberately the simplest enforcement that works. It requires the
 * user to enable the service manually (Settings > Accessibility); a real
 * product would add an in-app overlay explaining the block instead of a
 * silent bounce.
 */
class AppBlockerService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return
        if (!BlockedAppsStore.isEnabled(this)) return
        if (pkg in BlockedAppsStore.blockedPackages(this)) {
            performGlobalAction(GLOBAL_ACTION_HOME)
        }
    }

    override fun onInterrupt() = Unit
}

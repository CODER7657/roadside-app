package com.roadside.mechanic_app

import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Full-screen job offers (M4). Android 14+ makes this a special access the user turns
        // on in Settings; permission_handler doesn't cover it (lib/features/permissions).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "roadside/full_screen_intent")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canUse" -> result.success(canUseFullScreenIntent())
                    "openSettings" -> result.success(openFullScreenIntentSettings())
                    else -> result.notImplemented()
                }
            }
        // M4 only: show over the lock screen and wake the screen while an offer is open, like an
        // incoming call. Switched off again when M4 closes, so the rest of the app (customer
        // details, addresses) always needs the phone unlocked. Not set in the manifest for that reason.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "roadside/lock_screen")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showOverLockScreen" -> {
                        showOverLockScreen(call.arguments as? Boolean ?: false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun showOverLockScreen(show: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            // minSdk 24: the window flags do the same before Android 8.1.
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return true
        return getSystemService(NotificationManager::class.java).canUseFullScreenIntent()
    }

    private fun openFullScreenIntentSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return false
        return try {
            startActivity(
                Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, Uri.parse("package:$packageName")),
            )
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}

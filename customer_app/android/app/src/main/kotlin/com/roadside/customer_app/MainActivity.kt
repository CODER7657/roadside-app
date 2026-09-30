package com.roadside.customer_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingPick: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // U17 emergency contacts: the system picker returns the one contact the user chose, with a
        // temporary read grant for it, so the app needs no READ_CONTACTS permission (PLAN §10).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "roadside/contact_picker")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickPhone" -> pickPhone(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun pickPhone(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "A contact pick is already open", null)
            return
        }
        pendingPick = result
        try {
            startActivityForResult(
                Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI),
                PICK_PHONE,
            )
        } catch (e: ActivityNotFoundException) {
            pendingPick = null
            result.error("unavailable", "No contact picker on this phone", null)
        }
    }

    @Deprecated("FlutterActivity still routes results here")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_PHONE) return
        val result = pendingPick ?: return
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        val columns = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
        )
        try {
            contentResolver.query(uri, columns, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    // Only what the user picked; nothing is logged.
                    result.success(mapOf("name" to cursor.getString(0), "phone" to cursor.getString(1)))
                    return
                }
            }
            result.success(null)
        } catch (e: SecurityException) {
            result.error("denied", "The picked contact couldn't be read", null)
        }
    }

    private companion object {
        const val PICK_PHONE = 4217
    }
}

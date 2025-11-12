package com.example.aj_chat

import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var isUserInCall = false // Flag to track if the user is on VideoCallScreen

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        // Create the MethodChannel for communication with Flutter
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example.app/pip").setMethodCallHandler { call, result ->
            when (call.method) {
                "setUserInCall" -> {
                    // Update the isUserInCall flag
                    isUserInCall = call.argument<Boolean>("isInCall") ?: false
                    result.success(null)
                }
                "enterPipMode" -> {
                    if (isUserInCall && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        enterPictureInPictureModeWithAspectRatio()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enterPictureInPictureModeWithAspectRatio() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val aspectRatio = Rational(16, 9) // Aspect ratio for PiP (16:9 for video calls)
            val pipBuilder = PictureInPictureParams.Builder()
            pipBuilder.setAspectRatio(aspectRatio)
            enterPictureInPictureMode(pipBuilder.build())
        }
    }

//    override fun onUserLeaveHint() {
//        super.onUserLeaveHint()
//        // Trigger PiP when the user minimizes the app only if they are in VideoCallScreen
//        if (isUserInCall && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            enterPictureInPictureModeWithAspectRatio()
//        }
//    }
}

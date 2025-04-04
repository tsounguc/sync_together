package com.example.sync_together

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()

override fun onUserLeaveHint() {
    val params = PictureInPictureParams.Builder().build()
    enterPictureInPictureMode(params)
}


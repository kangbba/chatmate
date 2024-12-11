package com.chatus.chatmate

import android.os.Bundle
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.chatus.chatmate/volume"
    private var isCustomVolume = false // 기본값: 기본 볼륨 동작 수행

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableCustomVolumeControl" -> {
                    isCustomVolume = true
                    result.success(null)
                }
                "disableCustomVolumeControl" -> {
                    isCustomVolume = false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (isCustomVolume) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    sendVolumeEventToFlutter("up")
                    return true // 기본 동작 차단
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    sendVolumeEventToFlutter("down")
                    return true // 기본 동작 차단
                }
            }
        }
        return super.onKeyDown(keyCode, event) // 기본 동작 수행
    }

    private fun sendVolumeEventToFlutter(event: String) {
        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).invokeMethod("volumeButton", event)
        }
    }
}

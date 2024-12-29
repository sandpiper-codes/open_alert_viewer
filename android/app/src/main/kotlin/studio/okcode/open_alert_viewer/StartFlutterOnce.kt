/*
 * SPDX-FileCopyrightText: 2024 Open Alert Viewer authors
 *
 * SPDX-License-Identifier: MIT
 */

package studio.okcode.open_alert_viewer

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint

class StartFlutterOnce (context: Context, serviceOnly: Boolean) {
    private val serviceEngineName: String = "single_service_engine"
    private val withGuiEngineName: String = "single_with_ui_engine"
    private val flutterEngine: FlutterEngine
    init {
        val engineName: String
        val entrypoint: DartEntrypoint
        val group = FlutterEngineGroup(context)
        flutterEngine = group.createAndRunDefaultEngine(context)
        if (serviceOnly) {
            engineName = serviceEngineName
            entrypoint = DartEntrypoint(
                "lib/main.dart", "startBackground")
        } else {
            val serviceEngine = FlutterEngineCache.getInstance().get(serviceEngineName)
            try {
                serviceEngine?.destroy()
            } catch (_: RuntimeException) {}
            engineName = withGuiEngineName
            entrypoint = DartEntrypoint.createDefault()
        }
        if (FlutterEngineCache.getInstance().get(engineName) == null) {
            flutterEngine.dartExecutor.executeDartEntrypoint(entrypoint)
            FlutterEngineCache.getInstance().put(engineName, flutterEngine)
        }
    }
    fun getFlutterEngine() : FlutterEngine {
        return flutterEngine
    }
}

package net.benthal.mypipe

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "newpipe").setMethodCallHandler { call, result ->
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String))
            try {
                startActivity(intent.setPackage("org.schabi.newpipe"))
            } catch (e: ActivityNotFoundException) {
                // NewPipe not installed: let Android pick an app.
                startActivity(Intent.createChooser(intent.setPackage(null), null))
            }
            result.success(null)
        }
    }
}

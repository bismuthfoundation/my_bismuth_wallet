package io.reddwarf.my_idena_wallet;

import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterMain;

public class MainActivityMyIdenaWallet extends FlutterActivity {
  private static final String CHANNEL = "fappchannel";


      @Override
      public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
          GeneratedPluginRegistrant.registerWith(flutterEngine);
          new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                  .setMethodCallHandler(
                      (call, result) -> {
                        if (call.method.equals("getSecret")) {
                            result.success(new LegacyStorage().getSecret());                      
                        } else {
                            result.notImplemented();
                        }
                  }
          );
      }
}

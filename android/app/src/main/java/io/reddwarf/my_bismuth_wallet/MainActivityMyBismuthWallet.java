package io.reddwarf.my_bismuth_wallet;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivityMyBismuthWallet extends FlutterFragmentActivity {
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
                        });
    }
}

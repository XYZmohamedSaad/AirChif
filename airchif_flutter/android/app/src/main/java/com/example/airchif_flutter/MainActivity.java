package com.example.airchif_flutter;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import android.net.wifi.WifiManager;
import android.content.Context;

public class MainActivity extends FlutterActivity {

    private WifiManager.MulticastLock multicastLock;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        WifiManager wifi = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

        if (wifi != null) {
            multicastLock = wifi.createMulticastLock("tello_multicast_lock");
            multicastLock.setReferenceCounted(true);
            multicastLock.acquire();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (multicastLock != null && multicastLock.isHeld()) {
            multicastLock.release();
        }
    }
}

package com.example.airchif_flutter;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "TELLO_NET";
    private static final String CHANNEL = "tello/network";

    private ConnectivityManager cm;
    private ConnectivityManager.NetworkCallback defaultCallback;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "bindWifi":
                            Log.d(TAG, "MethodChannel: bindWifi()");
                            bindToActiveWifiIfPossible();
                            ensureDefaultNetworkCallback();
                            result.success(true);
                            break;

                        case "unbindWifi":
                            Log.d(TAG, "MethodChannel: unbindWifi()");
                            unbindProcessNetwork();
                            unregisterDefaultCallback();
                            result.success(true);
                            break;

                        case "logNetworks":
                            Log.d(TAG, "MethodChannel: logNetworks()");
                            logActiveNetworkState("logNetworks()");
                            result.success(true);
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private void bindToActiveWifiIfPossible() {
        if (cm == null) return;

        Network active = cm.getActiveNetwork();
        Log.d(TAG, "bindToActiveWifiIfPossible: active=" + active);

        if (active == null) {
            Log.w(TAG, "No active network -> cannot bind now");
            return;
        }

        NetworkCapabilities caps = cm.getNetworkCapabilities(active);
        if (caps == null) {
            Log.w(TAG, "Active network caps null -> cannot bind now");
            return;
        }

        boolean isWifi = caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI);
        Log.d(TAG, "Active caps: WIFI=" + isWifi +
                " CELL=" + caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) +
                " INTERNET=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) +
                " VALIDATED=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED));

        if (isWifi) {
            bindProcessToNetwork(active, "bindToActiveWifiIfPossible");
        } else {
            Log.w(TAG, "Active network is NOT WIFI -> not binding");
        }
    }

    private void ensureDefaultNetworkCallback() {
        if (cm == null) return;
        if (defaultCallback != null) {
            Log.d(TAG, "Default callback already registered");
            return;
        }

        defaultCallback = new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(@NonNull Network network) {
                Log.d(TAG, "DEFAULT onAvailable: " + network);
                logNetworkCaps(network, "DEFAULT onAvailable");
                // Wenn ein WIFI Netzwerk verfügbar ist, dran binden
                NetworkCapabilities caps = cm.getNetworkCapabilities(network);
                if (caps != null && caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    bindProcessToNetwork(network, "DEFAULT onAvailable");
                }
            }

            @Override
            public void onCapabilitiesChanged(@NonNull Network network, @NonNull NetworkCapabilities caps) {
                Log.d(TAG, "DEFAULT onCapabilitiesChanged: " + network);
                Log.d(TAG, "CapsChanged: WIFI=" + caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                        + " CELL=" + caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                        + " INTERNET=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                        + " VALIDATED=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED));
                if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    bindProcessToNetwork(network, "DEFAULT onCapabilitiesChanged");
                }
            }

            @Override
            public void onLost(@NonNull Network network) {
                Log.w(TAG, "DEFAULT onLost: " + network);
                logActiveNetworkState("DEFAULT onLost");
            }
        };

        Log.d(TAG, "Registering default network callback...");
        cm.registerDefaultNetworkCallback(defaultCallback);
        logActiveNetworkState("after registerDefaultNetworkCallback");
    }

    private void unregisterDefaultCallback() {
        if (cm == null) return;
        if (defaultCallback == null) return;
        try {
            cm.unregisterNetworkCallback(defaultCallback);
            Log.d(TAG, "Default callback unregistered");
        } catch (Exception e) {
            Log.e(TAG, "unregister default callback failed: " + e);
        }
        defaultCallback = null;
    }

    private void bindProcessToNetwork(Network network, String reason) {
        if (cm == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            boolean ok = cm.bindProcessToNetwork(network);
            Log.d(TAG, "bindProcessToNetwork(" + network + ") reason=" + reason + " => " + ok);
        } else {
            // legacy
            ConnectivityManager.setProcessDefaultNetwork(network);
            Log.d(TAG, "setProcessDefaultNetwork(" + network + ") reason=" + reason + " (legacy)");
        }

        logActiveNetworkState("after bind (" + reason + ")");
    }

    private void unbindProcessNetwork() {
        if (cm == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            boolean ok = cm.bindProcessToNetwork(null);
            Log.d(TAG, "bindProcessToNetwork(null) => " + ok);
        } else {
            ConnectivityManager.setProcessDefaultNetwork(null);
            Log.d(TAG, "setProcessDefaultNetwork(null) (legacy)");
        }

        logActiveNetworkState("after unbind");
    }

    private void logNetworkCaps(Network network, String prefix) {
        if (cm == null) return;
        NetworkCapabilities caps = cm.getNetworkCapabilities(network);
        if (caps == null) {
            Log.d(TAG, prefix + ": caps=null");
            return;
        }
        Log.d(TAG, prefix + ": WIFI=" + caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                + " CELL=" + caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                + " INTERNET=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                + " VALIDATED=" + caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED));
    }

    private void logActiveNetworkState(String where) {
        if (cm == null) return;
        Network active = cm.getActiveNetwork();
        Log.d(TAG, where + " ActiveNetwork=" + active);
        if (active != null) {
            logNetworkCaps(active, where + " ActiveCaps");
        }
    }
}

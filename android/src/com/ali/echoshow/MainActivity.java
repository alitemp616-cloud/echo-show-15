package com.ali.echoshow;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.WindowManager;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

// Full-screen WebView showing the Family OS dashboard. The web app handles its own kiosk behaviour.
public class MainActivity extends Activity {
    static final long RETRY_MS = 30000;

    private WebView web;
    private final Handler handler = new Handler();

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        web = new WebView(this);
        setContentView(web);
        WebSettings settings = web.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        // Family OS speaks and listens without a tap, so media must not wait for a gesture.
        settings.setMediaPlaybackRequiresUserGesture(false);

        web.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                hideSystemUi();
            }

            // Retry the dashboard itself after a failed load (for example, Wi-Fi down at boot).
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                if (Config.DASHBOARD_URL.equals(failingUrl)) {
                    handler.postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            web.loadUrl(Config.DASHBOARD_URL);
                        }
                    }, RETRY_MS);
                }
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(PermissionRequest request) {
                grantMicrophoneOnly(request);
            }
        });

        web.loadUrl(Config.DASHBOARD_URL);
    }

    // Only the microphone (for "Hey <name>" voice mode) is passed through; camera, location and the rest stay denied.
    private void grantMicrophoneOnly(PermissionRequest request) {
        for (String resource : request.getResources()) {
            if (PermissionRequest.RESOURCE_AUDIO_CAPTURE.equals(resource)
                    && getPackageManager().checkPermission("android.permission.RECORD_AUDIO", getPackageName())
                       == PackageManager.PERMISSION_GRANTED) {
                request.grant(new String[] { resource });
                return;
            }
        }
        request.deny();
    }

    private void hideSystemUi() {
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) hideSystemUi();
    }

    // Back goes back within the dashboard; it never leaves the kiosk.
    @Override
    public void onBackPressed() {
        if (web.canGoBack()) web.goBack();
    }

    @Override
    protected void onDestroy() {
        handler.removeCallbacksAndMessages(null);
        super.onDestroy();
    }
}

package com.ali.echoshow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

// Opens the dashboard after the device restarts. Android may refuse this on some builds; the launcher icon always works.
public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            context.startActivity(new Intent(context, MainActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
        }
    }
}

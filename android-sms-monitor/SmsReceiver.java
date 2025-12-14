package com.bdpayx.smsmonitor;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;
import android.util.Log;

public class SmsReceiver extends BroadcastReceiver {
    private static final String TAG = "SmsReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        if (bundle == null) return;

        Object[] pdus = (Object[]) bundle.get("pdus");
        if (pdus == null) return;

        for (Object pdu : pdus) {
            SmsMessage smsMessage = SmsMessage.createFromPdu((byte[]) pdu);
            String sender = smsMessage.getDisplayOriginatingAddress();
            String body = smsMessage.getMessageBody();
            long timestamp = smsMessage.getTimestampMillis();

            Log.d(TAG, "SMS from: " + sender);
            Log.d(TAG, "Body: " + body);

            // Check if it's a payment SMS
            if (isPaymentSMS(sender, body)) {
                Log.d(TAG, "Payment SMS detected!");
                
                // Send to server
                Intent serviceIntent = new Intent(context, ApiService.class);
                serviceIntent.putExtra("sender", sender);
                serviceIntent.putExtra("body", body);
                serviceIntent.putExtra("timestamp", timestamp);
                context.startService(serviceIntent);
            }
        }
    }

    private boolean isPaymentSMS(String sender, String body) {
        // Check if SMS is from bKash, Nagad, or Rocket
        String lowerSender = sender.toLowerCase();
        String lowerBody = body.toLowerCase();

        boolean isFromPaymentService = 
            lowerSender.contains("bkash") || 
            lowerSender.contains("16247") ||
            lowerSender.contains("nagad") || 
            lowerSender.contains("16167") ||
            lowerSender.contains("rocket");

        boolean containsPaymentKeywords = 
            lowerBody.contains("received") || 
            lowerBody.contains("cash in") ||
            lowerBody.contains("tk ") ||
            lowerBody.contains("trxid") ||
            lowerBody.contains("txnid");

        return isFromPaymentService && containsPaymentKeywords;
    }
}

package com.bdpayx.smsmonitor;

import android.app.IntentService;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class ApiService extends IntentService {
    private static final String TAG = "ApiService";

    public ApiService() {
        super("ApiService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        if (intent == null) return;

        String sender = intent.getStringExtra("sender");
        String body = intent.getStringExtra("body");
        long timestamp = intent.getLongExtra("timestamp", System.currentTimeMillis());

        sendToServer(sender, body, timestamp);
    }

    private void sendToServer(String sender, String body, long timestamp) {
        try {
            SharedPreferences prefs = getSharedPreferences("BDPayXMonitor", MODE_PRIVATE);
            String serverUrl = prefs.getString("server_url", "");
            String apiKey = prefs.getString("api_key", "");

            if (serverUrl.isEmpty() || apiKey.isEmpty()) {
                Log.e(TAG, "Server URL or API key not configured");
                return;
            }

            JSONObject json = new JSONObject();
            json.put("sender", sender);
            json.put("body", body);
            json.put("timestamp", timestamp);

            URL url = new URL(serverUrl + "/api/sms-webhook/sms-received");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("X-API-Key", apiKey);
            conn.setDoOutput(true);

            OutputStream os = conn.getOutputStream();
            os.write(json.toString().getBytes(StandardCharsets.UTF_8));
            os.close();

            int responseCode = conn.getResponseCode();
            BufferedReader br = new BufferedReader(
                new InputStreamReader(
                    responseCode == 200 ? conn.getInputStream() : conn.getErrorStream()
                )
            );

            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();

            Log.d(TAG, "Response: " + response.toString());

            prefs.edit().putLong("last_sync", System.currentTimeMillis()).apply();

        } catch (Exception e) {
            Log.e(TAG, "Error sending to server", e);
        }
    }
}

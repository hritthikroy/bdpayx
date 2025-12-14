package com.bdpayx.smsmonitor;

import android.Manifest;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends AppCompatActivity {
    private static final int PERMISSION_REQUEST_CODE = 100;
    
    private EditText serverUrlInput;
    private EditText apiKeyInput;
    private Button saveButton;
    private TextView statusText;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        prefs = getSharedPreferences("BDPayXMonitor", MODE_PRIVATE);

        serverUrlInput = findViewById(R.id.serverUrlInput);
        apiKeyInput = findViewById(R.id.apiKeyInput);
        saveButton = findViewById(R.id.saveButton);
        statusText = findViewById(R.id.statusText);

        // Load saved settings
        serverUrlInput.setText(prefs.getString("server_url", ""));
        apiKeyInput.setText(prefs.getString("api_key", ""));

        saveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveSettings();
            }
        });

        // Request permissions
        requestPermissions();
        
        updateStatus();
    }

    private void requestPermissions() {
        String[] permissions = {
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS
        };

        boolean allGranted = true;
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) 
                != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }

        if (!allGranted) {
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE);
        }
    }

    private void saveSettings() {
        String serverUrl = serverUrlInput.getText().toString().trim();
        String apiKey = apiKeyInput.getText().toString().trim();

        if (serverUrl.isEmpty() || apiKey.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }

        prefs.edit()
            .putString("server_url", serverUrl)
            .putString("api_key", apiKey)
            .apply();

        Toast.makeText(this, "Settings saved!", Toast.LENGTH_SHORT).show();
        updateStatus();
    }

    private void updateStatus() {
        boolean hasPermissions = 
            ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) 
            == PackageManager.PERMISSION_GRANTED;
        
        boolean hasSettings = 
            !prefs.getString("server_url", "").isEmpty() && 
            !prefs.getString("api_key", "").isEmpty();

        long lastSync = prefs.getLong("last_sync", 0);

        StringBuilder status = new StringBuilder();
        status.append("Status:\n\n");
        status.append("Permissions: ").append(hasPermissions ? "✓ Granted" : "✗ Not granted").append("\n");
        status.append("Settings: ").append(hasSettings ? "✓ Configured" : "✗ Not configured").append("\n");
        
        if (lastSync > 0) {
            status.append("Last sync: ").append(new java.util.Date(lastSync).toString()).append("\n");
        }

        status.append("\n");
        status.append(hasPermissions && hasSettings ? "✓ Monitoring active" : "⚠ Setup incomplete");

        statusText.setText(status.toString());
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            updateStatus();
        }
    }
}

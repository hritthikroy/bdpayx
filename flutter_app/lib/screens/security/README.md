# Transaction PIN Security System

A complete transaction PIN security system for Flutter with biometric authentication support.

## Features

- ✅ 4-digit PIN entry with animated circles
- ✅ Shake animation on error
- ✅ Haptic feedback
- ✅ Biometric authentication (fingerprint/face ID)
- ✅ Failed attempt tracking with lockout
- ✅ PIN setup and change flows
- ✅ Phone number masking
- ✅ "Not you?" user switching
- ✅ "Forgot PIN?" recovery option

## Usage

### 1. Add SecurityProvider to your app

```dart
import 'package:provider/provider.dart';
import 'providers/security_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

### 2. Show Transaction PIN Screen

```dart
import 'screens/security/transaction_pin_screen.dart';

// Before a transaction
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TransactionPinScreen(
      userName: 'Pranta',
      phoneNumber: '+916268',
      canUseBiometric: true,
      onSuccess: () {
        // Proceed with transaction
        Navigator.pop(context);
        _processTransaction();
      },
    ),
  ),
);

if (result == true) {
  // PIN verified, proceed
}
```

### 3. Setup PIN (First Time)

```dart
import 'screens/security/setup_pin_screen.dart';

final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SetupPinScreen(),
  ),
);

if (result == true) {
  // PIN setup successful
}
```

### 4. Security Settings

```dart
import 'screens/security/security_settings_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SecuritySettingsScreen(),
  ),
);
```

## Integration Examples

### Example 1: Protect Exchange Transaction

```dart
// In exchange_screen.dart
Future<void> _confirmExchange() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TransactionPinScreen(
        onSuccess: () {
          Navigator.pop(context);
          _processExchange();
        },
      ),
    ),
  );
}
```

### Example 2: Protect Wallet Withdrawal

```dart
// In wallet_screen.dart
Future<void> _withdrawFunds() async {
  final securityProvider = context.read<SecurityProvider>();
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TransactionPinScreen(
        canUseBiometric: securityProvider.isBiometricEnabled,
      ),
    ),
  );
  
  if (result == true) {
    // Process withdrawal
  }
}
```

### Example 3: Add to Profile Settings

```dart
// In profile_screen.dart
ListTile(
  leading: Icon(Icons.security),
  title: Text('Security'),
  subtitle: Text('PIN & Biometric settings'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecuritySettingsScreen(),
      ),
    );
  },
)
```

## Security Features

### Failed Attempts & Lockout
- Tracks failed PIN attempts
- Locks out after 5 failed attempts for 5 minutes
- Automatically resets on successful authentication

### Biometric Authentication
- Supports fingerprint and face ID
- Can be enabled/disabled in settings
- Falls back to PIN if biometric fails

### PIN Storage
- Stored securely in SharedPreferences
- Never transmitted to server
- Can be reset through forgot PIN flow

## Customization

### Change Colors

```dart
// Update the purple color throughout the files
const Color(0xFF9C27B0) // Replace with your brand color
```

### Change PIN Length

```dart
// In transaction_pin_screen.dart
final List<String> _pin = ['', '', '', '', '', '']; // 6 digits
// Update all references from 4 to 6
```

### Add Server Verification

```dart
// In security_provider.dart
Future<bool> verifyTransactionPin(String pin) async {
  // Add API call to verify PIN with backend
  final response = await http.post(
    Uri.parse('$baseUrl/verify-pin'),
    body: {'pin': pin},
  );
  return response.statusCode == 200;
}
```

## Optional: Add Biometric Package

For production biometric authentication, add to `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^2.1.7
```

Then update `security_provider.dart`:

```dart
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometric() async {
  final auth = LocalAuthentication();
  
  try {
    return await auth.authenticate(
      localizedReason: 'Authenticate to proceed with transaction',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

## Testing

1. Run the app
2. Navigate to Security Settings
3. Set up a PIN (e.g., 1234)
4. Test PIN verification on transactions
5. Test biometric authentication
6. Test failed attempts and lockout
7. Test PIN change flow

## Files Created

- `lib/screens/security/transaction_pin_screen.dart` - Main PIN entry screen
- `lib/screens/security/setup_pin_screen.dart` - First-time PIN setup
- `lib/screens/security/change_pin_screen.dart` - Change existing PIN
- `lib/screens/security/security_settings_screen.dart` - Security settings UI
- `lib/providers/security_provider.dart` - Security state management

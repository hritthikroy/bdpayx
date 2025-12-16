# Integration Examples

## Example 1: Add PIN to Exchange Screen

Update `flutter_app/lib/screens/exchange/exchange_screen.dart`:

```dart
import '../security/transaction_pin_screen.dart';

// In your exchange confirmation method
Future<void> _confirmExchange() async {
  // Show PIN screen before processing exchange
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TransactionPinScreen(
        canUseBiometric: true,
        onSuccess: () {
          Navigator.pop(context);
          _processExchange();
        },
      ),
    ),
  );
}

Future<void> _processExchange() async {
  // Your existing exchange logic here
  final exchangeProvider = context.read<ExchangeProvider>();
  
  try {
    await exchangeProvider.createExchange(
      fromAmount: _fromAmount,
      toAmount: _toAmount,
    );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exchange completed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exchange failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## Example 2: Add Security Settings to Profile

Update `flutter_app/lib/screens/profile/profile_screen.dart`:

```dart
import '../security/security_settings_screen.dart';

// Add this to your profile menu
ListTile(
  leading: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.security, color: Colors.purple),
  ),
  title: const Text('Security'),
  subtitle: const Text('PIN & Biometric settings'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsScreen(),
      ),
    );
  },
),
```

## Example 3: Protect Wallet Withdrawals

```dart
import '../security/transaction_pin_screen.dart';

Future<void> _withdrawFunds(double amount) async {
  // First verify PIN
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const TransactionPinScreen(),
    ),
  );
  
  if (result == true) {
    // PIN verified, process withdrawal
    try {
      await _processWithdrawal(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal successful'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

## Example 4: First-Time Setup Flow

```dart
import '../security/setup_pin_screen.dart';

// Show setup PIN screen for new users
Future<void> _checkPinSetup() async {
  final prefs = await SharedPreferences.getInstance();
  final hasPin = prefs.getString('transaction_pin') != null;
  
  if (!hasPin) {
    // Show setup dialog
    final shouldSetup = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Transaction PIN'),
        content: const Text(
          'For your security, please set up a 4-digit PIN to protect your transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setup Now'),
          ),
        ],
      ),
    );
    
    if (shouldSetup == true) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetupPinScreen(),
        ),
      );
      
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN setup successful'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
```

## Example 5: Add to Main Navigation

Update `flutter_app/lib/screens/main_navigation.dart`:

```dart
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import 'security/setup_pin_screen.dart';

class MainNavigation extends StatefulWidget {
  // ... existing code
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    // Check PIN setup on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPinSetup();
    });
  }
  
  Future<void> _checkPinSetup() async {
    final securityProvider = context.read<SecurityProvider>();
    // Add your logic to check if PIN is set
  }
  
  // ... rest of your code
}
```

## Quick Test

1. Run your app
2. Navigate to Profile → Security Settings
3. Tap "Transaction PIN" to set up a new PIN
4. Enter 1234 twice to confirm
5. Go to Exchange screen
6. Try to make an exchange - PIN screen should appear
7. Enter 1234 to proceed
8. Test biometric option if available

## Customization Tips

### Change the purple color to match your brand:
```dart
// Replace all instances of Color(0xFF9C27B0) with your color
const Color(0xFF6366F1) // Your brand color
```

### Add backend verification:
```dart
// In security_provider.dart
Future<bool> verifyTransactionPin(String pin) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/verify-pin'),
    headers: {'Authorization': 'Bearer $token'},
    body: {'pin': pin},
  );
  return response.statusCode == 200;
}
```

### Customize lockout duration:
```dart
// In security_provider.dart, change from 5 minutes to 10 minutes:
_lockoutTime = DateTime.now().add(const Duration(minutes: 10));
```

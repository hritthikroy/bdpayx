# Currency Exchange Flutter App

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Update API endpoint in `lib/config/api_config.dart` if needed

3. Run the app:
```bash
flutter run
```

## Features

- User authentication (login/register)
- Real-time exchange rate display with auto-refresh
- Tiered pricing based on transaction amount
- Manual payment gateway with proof upload
- Transaction history with status tracking
- Live customer support chat
- Push notifications

## Screens

- Splash Screen
- Login/Register
- Home (Exchange, Transactions, Support)
- Exchange Screen with calculator
- Payment Screen with proof upload
- Transaction History
- Live Chat Support

## Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

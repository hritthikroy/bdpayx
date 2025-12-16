import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/exchange_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/security_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'config/supabase_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app IMMEDIATELY - all other init happens in background
  runApp(const MyApp());
  
  // Background initialization (non-blocking)
  _initializeInBackground();
}

// All heavy initialization happens after app is visible
Future<void> _initializeInBackground() async {
  // Set orientations (non-blocking)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFF8FAFC),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // Initialize Supabase in background
  SupabaseConfig.initialize().catchError((e) {
    debugPrint('Supabase init error: $e');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExchangeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: MaterialApp(
        title: 'Currency Exchange',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        themeMode: ThemeMode.light,
        home: const MainNavigation(), // Direct to main - no splash screen
        // Smooth page transitions
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/login':
              page = const LoginScreen();
              break;
            case '/main':
              page = const MainNavigation();
              break;
            case '/splash':
              page = const SplashScreen();
              break;
            default:
              page = const MainNavigation();
          }
          return _createSmoothRoute(page, settings);
        },
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainNavigation(),
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF8B5CF6),
        tertiary: Color(0xFFA855F7),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        color: Colors.white,
      ),
      // Smooth page transitions globally
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Create smooth route transitions
  static Route<dynamic> _createSmoothRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth fade + slide transition
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

// App initializer to decide which screen to show
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize after first frame to avoid flickering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Get providers
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    
    // Initialize exchange provider in background
    exchangeProvider.initialize();
    
    // Load token in background
    authProvider.loadToken();
    
    // Navigate IMMEDIATELY for super fast loading
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show minimal loading while initializing
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

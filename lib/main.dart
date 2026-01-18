import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_manager_app/firebase_option.dart';
import 'package:task_manager_app/pages/root_page.dart';

// import 'pages/root_page.dart';
import 'pages/registration_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/todo_page.dart';

import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧊 Transparent status bar for glass UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // 🔔 Init notifications
  await NotificationService.init();

  // 🔥 Init Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  runApp(const MyApp());
}

// ================= APP ROOT =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Palette: black / white / pale-red (accent)
    final Color accent = const Color(0xFFFF6B6B); // pale red
    final Color background = const Color(0xFF0B0B0D); // near-black
    final Color surface = const Color(0xFF121212);

    final ColorScheme darkScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          background: background,
          surface: surface,
          onBackground: Colors.white,
          onSurface: Colors.white,
          onPrimary: Colors.white,
        );

    return MaterialApp(
      title: 'TODO App',
      debugShowCheckedModeBanner: false,

      // 🎨 App theme (force dark look using palette)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: background,
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: background,
      ),

      // Force dark mode so app uses the chosen palette everywhere
      themeMode: ThemeMode.dark,

      // ✅ ROOT PAGE (IMPORTANT)
      home: const RootPage(),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoginMode = true;

  void _toggleAuthMode() {
    setState(() => _isLoginMode = !_isLoginMode);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomePage(userId: snapshot.data!.uid);
        }

        return _isLoginMode
            ? LoginPage(onRegisterPressed: _toggleAuthMode)
            : RegistrationPage(onLoginPressed: _toggleAuthMode);
      },
    );
  }
}

// ================= HOME PAGE =================
class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    DashboardPage(userId: widget.userId, onLogout: _handleLogout),
    TodoPage(userId: widget.userId),
  ];

  // ✅ CORRECT LOGOUT (NO NAVIGATION)
  void _handleLogout() async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'TODOs'),
        ],
      ),
    );
  }
}

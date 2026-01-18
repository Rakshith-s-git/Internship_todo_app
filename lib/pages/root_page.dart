import 'package:flutter/material.dart';
import 'app_splash_page.dart';
import '../main.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash
        ? const AppSplashPage()
        : const AuthWrapper(); // 🔥 ALWAYS LISTENING
  }
}

import 'package:flutter/material.dart';
import '../widgets/animated_logo.dart';

class AppSplashPage extends StatelessWidget {
  const AppSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      body: const Center(child: AnimatedGlassLogo(size: 130)),
    );
  }
}

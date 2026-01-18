import 'package:flutter/material.dart';
import 'glass_logo.dart'; // ✅ THIS IMPORT WAS MISSING

class AnimatedGlassLogo extends StatefulWidget {
  final double size;

  const AnimatedGlassLogo({super.key, this.size = 120});

  @override
  State<AnimatedGlassLogo> createState() => _AnimatedGlassLogoState();
}

class _AnimatedGlassLogoState extends State<AnimatedGlassLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: GlassLogo(size: widget.size), // ✅ NOW FOUND
      ),
    );
  }
}

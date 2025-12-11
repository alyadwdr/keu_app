import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Setelah 3 detik pindah ke /main melalui GoRouter
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/main');  // ganti Navigator lama ke GoRouter
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Image.asset(
            'assets/images/logo_keu.png',
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

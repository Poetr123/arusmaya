import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashContent();
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Gagal memeriksa sesi pengguna.')),
          );
        }

        if (snapshot.data != null) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF142B4A), Color(0xFF2563EB), Color(0xFF38BDF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 85,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'ArusMaya',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kelola keuangan, kendalikan masa depan.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

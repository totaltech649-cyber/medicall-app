import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'patient_home_screen.dart';
import 'doctor_home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app.AuthProvider>(
      builder: (context, auth, _) {
        // Routing automatique selon l'état Firebase Auth
        switch (auth.status) {
          case app.AuthStatus.loading:
            return _buildSplash();

          case app.AuthStatus.authenticated:
            final user = auth.user!;
            if (user.role == UserRole.doctor) {
              return const DoctorHomeScreen();
            } else {
              return PatientHomeScreen(userName: user.name);
            }

          case app.AuthStatus.unauthenticated:
          case app.AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: 'Médi'),
                  TextSpan(
                    text: 'Call',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapplication/loginPage/app_loading_page.dart';
import 'package:flutterapplication/loginPage/auth_service.dart';
import 'package:flutterapplication/secondPage/mainPage.dart';
import 'package:flutterapplication/loginPage/verify_email.dart';
import 'package:flutterapplication/loginPage/login_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null && !user.emailVerified) {
            return const VerifyEmailPage();
          }

          return const MainPage(); // verified
        }

        return const LoginPage();
      },
    );
  }
}

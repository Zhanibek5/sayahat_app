import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapplication/loginPage/auth_service.dart';
import 'app_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  String errorMessage = '';
  bool _obscurePassword = true;

  void deleteAccount() async {
    try {
      await authService.value.deleteAccount(
          email: controllerEmail.text, password: controllerPassword.text);
      AppData.navBarCurrentIndexNotifier.value = 0;
      AppData.onboardingCurrentIndexNotifier = 0;
      popPage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          errorMessage = 'email_badly_formatted'.tr();
        } else {
          errorMessage = 'email_or_password_incorrect'.tr();
        }
      });
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'delete_account'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Image(
                  image: AssetImage('assets/sayahat.png'),
                  width: 300,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'delete_account_warning'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL FIELD
              TextFormField(
                controller: controllerEmail,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_email'.tr();
                  }
                  if (!value.contains("@")) {
                    return 'email_not_valid'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // PASSWORD FIELD
              TextFormField(
                controller: controllerPassword,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword; // көрінетін/жасырын режимді ауыстыру
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_password'.tr();
                  }
                  if (value.length < 6) {
                    return 'password_min_6'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ERROR MESSAGE
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),

              const SizedBox(height: 30),

              // DELETE ACCOUNT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      deleteAccount();
                    }
                  },
                  child: Text(
                    'delete_account'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 85),
              Center(
                child: Text(
                  "Sayahat App",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

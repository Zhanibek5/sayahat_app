import 'package:flutter/material.dart';
import 'package:flutterapplication/loginPage/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerCurrentPassword = TextEditingController();
  TextEditingController controllerNewPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true; // парольді бастапқыда жасыру

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerCurrentPassword.dispose();
    controllerNewPassword.dispose();
    super.dispose();
  }

  void updatePassword() async {
    try {
      await authService.value.resetPasswordFromCurrentPasword(
        currentPassword: controllerCurrentPassword.text,
        newPassword: controllerNewPassword.text,
        email: controllerEmail.text,
      );
      showSnackBarSuccess();
    } catch (e) {
      showSnackBarFailure();
    }
  }

  void showSnackBarSuccess() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      content: Text(
        'password_updated_success'.tr(),
        style: AppTextStyles.m,
      ),
      showCloseIcon: true,
    ));
  }

  void showSnackBarFailure() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      content: Text(
        'password_update_failed'.tr(),
        style: AppTextStyles.m,
      ),
      showCloseIcon: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'change_password'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
                'email_and_current_password_info'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL
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

              // CURRENT PASSWORD
              TextFormField(
                controller: controllerCurrentPassword,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'current_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_current_password'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // NEW PASSWORD
              TextFormField(
                controller: controllerNewPassword,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'new_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_new_password'.tr();
                  }
                  if (value.length < 6) {
                    return 'password_min_6'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // CHANGE PASSWORD BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      updatePassword();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'update_password'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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

class AppTextStyles {
  static const m = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );
}

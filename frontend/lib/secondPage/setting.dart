import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_page.dart';
import 'package:flutterapplication/loginPage/reset_password_page.dart';
import 'package:flutterapplication/loginPage/delete_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_provider.dart';
import 'package:provider/provider.dart';
import 'info.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = "Қазақша";
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'account'.tr(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.teal),
                  title: Text('edit_profile'.tr()),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilePage()),
                    );
                    setState(() {}); // refresh profile after edit
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.teal),
                  title: Text('change_password'.tr()),
                  onTap: () {
                    Navigator.pushNamed(
                        context, 'loginPage/change_password_page.dart');
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.teal),
                  title: Text('reset_password'.tr()),
                  onTap: () {
                    Navigator.pushNamed(
                        context, 'loginPage/reset_password_page.dart');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------- APP SETTINGS ----------
          Text(
            'app_settings'.tr(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined,
                      color: Colors.teal),
                  title: Text('notifications'.tr()),
                  value: context.watch<SettingsProvider>().notificationsEnabled,
                  onChanged: (value) {
                    context.read<SettingsProvider>().setNotifications(value);
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.teal),
                  title: Text('language'.tr()),
                  subtitle: Text(_getCurrentLanguageLabel(context)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showLanguageDialog,
                ),
                const Divider(height: 0),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------- ABOUT ----------
          Text(
            'about'.tr(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.teal),
                  title: Text('about_sayahat_app'.tr()),
                  subtitle: Text('about_app_description'.tr()),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                    setState(() {}); // refresh profile after edit
                  },
                ),
                const Divider(height: 0),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---------- LOGOUT ----------
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                'delete_account'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Sayahat App",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Language selection dialog
  void _showLanguageDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr()),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(Locale('en')),
              _languageOption(Locale('kk')),
              _languageOption(Locale('ru')),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(Locale locale) {
    String label;
    if (locale.languageCode == 'en')
      label = 'english'.tr();
    else if (locale.languageCode == 'kk')
      label = 'kazakh'.tr();
    else
      label = 'russian'.tr();

    return ListTile(
      title: Text(label),
      onTap: () async {
        await context.setLocale(locale);
        // Persist selection
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_language', locale.languageCode);
        Navigator.of(context).pop();
        setState(() {
          _selectedLanguage = label; // осы виджеттің локализацияланған атауы
        });
      },
    );
  }

  String _getCurrentLanguageLabel(BuildContext context) {
    final code = context.locale.languageCode;
    if (code == 'en') return 'english'.tr();
    if (code == 'kk') return 'kazakh'.tr();
    return 'russian'.tr();
  }
}

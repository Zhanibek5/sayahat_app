import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about_me_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_page.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? aboutMeText;
  String _selectedLanguage = "Қазақша"; // ← МІНЕ ОСЫ ЖЕРДЕ АНЫҚТАУ ҚАЖЕТ
  final String serverIp = "http://192.168.1.3:8000"; // сервер IP
  bool networkImageFailed = false;

  @override
  void initState() {
    super.initState();
    loadAboutMe();
  }

  Future<void> loadAboutMe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final url = Uri.parse("$serverIp/about_me/${user.uid}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          aboutMeText = data["aboutMe"] ?? "";
        });
      } else {
        setState(() {
          aboutMeText = "";
        });
      }
    } catch (e) {
      setState(() {
        aboutMeText = "";
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'loginPage/login_page.dart');
  }

  void editAboutMe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AboutMePage(
          initialText: aboutMeText ?? "",
          userId: user.uid,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        aboutMeText = result;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String imageUrl =
        "http://192.168.1.3:8000/profile_image/${user!.uid}?v=${DateTime.now().millisecondsSinceEpoch}";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 230,
            color: Colors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: !networkImageFailed && user?.photoURL != null
                      ? NetworkImage(imageUrl)
                      : const AssetImage("assets/avatar.png") as ImageProvider,
                  onBackgroundImageError: (_, __) {
                    setState(() {
                      networkImageFailed = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'username'.tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? 'no_email'.tr(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // About Me Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 50,
                          maxHeight: 170,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'about_me'.tr(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                aboutMeText?.isNotEmpty == true
                                    ? aboutMeText!
                                    : 'no_info'.tr(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Account Settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit, color: Colors.teal),
                            title: Text('edit_profile'.tr()),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfilePage()),
                              ).then((_) =>
                                  setState(() {})); // ← ProfilePage rebuild
                            },
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.lock_outline,
                                color: Colors.teal),
                            title: Text('change_password'.tr()),
                            onTap: () {
                              Navigator.pushNamed(context,
                                  'loginPage/change_password_page.dart');
                            },
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.info_outline,
                                color: Colors.teal),
                            title: Text('edit_about_me'.tr()),
                            onTap: editAboutMe,
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading:
                                const Icon(Icons.language, color: Colors.teal),
                            title: Text('language'.tr()),
                            subtitle: Text(_getCurrentLanguageLabel(context)),
                            onTap: _showLanguageDialog,
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.logout,
                                color: Colors.redAccent),
                            title: Text('logout'.tr()),
                            onTap: logout,
                          ),
                        ],
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
        ],
      ),
    );
  }
}

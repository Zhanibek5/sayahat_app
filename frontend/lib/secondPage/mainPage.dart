import 'package:flutter/material.dart';
import 'package:flutterapplication/secondPage/profile.dart';
import 'package:flutterapplication/secondPage/setting.dart';
import 'package:flutterapplication/secondPage/map.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Locale өзгергенде қайта build жасау
    EasyLocalization.of(context)!.locale;
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapPage(),
          SettingsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'map'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'settings'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}

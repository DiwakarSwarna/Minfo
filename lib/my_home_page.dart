import 'package:flutter/material.dart';
import 'package:mango_app/hero_page.dart';
import 'package:mango_app/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  final bgcolor = Colors.green.shade900;
  final GlobalKey<ProfileState> profileKey = GlobalKey<ProfileState>();

  late final List<Widget> pages = [const HeroPage(), Profile(key: profileKey)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[50],
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });

          // ✅ Refresh data when navigating to Profile
          if (index == 1) {
            profileKey.currentState?.loadUserData();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: bgcolor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: bgcolor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

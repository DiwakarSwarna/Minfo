import 'package:flutter/material.dart';
import 'package:mango_app/about_page.dart';
import 'package:mango_app/auth/login.dart';
import 'package:mango_app/mandi.dart';
import 'package:mango_app/mandi_settings.dart';
// import 'package:mango_app/splash_screen.dart';
import 'package:mango_app/my_home_page.dart';
import 'package:mango_app/splash_screen.dart';
// import 'package:mango_app/search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green[700]!,
          primary: const Color(0xFF003B73),
          secondary: const Color(0xFFFFF8F2),
          tertiary: const Color.fromARGB(255, 119, 119, 119),
        ),
        // textTheme: const TextTheme(
        //   bodyLarge: TextStyle(color: Color(0xFFBDBDBD)),
        //   bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
        //   bodySmall: TextStyle(color: Color(0xFFBDBDBD)),
        //   titleLarge: TextStyle(color: Color(0xFFFF9500)),
        //   titleMedium: TextStyle(color: Color(0xFFBDBDBD)),
        // ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      // home: MyHomePage(title: "Welcome to Mango app"),
      home: SplashScreen(),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => MyHomePage(),
        '/mandiHome': (context) => Mandi(),
        '/mandiSettings': (context) => MandiSettings(),
        '/about': (context) => AboutPage(),
      },
    );
  }
}

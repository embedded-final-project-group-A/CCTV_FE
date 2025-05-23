import 'package:flutter/material.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'wrappers/bottom_nav_wrapper.dart';
import 'screens/camera_registration.dart';
import 'screens/aboutus.dart';
import 'screens/support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up Flow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF477DD0)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/signin',
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => const BottomNavWrapper(),
        '/notifications': (context) => const BottomNavWrapper(currentIndex: 1),
        '/events': (context) => const BottomNavWrapper(currentIndex: 2),
        '/profile': (context) => const BottomNavWrapper(currentIndex: 3),
        '/camera_registration': (context) => const CameraRegistrationPage(),
        '/about': (context) => const AboutPage(),
        '/support': (context) => const SupportPage(),
      },
    );
  }
}

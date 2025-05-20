import 'package:flutter/material.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/home.dart';
import 'screens/events.dart';
import 'screens/profile.dart';
import 'screens/notifications.dart';

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
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/events': (context) => const EventsPage(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

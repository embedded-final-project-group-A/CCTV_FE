import 'package:flutter/material.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/home.dart';
import 'screens/events.dart';  // events.dart 임포트

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
        '/events': (context) => const EventsPage(),  // /events 라우트 등록
      },
    );
  }
}

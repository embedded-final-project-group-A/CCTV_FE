import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // 배경 흰색
      appBar: AppBar(
        centerTitle: true,             // 제목 가운데 정렬
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        title: const Text(
          'About Us',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About This App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This app is designed to help you easily manage your stores and cameras with intuitive controls and real-time updates.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'Thank you for choosing our app! We are committed to providing you with the best experience and continuous improvements.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

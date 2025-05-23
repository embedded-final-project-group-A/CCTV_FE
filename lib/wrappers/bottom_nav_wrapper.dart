import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/events.dart';
import '../screens/profile.dart';
import '../screens/notifications.dart';

class BottomNavWrapper extends StatefulWidget {
  final int currentIndex;
  const BottomNavWrapper({super.key, this.currentIndex = 0});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomePage(),           // index 0
    const NotificationsPage(),  // index 1
    const EventsPage(),         // index 2
    const ProfilePage(),        // index 3
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
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
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey,   // 회색 선 색상
              width: 0.5,           // 선 두께
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),         
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
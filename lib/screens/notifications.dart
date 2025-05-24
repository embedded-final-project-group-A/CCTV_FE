import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  final String apiUrl = 'http://localhost:8000/alerts/';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    // 10초마다 새 알림 갱신
    Future.delayed(const Duration(seconds: 10), _periodicFetch);
  }

  void _periodicFetch() async {
    await fetchNotifications();
    Future.delayed(const Duration(seconds: 10), _periodicFetch);
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications = data.map((json) => NotificationItem.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  // 날짜별로 알림 그룹핑
  Map<String, List<NotificationItem>> groupNotificationsByDate() {
    Map<String, List<NotificationItem>> grouped = {};
    for (var notification in notifications) {
      final date = notification.timestamp.split('T')[0]; // YYYY-MM-DD
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(notification);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = groupNotificationsByDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22,
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: groupedNotifications.entries.map((entry) {
                    return _NotificationSection(
                      date: entry.key,
                      notifications: entry.value,
                    );
                  }).toList(),
                ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  final String date;
  final List<NotificationItem> notifications;

  const _NotificationSection({
    required this.date,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            TextButton(
              onPressed: () {
                // TODO: 전체 알림 삭제 기능 구현
              },
              child: const Text('Clear all', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...notifications.map((item) => _NotificationCard(item: item)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        tileColor: Colors.white,
        leading: CircleAvatar(
          backgroundColor: Colors.pink[100],
          child: const Icon(Icons.videocam, color: Colors.black),
        ),
        title: Text('${item.store} - ${item.camera}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.event),
      ),
    );
  }
}

class NotificationItem {
  final String store;
  final String camera;
  final String event;
  final String timestamp;

  NotificationItem({
    required this.store,
    required this.camera,
    required this.event,
    required this.timestamp,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      store: json['store'],
      camera: json['camera'],
      event: json['event'],
      timestamp: json['timestamp'],
    );
  }
}

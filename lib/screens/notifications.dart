import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  final String storageKey = 'cached_notifications';

  @override
  void initState() {
    super.initState();
    loadCachedNotifications();
    fetchNotifications(); // 서버에서 최신 알림 불러오기
    Future.delayed(const Duration(seconds: 10), _periodicFetch);
  }

  void _periodicFetch() async {
    await fetchNotifications();
    Future.delayed(const Duration(seconds: 10), _periodicFetch);
  }

  Future<void> loadCachedNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(storageKey);

    if (cachedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        setState(() {
          notifications =
              jsonList.map((json) => NotificationItem.fromJson(json)).toList();
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Failed to decode cached notifications: $e');
      }
    }
  }

  Future<void> cacheNotifications(List<NotificationItem> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, jsonString);
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedItems = data.map((json) => NotificationItem.fromJson(json)).toList();
        setState(() {
          notifications = fetchedItems;
          isLoading = false;
        });
        cacheNotifications(fetchedItems);
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

  Map<String, List<NotificationItem>> groupNotificationsByDate() {
    Map<String, List<NotificationItem>> grouped = {};
    for (var notification in notifications) {
      final date = notification.timestamp.split('T')[0];
      grouped.putIfAbsent(date, () => []);
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
                // TODO: Clear all notifications of this date
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
        title: Text('Store: ${item.storeId} - Camera: ${item.cameraId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.message),
      ),
    );
  }
}


class NotificationItem {
  final String storeId;
  final int cameraId;
  final String message;
  final String timestamp;

  NotificationItem({
    required this.storeId,
    required this.cameraId,
    required this.message,
    required this.timestamp,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      storeId: json['store_id'],
      cameraId: json['camera_id'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'camera_id': cameraId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

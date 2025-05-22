import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationSection(
            date: 'Today',
            notifications: [
              NotificationItem(store: 'Store 1', camera: 'Camera 1', event: '폭행'),
            ],
          ),
          SizedBox(height: 24),
          _NotificationSection(
            date: 'Yesterday',
            notifications: [
              NotificationItem(store: 'Store 3', camera: 'Camera 2', event: '건강이상'),
            ],
          ),
        ],
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
              onPressed: () {},
              child: const Text('Clear all', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...notifications.map((item) => _NotificationCard(item: item)),
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

  const NotificationItem({
    required this.store,
    required this.camera,
    required this.event,
  });
}

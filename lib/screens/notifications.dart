import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import '../constants/api_constants.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  final String apiUrl = '${ApiConstants.baseUrl}/api/user/alerts/';
  final String storageKey = 'cached_notifications';

  @override
  void initState() {
    super.initState();
    loadCachedNotifications();
    fetchNotifications();
    // 10초마다 주기적 갱신
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found. Please login.')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse('$apiUrl?user_id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final fetchedItems =
            data.map((json) => NotificationItem.fromJson(json)).toList();
        setState(() {
          notifications = fetchedItems;
          isLoading = false;
        });
        cacheNotifications(fetchedItems);
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load notifications: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load notifications')),
        );
      }
    }
  }

  Map<String, List<NotificationItem>> groupNotificationsByDate() {
    Map<String, List<NotificationItem>> grouped = {};
    for (var notification in notifications) {
      final date = notification.eventTime.split('T')[0];
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
      body: Column(
        children: [
          Expanded(
            child: isLoading
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
              onPressed: () {
                // TODO: 날짜별 알림 모두 삭제 기능 구현 필요
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

  String getTypeDescription(int typeId) {
    switch (typeId) {
      case 1:
        return 'Theft';
      case 2:
        return 'Fall';
      case 3:
        return 'Fight';
      case 4:
        return 'Smoke';
      default:
        return 'Motion Detected';
    }
  }

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
        subtitle: Text(getTypeDescription(item.typeId)),
        onTap: () {
          if (item.videoUrl != null && item.videoUrl!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerPage(videoUrl: item.videoUrl!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No video available for this notification')),
            );
          }
        },
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({required this.videoUrl, Key? key}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      backgroundColor: Colors.black,
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child:
                  Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}

class NotificationItem {
  final int storeId;
  final int cameraId;
  final int typeId;
  final String eventTime;
  final String? videoUrl;

  NotificationItem({
    required this.storeId,
    required this.cameraId,
    required this.typeId,
    required this.eventTime,
    this.videoUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      storeId: json['store_id'],
      cameraId: json['camera_id'],
      typeId: json['type_id'],
      eventTime: json['event_time'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'camera_id': cameraId,
      'type_id': typeId,
      'event_time': eventTime,
      'video_url': videoUrl,
    };
  }
}

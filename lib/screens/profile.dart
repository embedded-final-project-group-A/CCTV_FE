import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> userStores = [];
  String? selectedStore;
  List<Map<String, String>> cameraFeeds = [];
  bool isLoading = true;
  bool isAlarmOn = true;
  String? userId;

  final String _storesApi = 'http://localhost:8000';

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchStores();
  }

  Future<void> _loadUserIdAndFetchStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId != null && userId!.isNotEmpty) {
      await fetchUserProfile(userId!);
      await fetchUserStores(userId!);
    } else {
      debugPrint("No user_id found in SharedPreferences");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_storesApi/api/user/profile?user_id=$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          userProfile = UserProfile.fromJson(jsonData);
        });
      } else {
        debugPrint('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<void> fetchUserStores(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_storesApi/api/user/stores?user_id=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);
        setState(() {
          userStores = stores.cast<String>();
          selectedStore = stores.isNotEmpty ? stores[0] : null;
        });
        if (selectedStore != null) {
          await fetchCamerasForStore(selectedStore!);
        }
      } else {
        debugPrint('Error fetching stores: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCamerasForStore(String store) async {
    try {
      final response = await http.get(Uri.parse('$_storesApi/api/store/cameras?store=$store'));
      if (response.statusCode == 200) {
        final List<dynamic> cams = jsonDecode(response.body);
        setState(() {
          cameraFeeds = cams.map<Map<String, String>>((e) => {
                "label": e["label"]?.toString() ?? "Unknown",
                "imageUrl": e["imageUrl"]?.toString() ?? "",
                "videoUrl": e["videoUrl"]?.toString() ?? "",
              }).toList();
        });
      } else {
        debugPrint('Failed to fetch cameras for store $store: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cameras: $e');
    }
  }

  void onStoreSelected(String store) {
    setState(() {
      selectedStore = store;
    });
    fetchCamerasForStore(store);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth - 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/events'),
                            child: const NotificationIcon(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 39),
                    const TitleSection(),
                    const SizedBox(height: 40),

                    Center(
                      child: Container(
                        width: contentWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage('assets/images/profile.png'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProfile?.username ?? 'Loading...',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(userProfile?.email ?? ''),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                // 편집 기능 예정
                              },
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Container(
                        width: contentWidth,
                        child: _buildToggleItem(
                          icon: Icons.alarm,
                          title: 'Alarm',
                          value: isAlarmOn,
                          onChanged: (val) {
                            setState(() {
                              isAlarmOn = val;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Container(
                        width: contentWidth,
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.store_mall_directory,
                              title: 'Store Registration',
                              onTap: () => Navigator.pushNamed(context, '/store_registration'),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.camera_alt_outlined,
                              title: 'Camera Registration',
                              onTap: () => Navigator.pushNamed(context, '/camera_registration'),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.help_outline,
                              iconColor: Colors.red,
                              title: 'Support',
                              onTap: () => Navigator.pushNamed(context, '/support'),
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.info_outline,
                              title: 'About us',
                              onTap: () => Navigator.pushNamed(context, '/about'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (userStores.isEmpty)
                      const Text('No stores registered yet. Please register one.'),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color iconColor = Colors.black54,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class UserProfile {
  final int id;
  final String username;
  final String email;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF222222),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 16),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBD04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
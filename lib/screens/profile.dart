import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final String storesApi = 'http://10.0.2.2:8000/api/user/stores?user_id=user1';

  @override
  void initState() {
    super.initState();
    fetchUserStores();
  }

  Future<void> fetchUserStores() async {
    try {
      final response = await http.get(Uri.parse(storesApi));
      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);
        setState(() {
          userStores = stores.cast<String>();
          selectedStore = stores.isNotEmpty ? stores[0] : null;
          isLoading = false;
        });
        if (selectedStore != null) {
          fetchCamerasForStore(selectedStore!);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load stores.')),
      );
    }
  }

  Future<void> fetchCamerasForStore(String store) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/store/cameras?store=$store'));
    if (response.statusCode == 200) {
      final List<dynamic> cams = jsonDecode(response.body);
      setState(() {
        cameraFeeds = cams.map<Map<String, String>>((e) => {
          "label": e["label"].toString(),
          "imageUrl": e["image_url"].toString(),
        }).toList();
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userStores.isEmpty
              ? const Center(child: Text('Please Register Your Store'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 빈 공간 또는 다른 위젯용 공간
                        const SizedBox(height: 46),

                        // 오른쪽 상단 알림 아이콘
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/events'),
                            child: const NotificationIcon(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // TitleSection 사용
                        const TitleSection(),
                        const SizedBox(height: 24),

                        // 프로필 박스
                        Container(
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
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Aytac Hasanova', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('aytac.hasan@gmail.com'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  // 편집 기능 추가 예정
                                },
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 메뉴: Camera Registration
                        _buildMenuItem(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camera Registration',
                          onTap: () => Navigator.pushNamed(context, '/camera_registration'),
                        ),
                        const SizedBox(height: 12),

                        // 토글: Alarm
                        _buildToggleItem(
                          icon: Icons.alarm,
                          title: 'Alarm',
                          value: isAlarmOn,
                          onChanged: (val) {
                            setState(() {
                              isAlarmOn = val;
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // 메뉴: Support
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          iconColor: Colors.red,
                          title: 'Support',
                          onTap: () => Navigator.pushNamed(context, '/support'),
                        ),
                        const SizedBox(height: 12),

                        // 메뉴: About us
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About us',
                          onTap: () => Navigator.pushNamed(context, '/about'),
                        ),

                        const SizedBox(height: 32),

                        // (선택적으로) 카메라 목록 표시
                        if (cameraFeeds.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Camera Feeds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...cameraFeeds.map((cam) => ListTile(
                                    leading: Image.network(cam["imageUrl"] ?? '', width: 48, height: 48, fit: BoxFit.cover),
                                    title: Text(cam["label"] ?? ''),
                                  )),
                            ],
                          )
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
          border: Border.all(color: Colors.grey.shade300), // 회색 테두리 추가
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300), // 동일한 회색 테두리
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Transform.scale(
            scale: 0.85, // Switch 크기 줄이기 (세로 높이 맞추기)
            child: Switch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center, // 중앙 정렬
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text(
            'Profile',
            style: TextStyle(fontSize: 22, color: Color(0xFF222222), fontWeight: FontWeight.bold),
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
          cursor: SystemMouseCursors.click, // 커서를 손 모양으로 변경
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

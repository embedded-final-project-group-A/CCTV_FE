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
      }
    } catch (e) {
      setState(() => isLoading = false);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userStores.isEmpty
              ? const Center(child: Text('Please Register Your Store'))
              : HomeContent(
                  userStores: userStores,
                  onStoreSelected: onStoreSelected,
                  cameraFeeds: cameraFeeds,
                ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<String> userStores;
  final Function(String) onStoreSelected;
  final List<Map<String, String>> cameraFeeds;

  const HomeContent({
    super.key,
    required this.userStores,
    required this.onStoreSelected,
    required this.cameraFeeds,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return Container(
          width: width,
          height: 837,
          color: const Color(0xFFFDFDFD),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32), // 좌우, 상하 여백
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
            children: [
              // 상단 검정바 대신 그냥 빈 공간 또는 필요시 다른 위젯 넣기
              const SizedBox(height: 32),

              // 오른쪽 상단 알림 아이콘
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/events'),
                  child: const NotificationIcon(),
                ),
              ),

              const SizedBox(height: 24),

              const GreetingSection(),

              const SizedBox(height: 32),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
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

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center, // 수정된 부분
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

class ProfileContent extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileContent({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    bool isAlarmOn = true;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.topRight,
              child: NotificationIcon(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 프로필 박스
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(userEmail, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 메뉴 카드들
            _buildMenuCard(
              context,
              title: 'Camera Registration',
              icon: Icons.camera_alt,
              onPressed: () {
                Navigator.pushNamed(context, '/camera_registration');
              },
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              context,
              title: 'Alarm',
              icon: Icons.alarm,
              value: isAlarmOn,
              onChanged: (val) {
                isAlarmOn = val;
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              title: 'Support',
              icon: Icons.support_agent,
              onPressed: () {
                Navigator.pushNamed(context, '/support');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              title: 'About Us',
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          TextButton(onPressed: onPressed, child: const Text('Go')),
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
              Switch(
                value: value,
                onChanged: (val) {
                  setState(() {
                    onChanged(val);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
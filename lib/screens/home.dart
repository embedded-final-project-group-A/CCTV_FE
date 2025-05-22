import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

              StoreSelector(userStores: userStores, onStoreSelected: onStoreSelected),

              const SizedBox(height: 24),

              CameraFeeds(cameraFeeds: cameraFeeds),
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
      alignment: Alignment(-0.6, 0), // 가운데보다 왼쪽으로 약간 치우치게 조정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hi, Sabina!',
            style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
          ),
          SizedBox(height: 8),
          Text(
            'Be sure of your safety',
            style: TextStyle(fontSize: 22, color: Color(0xFF222222), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class StoreSelector extends StatelessWidget {
  final List<String> userStores;
  final Function(String) onStoreSelected;

  const StoreSelector({super.key, required this.userStores, required this.onStoreSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: userStores.map((store) {
            return GestureDetector(
              onTap: () => onStoreSelected(store),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  store,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF3B71FE)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CameraFeeds extends StatelessWidget {
  final List<Map<String, String>> cameraFeeds;

  const CameraFeeds({super.key, required this.cameraFeeds});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 12) / 2; // 좌우 padding + 간격 고려

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: cameraFeeds
            .map((cam) => _cameraCard(cam['label']!, cam['imageUrl']!, cardWidth))
            .toList(),
      ),
    );
  }

  Widget _cameraCard(String label, String imageUrl, double width) {
    return Container(
      width: width,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 13), blurRadius: 6)],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 128),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 12,
            top: 12,
            child: Icon(Icons.more_vert, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

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

  // *** 중요: 이 부분을 http://localhost:8000 으로 수정합니다! ***
  final String _storesApi = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    fetchUserStores();
  }

  @override
  void dispose() {
    // VideoPlayerController는 FullScreenVideoPage에서만 관리되므로
    // HomePageState 에서는 dispose할 컨트롤러가 없습니다.
    super.dispose();
  }

  Future<void> fetchUserStores() async {
    try {
      final response =
          await http.get(Uri.parse('$_storesApi/api/user/stores?user_id=user1'));
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
      final response =
          await http.get(Uri.parse('$_storesApi/api/store/cameras?store=$store'));
      if (response.statusCode == 200) {
        final List<dynamic> cams = jsonDecode(response.body);
        setState(() {
          cameraFeeds = cams.map<Map<String, String>>((e) => {
                "label": e["label"]?.toString() ?? "Unknown",
                // 백엔드에서 제공하는 'imageUrl' 키를 사용합니다.
                "imageUrl": e["imageUrl"]?.toString() ?? "",
                // 백엔드에서 제공하는 'videoUrl' 키를 사용합니다.
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

  void onStoreSelected(String store) async {
    setState(() {
      selectedStore = store;
    });
    await fetchCamerasForStore(store);
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
                  selectedStore: selectedStore,
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
  final String? selectedStore;

  const HomeContent({
    super.key,
    required this.userStores,
    required this.onStoreSelected,
    required this.cameraFeeds,
    required this.selectedStore,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return Container(
          width: width,
          color: const Color(0xFFFDFDFD),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/events'),
                  child: const NotificationIcon(),
                ),
              ),
              const SizedBox(height: 16),
              const GreetingSection(),
              const SizedBox(height: 32),
              StoreSelector(
                userStores: userStores,
                selectedStore: selectedStore,
                onStoreSelected: onStoreSelected,
              ),
              const SizedBox(height: 20),
              // CameraFeeds 위젯이 ListView.builder를 사용하여 스크롤 가능하게 합니다.
              Expanded(
                child: CameraFeeds(cameraFeeds: cameraFeeds),
              ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications, size: 24, color: Colors.grey),
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
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(-0.6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hi, Hasanova!',
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
  final String? selectedStore;
  final Function(String) onStoreSelected;

  const StoreSelector({super.key, required this.userStores, required this.selectedStore, required this.onStoreSelected});

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
            final isSelected = store == selectedStore;
            final screenWidth = MediaQuery.of(context).size.width;
            // 유동적인 개수보다는 명시적으로 2개씩 배치되도록 재계산합니다.
            // 16*2 (양쪽 패딩), 12 (아이템 간 간격)
            final itemWidth = (screenWidth - 32 - 12) / 2;


            return GestureDetector(
              onTap: () => onStoreSelected(store),
              child: Container(
                width: itemWidth, // 계산된 너비 적용
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B71FE) : const Color(0xFFEEF2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  store,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF3B71FE),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
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
    // 카드 너비를 화면 너비에 맞춰 조정합니다. (양쪽 패딩 16px 제외)
    final cardWidth = screenWidth - 32;

    // 만약 cameraFeeds가 비어있다면, 'No camera feeds available' 메시지를 표시합니다.
    if (cameraFeeds.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No camera feeds available for this store.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // HomeContent에서 이미 좌우 패딩을 줬으므로 여기서는 0
      child: ListView.builder( // 스크롤이 필요한 경우 ListView.builder 사용
        shrinkWrap: true, // 부모의 Column/Expanded 내에서 사용 시 필요
        physics: const ClampingScrollPhysics(), // 스크롤 물리 효과 (선택 사항)
        itemCount: cameraFeeds.length,
        itemBuilder: (context, index) {
          final cam = cameraFeeds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16), // 각 카드 사이의 수직 간격
            child: _cameraCard(cam, cardWidth, context),
          );
        },
      ),
    );
  }

  Widget _cameraCard(Map<String, String> cam, double width, BuildContext context) {
    final label = cam['label'] ?? 'Unknown Camera';
    final imageUrl = cam['imageUrl'] ?? ''; // 백엔드에서 제공하는 imageUrl
    final videoUrl = cam['videoUrl'] ?? ''; // 백엔드에서 제공하는 videoUrl

    return GestureDetector(
      onTap: () {
        if (videoUrl.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => FullScreenVideoPage(videoUrl: videoUrl),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video URL not available for this camera.')),
          );
        }
      },
      child: Container(
        width: width,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6)],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // imageUrl이 비어있지 않다면 Image.network로 표시, 아니면 기본 아이콘
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           debugPrint('Image load error for URL: $imageUrl. Error: $error');
                           return const Icon(Icons.broken_image, size: 48, color: Colors.grey); // 이미지 로드 실패 시
                        },
                      )
                    : const Center(child: Icon(Icons.videocam_off, size: 48, color: Colors.grey)), // imageUrl 없을 시
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
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
      ),
    );
  }
}

class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPage({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _controller.setLooping(true);
          _controller.play();
        });
      }).catchError((e) {
        debugPrint('Video initialization error for URL: ${widget.videoUrl}. Error: $e');
        setState(() {
          _isLoading = false; // 로딩 중단
        });
        // 에러 발생 시 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Text(
                    'Video not available.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
      ),
    );
  }
}
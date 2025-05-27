import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? userId;

  final String _storesApi = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchStores();
  }

  Future<void> _loadUserIdAndFetchStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId != null && userId!.isNotEmpty) {
      await fetchUserStores(userId!);
    } else {
      debugPrint("No user_id found in SharedPreferences");
      setState(() {
        isLoading = false;
      });
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
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
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
            final itemWidth = (screenWidth - 120 - (12 * 3)) / 4;

            return GestureDetector(
              onTap: () => onStoreSelected(store),
              child: Container(
                width: itemWidth,
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
    final cardWidth = screenWidth - 120;

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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: cameraFeeds.length,
        itemBuilder: (context, index) {
          final cam = cameraFeeds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: _cameraCard(cam, cardWidth, context),
            ),
          );
        },
      ),
    );
  }

  Widget _cameraCard(Map<String, String> cam, double width, BuildContext context) {
    final label = cam['label'] ?? 'Unknown Camera';
    final imageUrl = cam['imageUrl'] ?? '';
    final videoUrl = cam['videoUrl'] ?? '';

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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image load error for URL: $imageUrl. Error: $error');
                          return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
                        },
                      )
                    : const Center(child: Icon(Icons.videocam_off, size: 48, color: Colors.grey)),
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
          _isLoading = false;
        });
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

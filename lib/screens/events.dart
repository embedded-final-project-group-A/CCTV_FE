import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<String> userStores = [];
  String? selectedStore;

  List<String> cameraLabels = [];
  String? selectedCamera;

  List<Map<String, String>> events = [];

  bool isLoadingStores = true;
  bool isLoadingCameras = false;
  bool isLoadingEvents = false;

  final String _storesApi = '${ApiConstants.baseUrl}';

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchStores();
  }

  Future<void> _loadUserIdAndFetchStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('user_id');

    if (storedUserId == null) {
      debugPrint('No user_id found in SharedPreferences');
      setState(() {
        isLoadingStores = false;
      });
      return;
    }

    setState(() {
      userId = storedUserId;
    });

    await fetchUserStores();
  }

  Future<void> fetchUserStores() async {
    if (userId == null) return;

    try {
      final response = await http
          .get(Uri.parse('$_storesApi/api/user/stores/detail?user_id=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);
        setState(() {
          userStores = stores.map<String>((e) => e['name'].toString()).toList();
          selectedStore = userStores.isNotEmpty ? userStores[0] : null;
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
        isLoadingStores = false;
      });
    }
  }


  Future<void> fetchCamerasForStore(String store) async {
    setState(() {
      isLoadingCameras = true;
      cameraLabels = [];
      selectedCamera = null;
      events = [];
    });

    try {
      final response =
          await http.get(Uri.parse('$_storesApi/api/store/cameras?store=$store'));
      if (response.statusCode == 200) {
        final List<dynamic> cams = jsonDecode(response.body);
        setState(() {
          cameraLabels =
              cams.map<String>((e) => e["name"]?.toString() ?? "Unknown").toList();
          selectedCamera = cameraLabels.isNotEmpty ? cameraLabels[0] : null;
        });

        if (selectedCamera != null) {
          await fetchEventsForCamera(store, selectedCamera!);
        }
      } else {
        debugPrint(
            'Failed to fetch cameras for store $store: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cameras: $e');
    } finally {
      setState(() {
        isLoadingCameras = false;
      });
    }
  }

  Future<void> fetchEventsForCamera(String store, String cameraLabel) async {
    setState(() {
      isLoadingEvents = true;
      events = [];
    });

    try {
      final response = await http.get(Uri.parse(
          '$_storesApi/api/store/events?store=$store&camera_label=${Uri.encodeComponent(cameraLabel)}'));
      if (response.statusCode == 200) {
        final List<dynamic> evts = jsonDecode(response.body);
        setState(() {
          events = evts.map<Map<String, String>>((e) => {
                "date": e["date"]?.toString() ?? "",
                "type": e["type"]?.toString() ?? "",
                "videoUrl": e["url"]?.toString() ?? "",
              }).toList();
        });
      } else {
        debugPrint(
            'Failed to fetch events for camera $cameraLabel: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
    } finally {
      setState(() {
        isLoadingEvents = false;
      });
    }
  }


  void onStoreSelected(String store) {
    setState(() {
      selectedStore = store;
    });
    fetchCamerasForStore(store);
  }

  void onCameraSelected(String cameraLabel) {
    setState(() {
      selectedCamera = cameraLabel;
      events = [];
    });

    if (selectedStore != null) {
      fetchEventsForCamera(selectedStore!, cameraLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoadingStores
          ? const Center(child: CircularProgressIndicator())
          : userStores.isEmpty
              ? const Center(child: Text('Please Register Your Store'))
              : SingleChildScrollView(
                  child: EventsContent(
                    userStores: userStores,
                    selectedStore: selectedStore,
                    onStoreSelected: onStoreSelected,
                    cameraLabels: cameraLabels,
                    selectedCamera: selectedCamera,
                    onCameraSelected: onCameraSelected,
                    isLoadingCameras: isLoadingCameras,
                  ),
                ),
    );
  }
}

class EventsContent extends StatelessWidget {
  final List<String> userStores;
  final Function(String) onStoreSelected;
  final List<String> cameraLabels;
  final String? selectedStore;
  final String? selectedCamera;
  final Function(String) onCameraSelected;
  final bool isLoadingCameras;

  // 생성자: events, isLoadingEvents, cardWidth 제거
  const EventsContent({
    super.key,
    required this.userStores,
    required this.onStoreSelected,
    required this.cameraLabels,
    required this.selectedStore,
    required this.selectedCamera,
    required this.onCameraSelected,
    required this.isLoadingCameras,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth - 120;

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
              const SizedBox(height: 39),
              const GreetingSection(),
              const SizedBox(height: 40),
              StoreSelector(
                userStores: userStores,
                selectedStore: selectedStore,
                onStoreSelected: onStoreSelected,
              ),
              const SizedBox(height: 20),
              isLoadingCameras
                  ? const Center(child: CircularProgressIndicator())
                  : (selectedStore == null || cameraLabels.isEmpty)
                      ? const Center(child: Text("카메라가 없습니다."))
                      : CameraAccordion(
                          cameraLabels: cameraLabels,
                          selectedStore: selectedStore!,
                          onCameraSelected: onCameraSelected,
                          cardWidth: cardWidth,  // cardWidth 추가
                          // cardWidth 제거 (CameraAccordion 생성자에 없음)
                        ),
            ],
          ),
        );
      },
    );
  }
}

class CameraAccordion extends StatefulWidget {
  final List<String> cameraLabels;
  final String selectedStore;
  final Function(String) onCameraSelected;
  final double cardWidth;

  const CameraAccordion({
    super.key,
    required this.cameraLabels,
    required this.selectedStore,
    required this.onCameraSelected,
    required this.cardWidth,
  });

  @override
  State<CameraAccordion> createState() => _CameraAccordionState();
}

class _CameraAccordionState extends State<CameraAccordion> {
  final Map<String, bool> _expandedMap = {};
  final Map<String, List<Map<String, dynamic>>> _cameraEvents = {};
  final Map<String, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    for (var label in widget.cameraLabels) {
      _expandedMap[label] = false;
      _loadingMap[label] = false;
    }
  }

  Future<void> _fetchEvents(String cameraLabel) async {
    setState(() {
      _loadingMap[cameraLabel] = true;
    });

    final uri = Uri.parse(
        'http://localhost:8000/api/store/events?store=${widget.selectedStore}&camera_label=$cameraLabel');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _cameraEvents[cameraLabel] =
              jsonData.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        debugPrint('Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to fetch events: $e');
    }

    setState(() {
      _loadingMap[cameraLabel] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.cameraLabels.map((cameraLabel) {
        final isExpanded = _expandedMap[cameraLabel] ?? false;
        final isLoading = _loadingMap[cameraLabel] ?? false;
        final events = _cameraEvents[cameraLabel] ?? [];

        return Center( // <-- 여기서 가운데 정렬
          child: Container(
            width: widget.cardWidth,  // 고정된 가로 크기
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    setState(() {
                      _expandedMap[cameraLabel] = !isExpanded;
                      widget.onCameraSelected(cameraLabel);
                    });

                    if (!isExpanded && !_cameraEvents.containsKey(cameraLabel)) {
                      await _fetchEvents(cameraLabel);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Icon(Icons.videocam, color: Colors.black54),
                        const SizedBox(width: 16),
                        Expanded(child: Text(cameraLabel)),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      : events.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text("이벤트가 없습니다."),
                            )
                          : Column(
                              children: events.map((event) {
                                final date = event['date'] ?? '';
                                final type = event['type'] ?? '';
                                final videoUrl = event['url'] ?? '';

                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    if (videoUrl.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullScreenVideoPage(videoUrl: videoUrl),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.event_note, color: Colors.black54),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(date,
                                                  style:
                                                      const TextStyle(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text(type, style: const TextStyle(color: Colors.black54)),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            size: 16, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
              ],
            ),
          ),
        );
      }).toList(),
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

class CameraSelector extends StatelessWidget {
  final List<String> cameraLabels;
  final String? selectedCamera;
  final Function(String) onCameraSelected;

  const CameraSelector({
    super.key,
    required this.cameraLabels,
    required this.selectedCamera,
    required this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 120;

    if (cameraLabels.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No cameras available for this store.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: cameraLabels.map((cameraLabel) {
            final isSelected = cameraLabel == selectedCamera;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                width: cardWidth,
                child: _buildMenuItem(
                  icon: Icons.videocam,
                  title: cameraLabel,
                  isSelected: isSelected,
                  onTap: () => onCameraSelected(cameraLabel),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final bgColor = isSelected ? const Color(0xFF3B71FE) : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.black87;
    final iconColor = isSelected ? Colors.white : Colors.black54;
    final arrowColor = isSelected ? Colors.white : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textColor),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: arrowColor),
          ],
        ),
      ),
    );
  }
}

class EventsList extends StatelessWidget {
  final List<Map<String, String>> events;
  final double cardWidth;

  const EventsList({
    super.key,
    required this.events,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No events available for this camera.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(events.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const SizedBox(height: 12); // separator
            }
            final itemIndex = index ~/ 2;
            final evt = events[itemIndex];
            final date = evt['date'] ?? '';
            final type = evt['type'] ?? '';
            final videoUrl = evt['videoUrl'] ?? '';

            return SizedBox(
              width: cardWidth,
              child: InkWell(
                onTap: () {
                  if (videoUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenVideoPage(videoUrl: videoUrl),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video URL not available for this event.')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Colors.black54),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$date - $type',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
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
      alignment: Alignment.center, // 중앙 정렬
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Events',
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
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              backgroundColor: Colors.white,
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
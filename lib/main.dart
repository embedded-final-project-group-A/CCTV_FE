import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? youtubeUrl;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    fetchYoutubeLink();
  }

  Future<void> fetchYoutubeLink() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/youtube_link'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        youtubeUrl = data['youtube_url'];
        final videoId = YoutubePlayer.convertUrlToId(youtubeUrl!)!;
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      });
    } else {
      // 에러 처리
      debugPrint('Failed to fetch YouTube URL');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('YouTube Video Player')),
        body: Center(
          child: youtubeUrl == null || _controller == null
              ? const CircularProgressIndicator()
              : YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                ),
        ),
      ),
    );
  }
}

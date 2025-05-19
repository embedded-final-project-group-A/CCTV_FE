// home.dart

import 'package:flutter/material.dart';
import 'events.dart'; // Bell icon 클릭 시 이동할 페이지
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<String> userStores = [];
  TabController? _tabController;
  bool isLoading = true;

  // API 주소 변수 (필요시 변경)
  final String apiUrl = 'http://127.0.0.1:8000/api/user/stores?user_id=user1';

  @override
  void initState() {
    super.initState();
    fetchUserStores();
  }

  Future<void> fetchUserStores() async {
    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);
        setState(() {
          userStores = stores.cast<String>();
          if (userStores.isNotEmpty) {
            _tabController = TabController(length: userStores.length, vsync: this);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/events');
            },
          ),
        ],
        bottom: userStores.isNotEmpty && _tabController != null
            ? TabBar(
                controller: _tabController,
                tabs: userStores.map((store) => Tab(text: store)).toList(),
              )
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userStores.isEmpty
              ? const Center(child: Text('Please Regist Your Store'))
              : TabBarView(
                  controller: _tabController,
                  children: userStores.map((store) {
                    return Center(
                      child: Text('Content for $store'),
                    );
                  }).toList(),
                ),
    );
  }
}

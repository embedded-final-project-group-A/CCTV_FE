import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class CameraRegistrationPage extends StatefulWidget {
  const CameraRegistrationPage({super.key});

  @override
  State<CameraRegistrationPage> createState() => _CameraRegistrationPageState();
}

class _CameraRegistrationPageState extends State<CameraRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cameraNameController = TextEditingController();
  final TextEditingController _cameraUrlController = TextEditingController();

  String? userId;

  // Store id & name 리스트를 따로 관리
  List<String> storeIds = [];
  List<String> storeNames = [];

  String? selectedStoreId;
  bool isLoading = true;

  final String _storesApi = '${ApiConstants.baseUrl}';

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchStores();
  }

  Future<void> _loadUserIdAndFetchStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId != null && userId!.isNotEmpty) {
      final response = await http.get(
        Uri.parse("$_storesApi/api/user/stores/detail?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> stores = jsonDecode(response.body);

        setState(() {
          storeIds = stores.map((e) => e['id'].toString()).toList();
          storeNames = stores.map((e) => e['name'] as String).toList();
          selectedStoreId = storeIds.isNotEmpty ? storeIds[0] : null;
          isLoading = false;
        });
      } else {
        debugPrint("Failed to fetch stores: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } else {
      debugPrint("No user_id found in SharedPreferences");
      setState(() => isLoading = false);
    }
  }

  Future<void> _registerCamera() async {
    if (_formKey.currentState!.validate()) {
      final name = _cameraNameController.text.trim();
      final url = _cameraUrlController.text.trim();

      if (userId == null || selectedStoreId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID or Store ID missing")),
        );
        return;
      }

      final videoUrl = "$url.mp4";
      final imageUrl = "$url.jpg";

      final response = await http.post(
        Uri.parse("$_storesApi/api/cameras"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": int.parse(userId!),
          "store_id": int.parse(selectedStoreId!),
          "name": name,
          "video_url": videoUrl,
          "image_url": imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Registered'),
            content: Text('Name: $name\nVideo URL: $videoUrl\nImage URL: $imageUrl'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        _cameraNameController.clear();
        _cameraUrlController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to register camera")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Registration'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedStoreId,
                items: List.generate(storeIds.length, (index) {
                  return DropdownMenuItem(
                    value: storeIds[index],
                    child: Text(storeNames[index]),
                  );
                }),
                onChanged: (value) => setState(() => selectedStoreId = value),
                decoration: const InputDecoration(
                  labelText: 'Select Store',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a store' : null,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cameraNameController,
                      decoration: const InputDecoration(
                        labelText: 'Camera Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter camera name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cameraUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Camera URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter camera URL' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2F7),
                          foregroundColor: const Color(0xFF3B71FE),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Register Camera'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

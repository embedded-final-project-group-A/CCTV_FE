import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class StoreRegistrationPage extends StatefulWidget {
  const StoreRegistrationPage({super.key});

  @override
  State<StoreRegistrationPage> createState() => _StoreRegistrationPageState();
}

class _StoreRegistrationPageState extends State<StoreRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeLocationController = TextEditingController();
  final String _registerApi = '${ApiConstants.baseUrl}/api/store/register';

  Future<void> _registerStore() async {
    if (!_formKey.currentState!.validate()) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      _showDialog('Error', 'User ID not found.');
      return;
    }

    final storeData = {
      'user_id': int.parse(userId),
      'name': _storeNameController.text,
      'location': _storeLocationController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(_registerApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(storeData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showDialog('Success', 'Store registered: ${data['name']}');
        _storeNameController.clear();
        _storeLocationController.clear();
      } else {
        _showDialog('Error', 'Failed to register store: ${response.body}');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to connect to server: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Store Registration',
          style: TextStyle(fontSize: 22, color: Color(0xFF222222), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a new store by entering its name and location below.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Store Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter store name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _storeLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Store Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter store location' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerStore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2F7),
                          foregroundColor: const Color(0xFF3B71FE),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Register Store'),
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

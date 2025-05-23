import 'package:flutter/material.dart';

class CameraRegistrationPage extends StatefulWidget {
  const CameraRegistrationPage({super.key});

  @override
  State<CameraRegistrationPage> createState() => _CameraRegistrationPageState();
}

class _CameraRegistrationPageState extends State<CameraRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cameraNameController = TextEditingController();
  final TextEditingController _cameraUrlController = TextEditingController();

  void _registerCamera() {
    if (_formKey.currentState!.validate()) {
      final name = _cameraNameController.text;
      final url = _cameraUrlController.text;

      // TODO: 실제 등록 API 호출 또는 로직 추가

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Camera Registered'),
          content: Text('Name: $name\nURL: $url'),
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
    }
  }

  @override
  void dispose() {
    _cameraNameController.dispose();
    _cameraUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: const Text(
          'Camera Registration',
          style: TextStyle(
            fontSize: 22,
            color: Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,           // 제목 가운데 정렬
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // 키보드 올라와도 스크롤 가능
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a new camera by entering its name and URL below. '
                'Make sure the URL is correct to ensure proper connection.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter camera name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cameraUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Camera URL',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter camera URL'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerCamera,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2F7), // 하늘색 배경
                          foregroundColor: const Color(0xFF3B71FE),            // 글씨는 흰색
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // 버튼 모서리 둥글게 (선택사항)
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

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();
  String? _idFrontPath;
  String? _idBackPath;

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        switch (type) {
          case 'front':
            _idFrontPath = image.path;
            break;
          case 'back':
            _idBackPath = image.path;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.verified_user, size: 48, color: Color(0xFF3B82F6)),
                  SizedBox(height: 12),
                  Text(
                    'Complete KYC Verification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please provide your documents for verification. This helps us keep your account secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name (as per ID)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idNumberController,
              decoration: InputDecoration(
                labelText: 'ID Number (NID/Passport)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildUploadButton(
              'ID Front Side',
              _idFrontPath,
              () => _pickImage('front'),
            ),
            const SizedBox(height: 12),
            _buildUploadButton(
              'ID Back Side',
              _idBackPath,
              () => _pickImage('back'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitKyc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit for Verification', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, String? path, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(path != null ? Icons.check_circle : Icons.upload_file),
      label: Text(path != null ? '$label - Uploaded' : 'Upload $label'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: path != null ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  void _submitKyc() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _idNumberController.text.isEmpty ||
        _idFrontPath == null ||
        _idBackPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and upload documents')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KYC submitted successfully! We will review within 24 hours.')),
    );
    Navigator.pop(context);
  }
}

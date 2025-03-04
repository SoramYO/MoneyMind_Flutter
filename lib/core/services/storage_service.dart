import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String folderName) async {
    try {
      // Create unique filename with timestamp
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      
      // Create a storage reference
      final ref = _storage.ref().child('$folderName/$fileName');
      
      // Start upload
      final uploadTask = await ref.putFile(file);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading to Firebase: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
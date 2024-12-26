// firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

// firebase_storage_service.dart
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String senderId) async {
    try {
      // Create unique file name
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(filePath)}';
      final ref = _storage.ref().child('messages/$senderId/$fileName');

      // Create blob from file for web
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
      );

      // Upload bytes
      final task = ref.putData(bytes, metadata);

      // Monitor upload progress
      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      // Wait for completion and get URL
      final snapshot = await task;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(File file, {required String filename}) async {
    final ref = _storage.ref().child('products/$filename');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> deleteFileByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Có thể file không tồn tại hoặc đã bị xóa trước đó
      print('⚠️ Storage delete error: $e');
    }
  }
}

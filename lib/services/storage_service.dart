import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file và trả về link tải
  Future<String> uploadProductImage(File file, {required String filename}) async {
    final ref = _storage.ref().child('products/$filename');
    final task = await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Xóa file trong Storage bằng URL (nếu có)
  Future<void> deleteFileByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('⚠️ Không thể xóa file: $e');
    }
  }
}

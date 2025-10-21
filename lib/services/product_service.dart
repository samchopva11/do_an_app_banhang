import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'storage_service.dart';

class ProductService {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
  final StorageService _storageService = StorageService();

  Stream<List<Product>> streamAllProducts() {
    return productsRef.orderBy('createdAt', descending: true).snapshots().map(
            (snap) => snap.docs.map((d) => Product.fromDoc(d)).toList());
  }

  Future<DocumentReference> addProduct(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await productsRef.add(data);
    return docRef;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data, {String? oldImageUrl}) async {
    // Nếu có ảnh cũ và admin đã thay ảnh, thì xóa ảnh cũ
    if (oldImageUrl != null && data['imageUrl'] != oldImageUrl) {
      await _storageService.deleteFileByUrl(oldImageUrl);
    }
    await productsRef.doc(id).update(data);
  }

  Future<void> deleteProduct(String id, {String? imageUrl}) async {
    await productsRef.doc(id).delete();
    // Xóa ảnh trên Storage (nếu có)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storageService.deleteFileByUrl(imageUrl);
    }
  }

  Future<Product?> getProductById(String id) async {
    final doc = await productsRef.doc(id).get();
    if (doc.exists) return Product.fromDoc(doc);
    return null;
  }
}

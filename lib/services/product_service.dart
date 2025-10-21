import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
  final StorageService _storage = StorageService();

  Stream<List<Product>> streamAllProducts() {
    return productsRef.orderBy('createdAt', descending: true).snapshots().map((snap) =>
        snap.docs.map((d) => Product.fromDoc(d)).toList());
  }

  Future<DocumentReference> addProduct(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    final docRef = await productsRef.add(data);
    return docRef;
  }

  /// updateProduct: nếu admin đổi ảnh (imageUrl khác oldImageUrl) -> xóa old image
  Future<void> updateProduct(String id, Map<String, dynamic> data, {String? oldImageUrl}) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (oldImageUrl != null && data['imageUrl'] != oldImageUrl) {
      await _storage.deleteFileByUrl(oldImageUrl);
    }
    await productsRef.doc(id).update(data);
  }

  /// deleteProduct: xóa document rồi xóa image (nếu có)
  Future<void> deleteProduct(String id, {String? imageUrl}) async {
    await productsRef.doc(id).delete();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _storage.deleteFileByUrl(imageUrl);
    }
  }

  Future<Product?> getProductById(String id) async {
    final doc = await productsRef.doc(id).get();
    if (doc.exists) return Product.fromDoc(doc);
    return null;
  }
}

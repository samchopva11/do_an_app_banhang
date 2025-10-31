import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'cart';

  // 🟢 Lấy danh sách giỏ hàng theo userId
  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromDoc(doc)).toList());
  }

  // 🟢 Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(CartItem item, String userId) async {
    final cartRef = _firestore.collection(collection);

    // Kiểm tra xem sản phẩm đã có trong giỏ của user chưa
    final existing = await cartRef
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: item.productId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Nếu đã có thì tăng số lượng
      final doc = existing.docs.first;
      final currentQty = (doc['quantity'] ?? 1) as int;
      await doc.reference.update({'quantity': currentQty + item.quantity});
    } else {
      // Nếu chưa có thì thêm mới
      await cartRef.add({
        ...item.toMap(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }



  // 🟢 Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  // 🟢 Cập nhật số lượng sản phẩm
  Future<void> updateQuantity(String id, int quantity) async {
    await _firestore.collection(collection).doc(id).update({
      'quantity': quantity,
    });
  }

  // 🟢 Xóa toàn bộ giỏ hàng của user
  Future<void> clearCart(String userId) async {
    final batch = _firestore.batch();
    final cartItems = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in cartItems.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

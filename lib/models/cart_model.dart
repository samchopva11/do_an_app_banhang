import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String name;
  final int price;
  final String? imageUrl;
  final int quantity;
  final Timestamp createdAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.quantity,
    required this.createdAt,
  });

  factory CartItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      userId: data['userId'],
      productId: data['productId'],
      name: data['name'],
      price: (data['price'] ?? 0) is int ? data['price'] : (data['price'] ?? 0).toInt(),
      imageUrl: data['imageUrl'],
      quantity: data['quantity'] ?? 1,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }
}

// Product model
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final bool visible;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.visible,
    required this.createdAt,
  });

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0) is int ? data['price'] : (data['price'] ?? 0).toInt(),
      imageUrl: data['imageUrl'],
      visible: data['visible'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'visible': visible,
      'createdAt': createdAt,
    };
  }
}

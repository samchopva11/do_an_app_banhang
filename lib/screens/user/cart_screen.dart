import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final cartService= CartService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Bạn cần đăng nhập để xem giỏ hàng')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng của bạn')),
      body: StreamBuilder<List<CartItem>>(
        stream: cartService.getCartItems(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // lỗi kết nối
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi khi tải giỏ hàng'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống 😅'));
          }

          final total = items.fold<int>(0, (sum, item) => sum + item.price * item.quantity);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return ListTile(
                      leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(item.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: Colors.grey[300]),
                      title: Text(item.name),
                      subtitle: Text('${item.price} VND'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  cartService.updateQuantity(item.id, item.quantity - 1);
                                } else {
                                  cartService.removeFromCart(item.id);
                                }
                              },

                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cartService.updateQuantity(item.id, item.quantity + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng: $total VND', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng đặt hàng sẽ thêm sau 🔜')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

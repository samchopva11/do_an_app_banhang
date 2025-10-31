import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/product_card.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../models/cart_model.dart';
import 'cart_screen.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu người dùng',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Giỏ hàng'),
              onTap: () {
                Navigator.pop(context); // Đóng Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async {
                await auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nổi bật.'));
          }

          final products = snapshot.data!.docs;
          final user = FirebaseAuth.instance.currentUser;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final data = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              // ✅ Sửa lỗi kiểu dữ liệu an toàn
              final String name = data['name'] ?? 'Không tên';
              final String imageUrl = data['imageUrl'] ?? '';
              final int price = (data['price'] is num)
                  ? (data['price'] as num).toInt()
                  : 0;

              return ProductCard(
                name: name,
                price: price.toDouble(),

                imageUrl: imageUrl,
                onAddToCart: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng')),
                    );
                    return;
                  }

                  try {
                    final cartItem = CartItem(
                      id: '',
                      userId: user.uid,
                      productId: productId,
                      name: name,
                      price: price,
                      imageUrl: imageUrl,
                      quantity: 1,
                      createdAt: Timestamp.now(),
                    );

                    await cartService.addToCart(cartItem, user.uid);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã thêm "$name" vào giỏ hàng 🛒')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi thêm vào giỏ hàng: $e')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

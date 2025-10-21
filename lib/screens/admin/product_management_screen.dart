import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import 'product_form_screen.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sản phẩm')),
      body: StreamBuilder<List<Product>>(
        stream: productService.streamAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào.'));
          }
          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, i) {
              final p = products[i];
              return ListTile(
                leading: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? Image.network(p.imageUrl!, width: 64, height: 64, fit: BoxFit.cover)
                    : Container(width: 64, height: 64, color: Colors.grey[200], child: const Icon(Icons.image)),
                title: Text(p.name),
                subtitle: Text('${p.price} VND'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Xóa sản phẩm'),
                          content: const Text('Bạn có chắc muốn xóa sản phẩm này?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await productService.deleteProduct(p.id, imageUrl: p.imageUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
                          }
                        }
                      }
                    },
                  ),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

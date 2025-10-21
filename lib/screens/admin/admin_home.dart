import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'product_management_screen.dart'; // sẽ tạo tiếp

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Admin: ${auth.user?.email ?? ''}')),
            ListTile(title: const Text('Quản lý sản phẩm'), onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
            }),
            ListTile(title: const Text('Đăng xuất'), onTap: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }),
          ],
        ),
      ),
      body: const Center(child: Text('Admin home - chào mừng!')),
    );
  }
}

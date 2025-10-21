import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../role_redirect.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Trang người dùng')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text(auth.user?.email ?? '')),
            ListTile(title: const Text('Trang chủ'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Đăng xuất'), onTap: () async { await auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }),
          ],
        ),
      ),
      body: const Center(child: Text('Đây là giao diện người dùng.')),
    );
  }
}

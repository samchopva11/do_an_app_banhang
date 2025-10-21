import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'admin/admin_home.dart';
import 'user/home_screen.dart';
import 'login_screen.dart';

class RoleRedirect extends StatelessWidget {
  const RoleRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    // nếu chưa login -> chuyển sang Login
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    // nếu profile đã load sẵn -> quyết định ngay
    if (auth.profile != null) {
      return auth.isAdmin ? const AdminHome() : const UserHome();
    }

    // chờ load profile
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).get(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final data = snap.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          // nếu không có document người dùng trong Firestore -> tạo mặc định role=user
          FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).set({
            'email': auth.user!.email,
            'username': auth.user!.displayName ?? '',
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
          return const UserHome();
        }
        final role = data['role'] ?? 'user';
        return role == 'admin' ? const AdminHome() : const UserHome();
      },
    );
  }
}

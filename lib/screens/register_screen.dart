import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _username = TextEditingController();
  bool _loading = false;

  void _doRegister() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final err = await auth.register(email: _email.text.trim(), password: _pw.text, username: _username.text.trim());
    setState(() => _loading = false);
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công. Đăng nhập lại.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _username, decoration: const InputDecoration(labelText: 'Tên hiển thị')),
          const SizedBox(height:8),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height:8),
          TextField(controller: _pw, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          const SizedBox(height:16),
          ElevatedButton(onPressed: _loading ? null : _doRegister, child: _loading ? const CircularProgressIndicator() : const Text('Đăng ký')),
        ],),
      ),
    );
  }
}

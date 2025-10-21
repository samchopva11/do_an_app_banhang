import 'package:do_an_app_banhang/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;

  void _doLogin() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final err = await auth.login(email: _email.text.trim(), password: _pw.text);
    setState(() => _loading = false);
    if (err == null) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height:8),
          TextField(controller: _pw, decoration: const InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          const SizedBox(height:16),
          ElevatedButton(
            onPressed: _loading ? null : _doLogin,
            child: _loading ? const CircularProgressIndicator() : const Text('Đăng nhập'),
          ),
          const SizedBox(height:12),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: const Text('Chưa có tài khoản? Đăng ký'),
          )
        ],),
      ),
    );
  }
}

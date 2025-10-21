import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/role_redirect.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart'; // file được tạo bởi flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChannels.textInput.invokeMethod('TextInput.setClient', []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ứng dụng Bán Hàng',

        // 🇻🇳 Thêm hỗ trợ tiếng Việt
        locale: const Locale('vi', 'VN'),
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Giao diện tổng thể
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          fontFamily: 'Roboto', // font hỗ trợ tiếng Việt
        ),

        // Các route có sẵn
        routes: {
          '/login': (_) => const LoginScreen(),
          '/': (_) => const RoleRedirect(), // route gốc -> user hoặc admin
        },
      ),
    );
  }
}

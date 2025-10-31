import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? user;
  Map<String, dynamic>? profile; // từ Firestore: email, role,...

  AuthService() {
    // Listen auth state
    _auth.authStateChanges().listen((u) async {
      user = u;
      if (user != null) {
        final doc = await _db.collection('users').doc(user!.uid).get();
        profile = doc.exists ? doc.data() : null;
      } else {
        profile = null;
      }
      notifyListeners();
    });
  }

  // Đăng ký: tạo Account + tạo document users trong Firestore
  Future<String?> register({required String email, required String password, required String username}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'role': 'user', // mặc định user
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng nhập
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isLoggedIn => user != null;
  bool get isAdmin => profile != null && (profile!['role'] == 'admin');
}

// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user_name');
    if (user != null && user.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TasksScreen(userName: user)),
      );
    }
  }

  Future<void> _login() async {
    final name = _userCtrl.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TasksScreen(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل الدخول')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('أدخل اسم المستخدم للبدء', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _userCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اسم المستخدم'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _login, child: const Text('دخول'))
            ],
          ),
        ),
      ),
    );
  }
}

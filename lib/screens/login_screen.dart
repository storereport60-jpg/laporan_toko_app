import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  bool loading = false;

  Future<String> _deviceId() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;
    return android.id;
  }

  Future<void> login() async {
    if (_userCtrl.text.isEmpty) return;
    setState(() => loading = true);

    final snap = await FirebaseDatabase.instance.ref('userList').get();
    final device = await _deviceId();

    for (final u in snap.children) {
      final data = Map<String, dynamic>.from(u.value as Map);
      if (data['username'] == _userCtrl.text.toUpperCase()) {
        if (DateTime.parse(data['expired']).isBefore(DateTime.now())) {
          _err('Akun expired'); return;
        }
        if (data['deviceId'] != null && data['deviceId'] != device) {
          _err('Akun digunakan di device lain'); return;
        }
        await u.ref.child('deviceId').set(device);
        if (!mounted) return;
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: data)));
        return;
      }
    }
    _err('User tidak ditemukan');
  }

  void _err(String msg){
    setState(() => loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Login Sistem', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 16),
            TextField(
              controller: _userCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading ? const CircularProgressIndicator() : const Text('Masuk'),
            ),
          ]),
        ),
      ),
    );
  }
}
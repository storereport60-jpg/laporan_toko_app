import 'package:flutter/material.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halo ${user['username']}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _menu(context, 'Selisih Terakhir', 'last'),
        _menu(context, 'SO Adjust', 'adjust'),
        _menu(context, 'Daily Performance', 'daily'),
        _menu(context, 'PLU Tidak Main', 'notmain'),
        _menu(context, 'Discontinue', 'disc'),
        _menu(context, 'Laporan 23–24', '2324'),
      ]),
    );
  }

  Widget _menu(BuildContext c, String title, String type) => Card(
    child: ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(c,
        MaterialPageRoute(builder: (_) => ReportScreen(user: user, type: type))),
    ),
  );
}
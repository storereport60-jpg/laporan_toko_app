import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatefulWidget {
  final Map user;
  final String type;
  const ReportScreen({super.key, required this.user, required this.type});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? data;
  bool loading = false;
  DateTime? start;
  DateTime? end;

  String fmt(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

  Future<void> load() async {
    setState(() => loading = true);
    final store = widget.user['storeId'];
    String url = '';

    switch (widget.type) {
      case 'last':
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan_so/csel_last_so_absolute_desc?storeId=$store';
        break;
      case 'notmain':
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan/laporan_plu_tak_main_toko?storeId=$store&dateTx=${fmt(DateTime.now())}';
        break;
      case 'disc':
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan/rpt_plu_discontinue?storeId=$store&dateSo=${fmt(DateTime.now())}&filter_tag=All';
        break;
      case 'adjust':
        if (start == null) return;
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan_so/csel_all_so_absolute_desc?storeId=$store&dateSo=${fmt(start!)}';
        break;
      case 'daily':
        if (start == null || end == null) return;
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan/daily_performance?storeId=$store&periode1=${fmt(start!)}&periode2=${fmt(end!)}';
        break;
      case '2324':
        if (start == null) return;
        url = 'https://app.alfastore.co.id/prd/api/rpt/laporan/rep_gabungan_23_24?storeId=$store&periode1=${fmt(start!)}';
        break;
    }

    final res = await http.get(Uri.parse(url));
    setState(() { data = res.body; loading = false; });
  }

  Future<void> exportPdf() async {
    if (data == null) return;
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Text('Laporan ${widget.type.toUpperCase()}',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('User: ${widget.user['username']}'),
        pw.Text('Toko: ${widget.user['storeId']}'),
        pw.SizedBox(height: 12),
        pw.Text(data!, style: const pw.TextStyle(fontSize: 9)),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => isStart ? start = picked : end = picked);
  }

  @override
  void initState() {
    super.initState();
    if (['last','notmain','disc'].contains(widget.type)) load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan'), actions: [
        IconButton(icon: const Icon(Icons.picture_as_pdf),
          onPressed: data == null ? null : exportPdf)
      ]),
      body: Column(children: [
        if (!['last','notmain','disc'].contains(widget.type))
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, children: [
              ElevatedButton(onPressed: () => pickDate(true),
                child: Text(start == null ? 'Pilih Tanggal' : fmt(start!))),
              if (widget.type == 'daily')
                ElevatedButton(onPressed: () => pickDate(false),
                  child: Text(end == null ? 'Pilih Akhir' : fmt(end!))),
              ElevatedButton(onPressed: load, child: const Text('Tampilkan')),
            ]),
          ),
        Expanded(child: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
            ? const Center(child: Text('Silakan pilih parameter'))
            : SingleChildScrollView(padding: const EdgeInsets.all(12), child: Text(data!))),
      ]),
    );
  }
}
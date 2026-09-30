import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String scriptUrl = "https://script.google.com/macros/s/AKfycbyzOUFz4Om6ZS0flZEfBTA1DfWX4DTvNmWNggVaro1mcyzkQmt1DFA0kjnKDD2ymqpY/exec";
const String logoUrl = "https://i.ibb.co/6P0yN2B/sewtron-logo.png";

const Color bg = Color(0xFF030712);
const Color panel = Color(0xFF0B1324);
const Color panel2 = Color(0xFF111B2E);
const Color line = Color(0xFF22304A);
const Color blue = Color(0xFF38BDF8);
const Color green = Color(0xFF34D399);
const Color red = Color(0xFFF43F5E);
const Color amber = Color(0xFFF59E0B);
const Color purple = Color(0xFFA855F7);

num n(dynamic value) => num.tryParse(value?.toString() ?? '') ?? 0;
String money(dynamic value) => 'Tk ${n(value).toStringAsFixed(0)}';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SewtronApp());
}

class SewtronApp extends StatelessWidget {
  const SewtronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEWTRON ENGINEERING',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: blue, width: 1.4)),
        ),
      ),
      home: const AuthenticLampLoginScreen(),
    );
  }
}

// ==================== LOGIN ====================
class AuthenticLampLoginScreen extends StatefulWidget {
  const AuthenticLampLoginScreen({super.key});

  @override
  State<AuthenticLampLoginScreen> createState() => _AuthenticLampLoginScreenState();
}

class _AuthenticLampLoginScreenState extends State<AuthenticLampLoginScreen> {
  bool isLightOn = false;
  bool isLogging = false;
  String errorMsg = '';
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void toggleLight() => setState(() { isLightOn = !isLightOn; errorMsg = ''; });

  Future<void> handleLogin() async {
    final u = userCtrl.text.trim();
    final p = passCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      setState(() => errorMsg = 'ইউজারনেম এবং পাসওয়ার্ড লিখুন!');
      return;
    }
    setState(() { isLogging = true; errorMsg = ''; });
    try {
      final uri = Uri.parse('$scriptUrl?action=login&username=${Uri.encodeComponent(u)}&password=${Uri.encodeComponent(p)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body);
      if (data['status'] == 'SUCCESS') {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ModernDashboardScreen(
          user: data['user']['name'] ?? u,
          role: data['user']['role'] ?? 'Admin',
        )));
      } else {
        setState(() => errorMsg = data['message'] ?? 'ইউজারনেম বা পাসওয়ার্ড সঠিক নয়!');
      }
    } catch (e) {
      setState(() => errorMsg = 'কানেকশন এরর: $e');
    } finally {
      if (mounted) setState(() => isLogging = false);
    }
  }

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (isLightOn) Positioned.fill(child: Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(0, -0.55), radius: 1.2,
          colors: [amber.withOpacity(.18), Colors.black.withOpacity(.82), bg],
        )))),
        SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: toggleLight,
                child: Column(children: [
                  Container(width: 4, height: isLightOn ? 38 : 80, color: const Color(0xFF94A3B8)),
                  Container(width: 26, height: 12, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(3))),
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFF7D6), boxShadow: [BoxShadow(color: amber.withOpacity(isLightOn ? .9 : .35), blurRadius: isLightOn ? 42 : 20, spreadRadius: isLightOn ? 14 : 5)]),
                    child: Icon(Icons.lightbulb, color: amber, size: 32),
                  ),
                  if (!isLightOn) ...[
                    Container(width: 4, height: 65, color: const Color(0xFFCBD5E1)),
                    _logoCircle(82),
                    const SizedBox(height: 8),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: amber),
                    const Text('লোগো সুইচে টাচ করে লাইট অন করুন', style: TextStyle(color: Color(0xFFFCD34D), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ]),
              ),
              if (isLightOn) ...[
                const SizedBox(height: 14),
                _logoCircle(88),
                const SizedBox(height: 12),
                const Text('SEWTRON ENGINEERING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('Industrial Electronics & Control', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 22),
                _field(userCtrl, 'ইউজার নেম', Icons.person_outline),
                const SizedBox(height: 12),
                _field(passCtrl, 'পাসওয়ার্ড', Icons.lock_outline, obscure: true),
                if (errorMsg.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: red, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: amber, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: isLogging ? null : handleLogin,
                  child: isLogging ? const CircularProgressIndicator(color: Colors.black) : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5)),
                )),
                TextButton(onPressed: toggleLight, child: const Text('💡 লাইট অফ করুন', style: TextStyle(color: Color(0xFF64748B)))),
              ],
            ]),
          ),
        )))
      ]),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {bool obscure = false}) => TextField(
    controller: c, obscureText: obscure,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: blue), border: const OutlineInputBorder()),
  );

  Widget _logoCircle(double size) => Container(
    width: size, height: size, padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: amber, width: 3), boxShadow: [BoxShadow(color: amber.withOpacity(.35), blurRadius: 18)]),
    child: ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.settings, color: blue, size: 42))),
  );
}

// ==================== DASHBOARD ====================
class ModernDashboardScreen extends StatefulWidget {
  final String user;
  final String role;
  const ModernDashboardScreen({super.key, required this.user, required this.role});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
  bool isSyncing = true;
  Map<String, dynamic> summary = {'totalBill': 0, 'totalPaid': 0, 'totalDue': 0, 'actualCost': 0, 'customers': 0};
  List<dynamic> allEntries = [];
  List<dynamic> costEntries = [];
  List<dynamic> customerList = [];
  List<dynamic> masterCustomers = [];

  @override
  void initState() { super.initState(); syncDatabase(); }

  Future<void> syncDatabase() async {
    if (mounted) setState(() => isSyncing = true);
    try {
      final res = await http.get(Uri.parse(scriptUrl)).timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);
      if (data['status'] == 'SUCCESS' && mounted) {
        setState(() {
          summary = Map<String, dynamic>.from(data['summary'] ?? {});
          allEntries = List<dynamic>.from(data['entries'] ?? []).reversed.toList();
          costEntries = List<dynamic>.from(data['costEntries'] ?? []).reversed.toList();
          customerList = List<dynamic>.from(data['customers'] ?? []);
          masterCustomers = List<dynamic>.from(data['masterCustomers'] ?? data['customers'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) _snack('ডাটাবেস sync হয়নি: $e', error: true);
    } finally {
      if (mounted) setState(() => isSyncing = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: error ? red : panel2, content: Text(msg)));
  }

  Future<void> _post(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(scriptUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 20));
    final text = res.body.trim();
    if (text.isEmpty) throw Exception('Server থেকে কোনো response পাওয়া যায়নি');
    final d = jsonDecode(text);
    if (d is Map && d['status'] != 'SUCCESS') {
      throw Exception(d['message'] ?? 'Server error');
    }
  }

  // ==================== EXISTING FUNCTIONAL MODULES ====================
  void openEditEntryDialog(Map<String, dynamic> e) {
    final nameCtrl = TextEditingController(text: e['name']?.toString() ?? '');
    final billCtrl = TextEditingController(text: n(e['bill']).toString());
    final paidCtrl = TextEditingController(text: n(e['paid']).toString());
    final remCtrl = TextEditingController(text: e['remarks']?.toString() ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('এন্ট্রি সংশোধন • SL: ${e['sl']}', style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 16)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(nameCtrl, 'কাস্টমার নাম'), const SizedBox(height: 10),
        _dialogField(billCtrl, 'মোট বিল (৳)', number: true), const SizedBox(height: 10),
        _dialogField(paidCtrl, 'জমা (৳)', number: true), const SizedBox(height: 10),
        _dialogField(remCtrl, 'বিবরণ'),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.black), onPressed: () async {
          Navigator.pop(ctx);
          try {
            await _post({'action':'edit_entry','rowIndex':e['rowIndex'],'name':nameCtrl.text.trim(),'bill':double.tryParse(billCtrl.text) ?? 0,'paid':double.tryParse(paidCtrl.text) ?? 0,'remarks':remCtrl.text.trim()});
            _snack('বিল আপডেট হয়েছে'); await syncDatabase();
          } catch (err) { _snack('আপডেট ব্যর্থ: $err', error: true); }
        }, child: const Text('আপডেট করুন')),
      ],
    ));
  }

  void confirmDeleteEntry(Map<String, dynamic> e) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel,
      title: const Text('বিল ডিলিট করবেন?', style: TextStyle(color: red, fontWeight: FontWeight.bold)),
      content: Text("চালান '${e['inv']}' স্থায়ীভাবে মুছে ফেলতে চান?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('না')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: red), onPressed: () async {
          Navigator.pop(ctx);
          try { await _post({'action':'delete_entry','rowIndex':e['rowIndex']}); _snack('বিল ডিলিট হয়েছে'); await syncDatabase(); }
          catch (err) { _snack('ডিলিট ব্যর্থ: $err', error: true); }
        }, child: const Text('হ্যাঁ, ডিলিট করুন')),
      ],
    ));
  }

  Future<void> generateAndPrintA4Invoice(Map<String, dynamic> e) async {
    final pdf = pw.Document();
    final bill = n(e['bill']);
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(24), build: (ctx) => pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1.5)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('SEWTRON ENGINEERING', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.Text('BILL INVOICE / QUOTATION', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
        pw.Text('Garments Machinery, Automation & Precision Spare Parts', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.Text('Email: info@sewtroneng.com | Cell: +880 1758-943515 | Dhaka, Bangladesh', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
        pw.Divider(thickness: 1.5, color: PdfColors.blue900, height: 16),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('QUOTATION TO (CUSTOMER INFO):', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.Text('Customer Name: ${e['name'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Attention/Dept: ${e['attention'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Factory Address: ${e['address'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Contact/Mobile: ${e['mobile'] ?? ''}', style: const pw.TextStyle(fontSize: 8)),
          ])),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('INVOICE DETAILS:', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.Text('Invoice No: ${e['inv']}', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Date: ${e['date']}', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Prepared By: ${e['addedBy'] ?? widget.user}', style: const pw.TextStyle(fontSize: 8)),
          ])),
        ]),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: .5),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
          cellHeight: 20, cellStyle: const pw.TextStyle(fontSize: 8),
          headers: ['SL','Item Description','Unit','Qty','Unit Price (BDT)','Total Amount (BDT)'],
          data: [['1',(e['remarks']?.toString().isNotEmpty ?? false) ? e['remarks'].toString() : 'Industrial Machinery Spare Parts','Pcs','1',bill.toStringAsFixed(2),bill.toStringAsFixed(2)]],
        ),
        pw.SizedBox(height: 10),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Container(width: 180, child: pw.Column(children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal:'), pw.Text(bill.toStringAsFixed(2))]),
          pw.Divider(thickness: .5, color: PdfColors.grey400),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TOTAL AMOUNT (BDT):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)), pw.Text(bill.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900))]),
        ]))),
        pw.Spacer(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Customer Acceptance (Sign & Seal)', style: const pw.TextStyle(fontSize: 7.5)), pw.Text('Authorized Signature (SEWTRON)', style: const pw.TextStyle(fontSize: 7.5))]),
      ]),
    )));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void openStatementDialog() {
    showModalBottomSheet(context: context, backgroundColor: panel, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * .88,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        _sheetHandle(), const Text('Customer Statement & Due Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: purple)),
        const SizedBox(height: 8), const Divider(color: line),
        Expanded(child: customerList.isEmpty ? const Center(child: Text('কোনো কাস্টমার স্টেটমেন্ট পাওয়া যায়নি')) : ListView.builder(
          itemCount: customerList.length,
          itemBuilder: (_, i) { final c = customerList[i]; final due = n(c['due']); return Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(14), border: Border.all(color: due > 0 ? red.withOpacity(.35) : green.withOpacity(.25))),
            child: ExpansionTile(
              leading: CircleAvatar(backgroundColor: purple.withOpacity(.16), child: const Icon(Icons.person, color: purple)),
              title: Text(c['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Bill: ${money(c['billed'])}  •  Paid: ${money(c['paid'])}  •  Due: ${money(c['due'])}', style: TextStyle(color: due > 0 ? red : green, fontSize: 11, fontWeight: FontWeight.bold)),
              children: [Container(width: double.infinity, padding: const EdgeInsets.all(12), color: bg, child: Column(children: [
                if (c['history'] is List) ...(c['history'] as List).map((h) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text('${h['date']} | ${h['inv']}', style: const TextStyle(color: Colors.white54, fontSize: 10))), Text('Bill ${money(h['bill'])}', style: const TextStyle(fontSize: 11))]))),
              ]))],
            ),
          ); },
        )),
      ])),
    ));
  }

  void openTotalSummaryDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: panel, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Total Summary', style: TextStyle(color: red, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _summaryLine('সর্বমোট বিল', summary['totalBill'], blue),
        _summaryLine('সর্বমোট আদায়', summary['totalPaid'], green),
        _summaryLine('সর্বমোট বকেয়া', summary['totalDue'], red),
        _summaryLine('মোট মালামাল ক্রয়', summary['actualCost'], amber),
        ListTile(title: const Text('সক্রিয় ক্লায়েন্ট'), trailing: Text('${summary['customers'] ?? 0} জন', style: const TextStyle(fontWeight: FontWeight.bold))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে'))],
    ));
  }

  void openUserProfileDialog() {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'Staff';
    showModalBottomSheet(context: context, backgroundColor: panel, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => StatefulBuilder(builder: (bCtx, setDialogState) => Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(bCtx).viewInsets.bottom + 22),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetHandle(), const Text('User Profiles & Staff Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: green)),
        const SizedBox(height: 8), Text('বর্তমান অ্যাকাউন্ট: ${widget.user} (${widget.role})', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 18),
        _dialogField(nameCtrl, 'ইউজার নেম'), const SizedBox(height: 10), _dialogField(passCtrl, 'পাসওয়ার্ড', obscure: true), const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: selectedRole, decoration: const InputDecoration(labelText: 'পদবী (Role)'), items: const [DropdownMenuItem(value:'Admin',child:Text('Admin')),DropdownMenuItem(value:'Staff',child:Text('Staff'))], onChanged: (v) => setDialogState(() => selectedRole = v ?? 'Staff')),
        const SizedBox(height: 16), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black), onPressed: () async {
          if (nameCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) { _snack('ইউজারনেম ও পাসওয়ার্ড দিন', error: true); return; }
          Navigator.pop(ctx);
          try { await _post({'action':'add_user','name':nameCtrl.text.trim(),'password':passCtrl.text.trim(),'role':selectedRole}); _snack('নতুন স্টাফ সেভ হয়েছে'); }
          catch (e) { _snack('স্টাফ সেভ ব্যর্থ: $e', error: true); }
        }, child: const Text('নতুন স্টাফ সেভ করুন', style: TextStyle(fontWeight: FontWeight.bold)))),
      ]),
    )));
  }

  void openAddCustomerDialog({String? selectAfterSave}) {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final attentionCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const Row(children: [Icon(Icons.person_add_alt_1_rounded, color: green), SizedBox(width: 8), Text('Add New Customer', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white))]),
          const SizedBox(height: 14),
          _dialogField(nameCtrl, 'Customer Name *'), const SizedBox(height: 10),
          _dialogField(companyCtrl, 'Company / Factory Name'), const SizedBox(height: 10),
          _dialogField(attentionCtrl, 'Attention / Department'), const SizedBox(height: 10),
          _dialogField(mobileCtrl, 'Mobile'), const SizedBox(height: 10),
          _dialogField(addressCtrl, 'Factory Address'), const SizedBox(height: 10),
          _dialogField(emailCtrl, 'Email'), const SizedBox(height: 10),
          _dialogField(remarksCtrl, 'Remarks'), const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Customer', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) { _snack('Customer Name দিন', error: true); return; }
              Navigator.pop(ctx);
              try {
                await _post({
                  'action':'add_customer',
                  'name':nameCtrl.text.trim(),
                  'company':companyCtrl.text.trim(),
                  'attention':attentionCtrl.text.trim(),
                  'mobile':mobileCtrl.text.trim(),
                  'address':addressCtrl.text.trim(),
                  'email':emailCtrl.text.trim(),
                  'remarks':remarksCtrl.text.trim(),
                });
                _snack('নতুন Customer Google Sheet-এ সেভ হয়েছে');
                await syncDatabase();
              } catch (e) { _snack('Customer save failed: $e', error: true); }
            },
          )),
        ])),
      ),
    );
  }

  void openAddBillDialog() {
    String? selectedName;
    final invCtrl = TextEditingController();
    final billCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final remCtrl = TextEditingController();
    final attCtrl = TextEditingController();
    final addCtrl = TextEditingController();
    final mobCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (bCtx, setDialogState) {
        Map<String, dynamic>? selectedCustomer;
        for (final c in masterCustomers) {
          if ((c['name']?.toString() ?? '') == selectedName) { selectedCustomer = Map<String, dynamic>.from(c); break; }
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(bCtx).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _sheetHandle(),
            const Row(children: [Icon(Icons.receipt_long_rounded, color: blue), SizedBox(width: 8), Text('Data Entry • New Bill', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: selectedName,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Select Customer *', prefixIcon: Icon(Icons.person_search_rounded)),
                items: masterCustomers.map((c) => DropdownMenuItem<String>(value: c['name']?.toString(), child: Text(c['name']?.toString() ?? '', overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) {
                  setDialogState(() => selectedName = v);
                  final c = masterCustomers.firstWhere((x) => x['name']?.toString() == v, orElse: () => {});
                  attCtrl.text = c['attention']?.toString() ?? '';
                  addCtrl.text = c['address']?.toString() ?? '';
                  mobCtrl.text = c['mobile']?.toString() ?? '';
                },
              )),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: () { Navigator.pop(ctx); openAddCustomerDialog(); }, icon: const Icon(Icons.person_add_alt_1_rounded), tooltip: 'Add New Customer'),
            ]),
            if (selectedCustomer != null) ...[
              const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: green.withOpacity(.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: green.withOpacity(.25))), child: Text('${selectedCustomer['company'] ?? ''}  •  ${selectedCustomer['mobile'] ?? ''}', style: const TextStyle(color: green, fontSize: 11))),
            ],
            const SizedBox(height: 10),
            _dialogField(invCtrl, 'ইনভয়েস নং (ফাঁকা রাখলে auto)'), const SizedBox(height: 10),
            _dialogField(billCtrl, 'মোট বিল (৳)', number: true), const SizedBox(height: 10),
            _dialogField(paidCtrl, 'জমা / Paid (৳)', number: true), const SizedBox(height: 10),
            _dialogField(remCtrl, 'আইটেম বিবরণ'), const SizedBox(height: 10),
            _dialogField(attCtrl, 'Attention / Dept'), const SizedBox(height: 10),
            _dialogField(addCtrl, 'Factory Address'), const SizedBox(height: 10),
            _dialogField(mobCtrl, 'Contact / Mobile'), const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.black),
              icon: const Icon(Icons.save_rounded),
              label: const Text('সংরক্ষণ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                if ((selectedName ?? '').trim().isEmpty || billCtrl.text.trim().isEmpty) { _snack('Customer এবং বিলের পরিমাণ নির্বাচন করুন', error: true); return; }
                final b = double.tryParse(billCtrl.text) ?? 0; final p = double.tryParse(paidCtrl.text) ?? 0;
                if (b <= 0) { _snack('বিলের পরিমাণ 0-এর বেশি দিন', error: true); return; }
                if (p > b) { _snack('Paid amount বিলের চেয়ে বেশি হতে পারবে না', error: true); return; }
                Navigator.pop(ctx);
                try {
                  await _post({'action':'add_entry','name':selectedName,'inv':invCtrl.text.trim(),'bill':b,'paid':p,'due':b-p,'remarks':remCtrl.text.trim(),'addedBy':widget.user,'attention':attCtrl.text.trim(),'address':addCtrl.text.trim(),'mobile':mobCtrl.text.trim(),'date':DateTime.now().toIso8601String().substring(0,10)});
                  _snack('নতুন বিল Google Sheet-এ সেভ হয়েছে'); await syncDatabase();
                } catch (e) { _snack('বিল সেভ ব্যর্থ: $e', error: true); }
              },
            )),
          ])),
        );
      }),
    );
  }

  void openAddCostDialog() {
    final sName = TextEditingController(); final chNo = TextEditingController(); final desc = TextEditingController(); final price = TextEditingController(); final amt = TextEditingController(); final rem = TextEditingController();
    showModalBottomSheet(context: context, backgroundColor: panel, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(18,18,18,MediaQuery.of(ctx).viewInsets.bottom+20),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _sheetHandle(), const Text('Actual Cost • Purchase Entry', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: amber)), const SizedBox(height: 14),
        _dialogField(sName,'সাপ্লায়ারের নাম'), const SizedBox(height:10), _dialogField(chNo,'চালান নম্বর'), const SizedBox(height:10), _dialogField(desc,'আইটেম বিবরণ'), const SizedBox(height:10), _dialogField(price,'দর',number:true), const SizedBox(height:10), _dialogField(amt,'মোট টাকা',number:true), const SizedBox(height:10), _dialogField(rem,'মন্তব্য'), const SizedBox(height:16),
        SizedBox(width:double.infinity,height:50,child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:amber,foregroundColor:Colors.black),onPressed:() async {
          if(sName.text.trim().isEmpty||amt.text.trim().isEmpty){_snack('সাপ্লায়ার ও মোট টাকা দিন',error:true);return;}
          Navigator.pop(ctx);
          try{await _post({'action':'add_cost','supplier':sName.text.trim(),'challan':chNo.text.trim(),'desc':desc.text.trim(),'unitPrice':price.text.trim(),'amount':amt.text.trim(),'remarks':rem.text.trim(),'date':DateTime.now().toIso8601String().substring(0,10)});_snack('Actual Cost Google Sheet-এ সেভ হয়েছে');await syncDatabase();}catch(e){_snack('খরচ সেভ ব্যর্থ: $e',error:true);}
        },child:const Text('খরচ সেভ করুন',style:TextStyle(fontWeight:FontWeight.bold))))
      ]),),
    ));
  }

  Future<void> runCloudBackup() async {
    _snack('Google Drive backup নেওয়া হচ্ছে...');
    try {
      final res = await http.get(Uri.parse('$scriptUrl?action=backup')).timeout(const Duration(seconds:20));
      final d = jsonDecode(res.body);
      if (d['status'] != 'SUCCESS') throw Exception(d['message'] ?? 'Backup failed');
      _snack(d['message']?.toString() ?? 'ব্যাকআপ সম্পন্ন!');
    } catch(e) {
      _snack('Backup ব্যর্থ: $e', error: true);
    }
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      drawer: _drawer(),
      appBar: PreferredSize(preferredSize: const Size.fromHeight(88), child: _topBar()),
      body: isSyncing ? const Center(child: CircularProgressIndicator(color: amber)) : RefreshIndicator(
        color: blue, backgroundColor: panel, onRefresh: syncDatabase,
        child: ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 28), children: [
          _welcomeBanner(), const SizedBox(height: 14),
          _statsGrid(), const SizedBox(height: 20),
          _sectionHeader('Business Modules', 'Core business operations'), const SizedBox(height: 10),
          _moduleGrid(), const SizedBox(height: 20),
          _invoicePanel(), const SizedBox(height: 16),
          _quickActions(), const SizedBox(height: 16),
          _activityPanel(), const SizedBox(height: 20),
          const Center(child: Text('SEWTRON ENGINEERING  •  Business Management System', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5))),
        ]),
      ),
    );
  }

  PreferredSizeWidget _topBar() => PreferredSize(preferredSize: const Size.fromHeight(88), child: Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0B1830), Color(0xFF08101F)])),
    padding: const EdgeInsets.fromLTRB(14, 30, 8, 8),
    child: Row(children: [
      Builder(builder: (ctx) => IconButton(onPressed: () => Scaffold.of(ctx).openDrawer(), icon: const Icon(Icons.menu_rounded, color: Colors.white))),
      _miniLogo(), const SizedBox(width: 9),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SEWTRON ENGINEERING', maxLines:1, overflow:TextOverflow.ellipsis, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, letterSpacing: .4)),
        Text('${widget.user} • ${widget.role}', maxLines:1, overflow:TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
      ])),
      IconButton(onPressed: syncDatabase, icon: const Icon(Icons.refresh_rounded, color: blue)),
      IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthenticLampLoginScreen())), icon: const Icon(Icons.logout_rounded, color: red)),
    ]),
  ));

  Widget _miniLogo() => Container(width:42,height:42,padding:const EdgeInsets.all(2.5),decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white,border:Border.all(color:amber,width:2)),child:ClipOval(child:Image.network(logoUrl,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.settings,color:blue))));

  Widget _welcomeBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors:[Color(0xFF102A55),Color(0xFF0A172C)]), border: Border.all(color: blue.withOpacity(.22))),
    child: Row(children:[Container(width:48,height:48,decoration:BoxDecoration(shape:BoxShape.circle,color:blue.withOpacity(.13)),child:const Icon(Icons.dashboard_customize_rounded,color:blue,size:26)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Business Management System',style:TextStyle(fontSize:15,fontWeight:FontWeight.bold)),const SizedBox(height:3),Text('Welcome back, ${widget.user}. Your live business data is ready.',style:const TextStyle(color:Color(0xFF94A3B8),fontSize:11,height:1.3))])),const Icon(Icons.verified_rounded,color:green,size:20)]),
  );

  Widget _statsGrid() => GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.42,children:[
    _statCard('Total Bill',summary['totalBill'],blue,Icons.receipt_long_rounded),
    _statCard('Total Pay',summary['totalPaid'],green,Icons.account_balance_wallet_rounded),
    _statCard('Total Due',summary['totalDue'],red,Icons.pending_actions_rounded),
    _statCard('Actual Cost',summary['actualCost'],amber,Icons.payments_rounded),
  ]);

  Widget _statCard(String title,dynamic value,Color color,IconData icon)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(borderRadius:BorderRadius.circular(17),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[color.withOpacity(.20),panel]),border:Border.all(color:color.withOpacity(.45))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Container(padding:const EdgeInsets.all(7),decoration:BoxDecoration(color:color.withOpacity(.14),borderRadius:BorderRadius.circular(9)),child:Icon(icon,color:color,size:19)),Icon(Icons.arrow_forward_rounded,color:color.withOpacity(.65),size:17)]),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Color(0xFF94A3B8),fontSize:10.5)),const SizedBox(height:3),Text(money(value),style:TextStyle(color:color,fontSize:17,fontWeight:FontWeight.w900))]) ]));

  Widget _sectionHeader(String title,String sub)=>Row(children:[Container(width:4,height:28,decoration:BoxDecoration(color:blue,borderRadius:BorderRadius.circular(4))),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),Text(sub,style:const TextStyle(color:Color(0xFF64748B),fontSize:10.5))])),Text('${customerList.length} Customers',style:const TextStyle(color:Color(0xFF64748B),fontSize:10))]);

  Widget _moduleGrid()=>GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.45,children:[
    _module('1st','Data Entry','Daily Bill & Collection',blue,Icons.note_add_rounded,openAddBillDialog),
    _module('2nd','Statement','Customer Due Ledger',purple,Icons.calendar_month_rounded,openStatementDialog),
    _module('3rd','Total Summary','Live Due Summary',red,Icons.summarize_rounded,openTotalSummaryDialog),
    _module('4th','Actual Cost','Purchase & Expense',amber,Icons.shopping_cart_rounded,openAddCostDialog),
    _module('5th','User Profiles','Admin & Staff',green,Icons.manage_accounts_rounded,openUserProfileDialog),
    _module('6th','Reports','Sales & Collection',blue,Icons.bar_chart_rounded,openTotalSummaryDialog),
  ]);

  Widget _module(String num,String title,String sub,Color color,IconData icon,VoidCallback tap)=>InkWell(onTap:tap,borderRadius:BorderRadius.circular(16),child:Container(padding:const EdgeInsets.all(11),decoration:BoxDecoration(borderRadius:BorderRadius.circular(16),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[color.withOpacity(.20),panel]),border:Border.all(color:color.withOpacity(.38))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Container(width:38,height:38,decoration:BoxDecoration(color:color.withOpacity(.16),borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:color,size:19)),Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:3),decoration:BoxDecoration(color:color.withOpacity(.17),borderRadius:BorderRadius.circular(6)),child:Text(num,style:TextStyle(color:color,fontSize:9,fontWeight:FontWeight.bold)))]),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:13,fontWeight:FontWeight.bold)),const SizedBox(height:2),Text(sub,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Color(0xFF94A3B8),fontSize:9.5))])])));

  Widget _invoicePanel()=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:blue.withOpacity(.12),borderRadius:BorderRadius.circular(10)),child:const Icon(Icons.receipt_long_rounded,color:blue)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Recent Invoices',style:TextStyle(fontSize:15,fontWeight:FontWeight.bold)),Text('${allEntries.length} invoices • A4 print ready',style:const TextStyle(color:Color(0xFF64748B),fontSize:10))])),TextButton(onPressed:allEntries.isEmpty?null:()=>generateAndPrintA4Invoice(allEntries.first),child:const Text('Latest Print'))]),const Divider(color:line,height:18),if(allEntries.isEmpty)const Padding(padding:EdgeInsets.all(22),child:Center(child:Text('No invoices found',style:TextStyle(color:Color(0xFF64748B))))) else ...allEntries.take(6).map(_invoiceRow)]));

  Widget _invoiceRow(dynamic raw){final e=Map<String,dynamic>.from(raw as Map);final due=n(e['due']);final paid=n(e['paid']);final isPaid=due<=0;final partial=paid>0&&due>0;final color=isPaid?green:(partial?amber:red);final status=isPaid?'PAID':(partial?'PARTIAL':'UNPAID');return Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.symmetric(horizontal:9,vertical:9),decoration:BoxDecoration(color:panel2,borderRadius:BorderRadius.circular(12)),child:Row(children:[Container(width:34,height:34,decoration:BoxDecoration(color:color.withOpacity(.12),borderRadius:BorderRadius.circular(9)),child:Icon(Icons.description_rounded,color:color,size:18)),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e['name']?.toString()??'',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12.5,fontWeight:FontWeight.bold)),Text('Inv: ${e['inv']??''}  •  ${e['date']??''}',style:const TextStyle(color:Color(0xFF64748B),fontSize:9.5))])),Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text(money(e['bill']),style:const TextStyle(fontSize:12,fontWeight:FontWeight.bold)),Container(margin:const EdgeInsets.only(top:3),padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),decoration:BoxDecoration(color:color.withOpacity(.10),border:Border.all(color:color.withOpacity(.6)),borderRadius:BorderRadius.circular(5)),child:Text(status,style:TextStyle(color:color,fontSize:8,fontWeight:FontWeight.bold)))]),PopupMenuButton<String>(color:panel,icon:const Icon(Icons.more_vert,color:Colors.white54,size:18),onSelected:(v){if(v=='print')generateAndPrintA4Invoice(e);if(v=='edit')openEditEntryDialog(e);if(v=='delete')confirmDeleteEntry(e);},itemBuilder:(_)=>const[PopupMenuItem(value:'print',child:Text('Print A4 Bill')),PopupMenuItem(value:'edit',child:Text('Edit Bill')),PopupMenuItem(value:'delete',child:Text('Delete',style:TextStyle(color:red)))]) ]);}

  Widget _quickActions()=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.bolt_rounded,color:amber),SizedBox(width:6),Text('Quick Actions',style:TextStyle(fontSize:15,fontWeight:FontWeight.bold))]),const SizedBox(height:11),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:2.15,children:[_quick('New Bill',Icons.note_add_rounded,blue,openAddBillDialog),_quick('Add Customer',Icons.person_add_alt_1_rounded,green,openAddCustomerDialog),_quick('Statement',Icons.person_search_rounded,purple,openStatementDialog),_quick('Print Latest',Icons.print_rounded,red,()=>allEntries.isNotEmpty?generateAndPrintA4Invoice(allEntries.first):_snack('কোনো invoice নেই',error:true)),_quick('Summary',Icons.bar_chart_rounded,amber,openTotalSummaryDialog),_quick('Backup Data',Icons.cloud_upload_rounded,blue,runCloudBackup),_quick('User Settings',Icons.settings_rounded,green,openUserProfileDialog)])]));

  Widget _quick(String title,IconData icon,Color color,VoidCallback tap)=>ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:color.withOpacity(.14),foregroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12),side:BorderSide(color:color.withOpacity(.35)))),onPressed:tap,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:color,size:17),const SizedBox(width:6),Flexible(child:Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.bold)))]));

  Widget _activityPanel(){final items=allEntries.take(4).toList();return Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:line)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.timeline_rounded,color:blue),SizedBox(width:7),Text('Recent Activity',style:TextStyle(fontSize:15,fontWeight:FontWeight.bold))]),const SizedBox(height:12),if(items.isEmpty)const Text('No recent activity',style:TextStyle(color:Color(0xFF64748B),fontSize:11)) else ...items.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(margin:const EdgeInsets.only(top:3),width:8,height:8,decoration:const BoxDecoration(color:blue,shape:BoxShape.circle)),const SizedBox(width:9),Expanded(child:Text('Bill ${e['inv']??''} • ${e['name']??''} • ${money(e['bill'])}',style:const TextStyle(fontSize:11))),Text(e['date']?.toString()??'',style:const TextStyle(color:Color(0xFF64748B),fontSize:9))])))]));}

  Drawer _drawer()=>Drawer(backgroundColor:panel,child:SafeArea(child:Column(children:[Container(padding:const EdgeInsets.all(20),child:Row(children:[_miniLogo(),const SizedBox(width:10),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SEWTRON ENGINEERING',style:TextStyle(fontWeight:FontWeight.bold)),Text('Business Management',style:TextStyle(color:Color(0xFF64748B),fontSize:10))]))])),const Divider(color:line),_drawerItem(Icons.home_rounded,'Dashboard',()=>Navigator.pop(context)),_drawerItem(Icons.note_add_rounded,'New Bill',(){Navigator.pop(context);openAddBillDialog();}),_drawerItem(Icons.person_add_alt_1_rounded,'Add Customer',(){Navigator.pop(context);openAddCustomerDialog();}),_drawerItem(Icons.receipt_long_rounded,'Statement',(){Navigator.pop(context);openStatementDialog();}),_drawerItem(Icons.bar_chart_rounded,'Summary / Reports',(){Navigator.pop(context);openTotalSummaryDialog();}),_drawerItem(Icons.shopping_cart_rounded,'Actual Cost',(){Navigator.pop(context);openAddCostDialog();}),_drawerItem(Icons.manage_accounts_rounded,'User Profiles',(){Navigator.pop(context);openUserProfileDialog();}),_drawerItem(Icons.cloud_upload_rounded,'Backup',(){Navigator.pop(context);runCloudBackup();}),const Spacer(),Padding(padding:const EdgeInsets.all(16),child:Text('Logged in: ${widget.user} (${widget.role})',style:const TextStyle(color:Color(0xFF64748B),fontSize:10))) ])));

  Widget _drawerItem(IconData icon,String title,VoidCallback tap)=>ListTile(onTap:tap,leading:Icon(icon,color:blue),title:Text(title,style:const TextStyle(fontSize:13)),trailing:const Icon(Icons.chevron_right,color:Color(0xFF475569),size:18));
  Widget _dialogField(TextEditingController c,String label,{bool number=false,bool obscure=false})=>TextField(controller:c,obscureText:obscure,keyboardType:number?TextInputType.number:null,decoration:InputDecoration(labelText:label));
  Widget _sheetHandle()=>Container(width:40,height:4,margin:const EdgeInsets.only(bottom:14),decoration:BoxDecoration(color:const Color(0xFF475569),borderRadius:BorderRadius.circular(5)));
  Widget _summaryLine(String title,dynamic value,Color color)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(title),trailing:Text(money(value),style:TextStyle(color:color,fontWeight:FontWeight.bold,fontSize:14)));
}

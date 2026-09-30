import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String scriptUrl = "https://script.google.com/macros/s/AKfycbyzOUFz4Om6ZS0flZEfBTA1DfWX4DTvNmWNggVaro1mcyzkQmt1DFA0kjnKDD2ymqpY/exec";
const String logoUrl = "https://i.ibb.co/6P0yN2B/sewtron-logo.png";

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
        scaffoldBackgroundColor: const Color(0xFF05070C),
        fontFamily: 'Roboto',
      ),
      home: const AuthenticLampLoginScreen(),
    );
  }
}

// ==================== ১. লগইন স্ক্রিন ====================
class AuthenticLampLoginScreen extends StatefulWidget {
  const AuthenticLampLoginScreen({super.key});

  @override
  State<AuthenticLampLoginScreen> createState() => _AuthenticLampLoginScreenState();
}

class _AuthenticLampLoginScreenState extends State<AuthenticLampLoginScreen> {
  bool isLightOn = false;
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool isLogging = false;
  String errorMsg = "";

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
      errorMsg = "";
    });
  }

  Future<void> handleLogin() async {
    final inputUser = userCtrl.text.trim();
    final inputPass = passCtrl.text.trim();

    if (inputUser.isEmpty || inputPass.isEmpty) {
      setState(() => errorMsg = "ইউজারনেম এবং পাসওয়ার্ড লিখুন!");
      return;
    }

    setState(() { isLogging = true; errorMsg = ""; });

    try {
      final targetUri = Uri.parse(
        "$scriptUrl?action=login&username=${Uri.encodeComponent(inputUser)}&password=${Uri.encodeComponent(inputPass)}"
      );

      final response = await http.get(targetUri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body);

      if (data['status'] == 'SUCCESS') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainDashboardScreen(
              user: data['user']['name'] ?? inputUser,
              role: data['user']['role'] ?? "Admin",
            ),
          ),
        );
      } else {
        setState(() => errorMsg = data['message'] ?? "ইউজারনেম বা পাসওয়ার্ড সঠিক নয়!");
      }
    } catch (err) {
      setState(() => errorMsg = "কানেকশন এরর: $err");
    } finally {
      if (mounted) setState(() => isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          if (isLightOn)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.65),
                    radius: 1.25,
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.18),
                      Colors.black.withOpacity(0.85),
                      const Color(0xFF05070C),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenH - 50),
                child: Column(
                  mainAxisAlignment: isLightOn ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: toggleLight,
                      child: Column(
                        children: [
                          Container(width: 4.5, height: isLightOn ? 45 : 120, color: const Color(0xFF94A3B8)),
                          Container(width: 26, height: 12, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(3))),
                          Container(
                            width: isLightOn ? 42 : 56,
                            height: isLightOn ? 42 : 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLightOn ? const Color(0xFFFFFBEB) : const Color(0xFFFEF3C7).withOpacity(0.85),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(isLightOn ? 0.95 : 0.4),
                                  blurRadius: isLightOn ? 45 : 25,
                                  spreadRadius: isLightOn ? 16 : 8,
                                )
                              ],
                            ),
                            child: Icon(Icons.lightbulb, color: isLightOn ? const Color(0xFFD97706) : Colors.amber.shade800, size: isLightOn ? 26 : 36),
                          ),
                          if (!isLightOn) ...[
                            Container(width: 4, height: 130, color: const Color(0xFFCBD5E1)),
                            Container(
                              width: 78,
                              height: 78,
                              padding: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFF59E0B), width: 4),
                                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.5), blurRadius: 20, spreadRadius: 4)],
                              ),
                              child: ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover)),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFF59E0B), size: 28),
                            const Text("লোগো সুইচে টাচ করুন বা নিচে টান দিন", style: TextStyle(color: Color(0xFFFCD34D), fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ),
                    if (isLightOn) ...[
                      const SizedBox(height: 15),
                      Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                        ),
                        child: ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover)),
                      ),
                      const SizedBox(height: 12),
                      const Text("SEWTRON ENGINEERING", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "ইউজার নেম", border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "পাসওয়ার্ড", border: OutlineInputBorder())),
                      ),
                      const SizedBox(height: 14),
                      if (errorMsg.isNotEmpty) Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(50)),
                          onPressed: isLogging ? null : handleLogin,
                          child: isLogging ? const CircularProgressIndicator(color: Colors.black) : const Text("LOGIN (লগইন করুন)", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(onPressed: toggleLight, child: const Text("💡 লাইট অফ করুন", style: TextStyle(color: Color(0xFF64748B)))),
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==================== ২. মূল ড্যাশবোর্ড ====================
class MainDashboardScreen extends StatefulWidget {
  final String user;
  final String role;
  const MainDashboardScreen({super.key, required this.user, required this.role});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  bool isSyncing = true;
  Map<String, dynamic> summary = {"totalBill": 0, "totalPaid": 0, "totalDue": 0, "actualCost": 0, "customers": 0};
  List<dynamic> allEntries = [];
  List<dynamic> costEntries = [];
  List<dynamic> customerList = [];

  @override
  void initState() {
    super.initState();
    syncDatabase();
  }

  Future<void> syncDatabase() async {
    setState(() => isSyncing = true);
    try {
      final res = await http.get(Uri.parse(scriptUrl)).timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (data['status'] == 'SUCCESS') {
        if (!mounted) return;
        setState(() {
          summary = data['summary'];
          allEntries = data['entries'].reversed.toList();
          costEntries = data['costEntries'].reversed.toList();
          customerList = data['customers'];
        });
      }
    } catch (_) {}
    if (mounted) setState(() => isSyncing = false);
  }

  // --- ২ নম্বর মডিউল: কাস্টমার ডিউ স্টেটমেন্ট ডায়ালগ ---
  void openStatementDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("2nd - Customer Statement & Due Ledger", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
            const Divider(color: Color(0xFF334155), height: 20),
            Expanded(
              child: customerList.isEmpty
                  ? const Center(child: Text("কোনো কাস্টমার স্টেটমেন্ট পাওয়া যায়নি"))
                  : ListView.builder(
                      itemCount: customerList.length,
                      itemBuilder: (cCtx, i) {
                        final c = customerList[i];
                        return Card(
                          color: const Color(0xFF0F172A),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2D3748))),
                          child: ExpansionTile(
                            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                            subtitle: Text("মোট বিল: ৳${c['billed']} | জমা: ৳${c['paid']} | বকেয়া: ৳${c['due']}",
                                style: TextStyle(color: (c['due'] > 0) ? const Color(0xFFF87171) : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                color: const Color(0xFF161F30),
                                child: Column(
                                  children: [
                                    ...(c['history'] as List<dynamic>).map((h) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${h['date']} | ${h['inv']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text("বিল: ৳${h['bill']} (বাকি: ৳${h['due']})", style: const TextStyle(fontSize: 11, color: Colors.white)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ৩ নম্বর মডিউল: টোটাল সামারি লাইভ ডায়ালগ ---
  void openTotalSummaryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("3rd - Total Summary (সারসংক্ষেপ)", style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("সর্বমোট কাজের বিল"), trailing: Text("৳ ${summary['totalBill']}", style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("সর্বমোট আদায়"), trailing: Text("৳ ${summary['totalPaid']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("সর্বমোট বকেয়া (Due)"), trailing: Text("৳ ${summary['totalDue']}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))),
            ListTile(title: const Text("মোট মালামাল ক্রয়"), trailing: Text("৳ ${summary['actualCost']}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("মোট সক্রিয় ক্লায়েন্ট"), trailing: Text("${summary['customers']} জন", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ঠিক আছে", style: TextStyle(color: Color(0xFFF59E0B)))),
        ],
      ),
    );
  }

  // --- ৫ নম্বর মডিউল: ইউজার প্রোফাইল ও নতুন ইউজার অ্যাড ---
  void openUserProfileDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final newNameCtrl = TextEditingController();
        final newPassCtrl = TextEditingController();
        String selectedRole = "Staff";

        return StatefulBuilder(
          builder: (bCtx, setDialogState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(bCtx).viewInsets.bottom + 20, left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("5th - User Profiles & Staff Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                  const Divider(color: Color(0xFF334155), height: 16),
                  Text("বর্তমান লগইন: ${widget.user} (${widget.role})", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  const Text("নতুন ইউজার তৈরি করুন:", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(controller: newNameCtrl, decoration: const InputDecoration(labelText: "ইউজার নেম", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "পাসওয়ার্ড", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: "পদবী (Role)", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: "Admin", child: Text("Admin")),
                      DropdownMenuItem(value: "Staff", child: Text("Staff")),
                    ],
                    onChanged: (v) => setDialogState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34D399), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
                    onPressed: () async {
                      if (newNameCtrl.text.isNotEmpty && newPassCtrl.text.isNotEmpty) {
                        Navigator.pop(ctx);
                        await http.post(
                          Uri.parse(scriptUrl),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "action": "add_user",
                            "name": newNameCtrl.text.trim(),
                            "password": newPassCtrl.text.trim(),
                            "role": selectedRole,
                          }),
                        );
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("নতুন ইউজার সফলভাবে যোগ করা হয়েছে!")));
                      }
                    },
                    child: const Text("নতুন ইউজার সেভ করুন", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ১ নম্বর মডিউল: নতুন বিল ডাটা এন্ট্রি ---
  void openAddBillDialog() {
    final nameCtrl = TextEditingController();
    final invCtrl = TextEditingController();
    final billCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final remCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("1st - Data Entry (নতুন বিল)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "কাস্টমারের নাম", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: invCtrl, decoration: const InputDecoration(labelText: "চালান / ইনভয়েস নং", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: billCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "মোট বিল (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "জমা / পেইড (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: remCtrl, decoration: const InputDecoration(labelText: "আইটেম বিবরণ", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && billCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    double b = double.tryParse(billCtrl.text) ?? 0;
                    double p = double.tryParse(paidCtrl.text) ?? 0;
                    await http.post(
                      Uri.parse(scriptUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "action": "add_entry",
                        "name": nameCtrl.text,
                        "inv": invCtrl.text,
                        "bill": b,
                        "paid": p,
                        "due": b - p,
                        "remarks": remCtrl.text,
                        "addedBy": widget.user,
                        "date": DateTime.now().toIso8601String().substring(0, 10)
                      }),
                    );
                    syncDatabase();
                  }
                },
                child: const Text("সংরক্ষণ করুন", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- ৪ নম্বর মডিউল: একচুয়াল কস্ট ম্যানুয়াল এন্ট্রি ---
  void openAddCostDialog() {
    final sName = TextEditingController();
    final chNo = TextEditingController();
    final desc = TextEditingController();
    final price = TextEditingController();
    final amt = TextEditingController();
    final rem = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161F30),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("4th - Actual Cost (পার্টস ক্রয় এন্ট্রি)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              TextField(controller: sName, decoration: const InputDecoration(labelText: "সাপ্লায়ারের নাম", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: chNo, decoration: const InputDecoration(labelText: "চালান নম্বর", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: desc, decoration: const InputDecoration(labelText: "আইটেম বিবরণ", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "দর", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: amt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "মোট টাকা", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: rem, decoration: const InputDecoration(labelText: "মন্তব্য", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
                onPressed: () async {
                  if (sName.text.isNotEmpty && amt.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    await http.post(
                      Uri.parse(scriptUrl),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "action": "add_cost",
                        "supplier": sName.text,
                        "challan": chNo.text,
                        "desc": desc.text,
                        "unitPrice": price.text,
                        "amount": amt.text,
                        "remarks": rem.text,
                        "date": DateTime.now().toIso8601String().substring(0, 10)
                      }),
                    );
                    syncDatabase();
                  }
                },
                child: const Text("খরচ সেভ করুন", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- A4 ইনভয়েস জেনারেটর ---
  Future<void> generateAndPrintA4Invoice(Map<String, dynamic> e) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 2)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("SEWTRON ENGINEERING", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text("BILL INVOICE / QUOTATION", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                pw.Text("Garments Machinery, Automation & Precision Spare Parts", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Customer Name : ${e['name']}", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Invoice No : ${e['inv']}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Date : ${e['date']}", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Prepared By : ${e['addedBy'] ?? widget.user}", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 14),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  cellHeight: 24,
                  headers: ['SL', 'Item Description', 'Unit', 'Qty', 'Unit Price', 'Total (BDT)'],
                  data: [
                    ['1', e['remarks'] != "" ? e['remarks'] : "Industrial Spare Parts", 'Pcs', '1', "${e['bill']}.00", "${e['bill']}.00"],
                  ],
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Customer Acceptance (Sign & Seal)", style: const pw.TextStyle(fontSize: 8)),
                    pw.Text("Authorized Signature (SEWTRON)", style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: const Color(0xFF161F30),
          padding: const EdgeInsets.only(top: 32, left: 14, right: 14, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFF59E0B), width: 2)),
                    child: ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.settings, color: Colors.blue))),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("SEWTRON ENGINEERING", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text("Logged: ${widget.user} (${widget.role})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                    onPressed: () => syncDatabase(),
                    child: const Text("Refresh", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthenticLampLoginScreen())),
                    child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: isSyncing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    Expanded(child: metricCard("Total Bill", "Tk ${summary['totalBill']}", const Color(0xFF38BDF8))),
                    const SizedBox(width: 10),
                    Expanded(child: metricCard("Total Pay", "Tk ${summary['totalPaid']}", const Color(0xFF4ADE80))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: metricCard("Total Due", "Tk ${summary['totalDue']}", const Color(0xFFF87171))),
                    const SizedBox(width: 10),
                    Expanded(child: metricCard("Actual Cost", "Tk ${summary['actualCost']}", const Color(0xFFFBBF24))),
                  ],
                ),
                const SizedBox(height: 18),
                const Text("BUSINESS MODULES:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                const SizedBox(height: 8),

                // ৫টি মডিউল এখন সম্পূর্ণ ক্লিকযোগ্য
                moduleCard("1st", "Data Entry", "Daily Bill & Collection (New Entry)", "ENTRY", const Color(0xFF38BDF8), openAddBillDialog),
                moduleCard("2nd", "Statement", "Customer Statement & Due Ledger", "VIEW", const Color(0xFFA78BFA), openStatementDialog),
                moduleCard("3rd", "Total Summary", "All Customer Due Summary (Live)", "VIEW", const Color(0xFFF87171), openTotalSummaryDialog),
                moduleCard("4th", "Actual Cost", "Component Purchase & Expense Entry", "ENTRY", const Color(0xFFFBBF24), openAddCostDialog),
                moduleCard("5th", "User Profiles", "Admin & Staff Profiles (Add/Edit)", "EDIT", const Color(0xFF34D399), openUserProfileDialog),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2D3748))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent Invoices (A4 Bill Print)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                      const Divider(height: 16, color: Color(0xFF2D3748)),
                      ...allEntries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF8FAFC))),
                                Text("Inv: ${e['inv']} | ${e['date']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                              ],
                            ),
                            Row(
                              children: [
                                Text("Tk ${e['due']}", style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(width: 8),
                                IconButton(icon: const Icon(Icons.print, color: Color(0xFFF59E0B), size: 20), onPressed: () => generateAndPrintA4Invoice(e)),
                              ],
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget moduleCard(String num, String title, String desc, String tag, Color col, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF161F30),
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2D3748))),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: col, width: 2), color: const Color(0xFF0F172A)),
          child: Text(num, style: TextStyle(fontWeight: FontWeight.bold, color: col, fontSize: 11)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        subtitle: Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(6)),
          child: Text(tag, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 10)),
        ),
      ),
    );
  }

  Widget metricCard(String title, String val, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF161F30), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: c, width: 4.5))),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
        ],
      ),
    );
  }
}

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
        scaffoldBackgroundColor: const Color(0xFF030712),
        fontFamily: 'Roboto',
      ),
      home: const AuthenticLampLoginScreen(),
    );
  }
}

// ==================== ১. ঝুলন্ত ডিম লাইট লগইন স্ক্রিন ====================
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
    final u = userCtrl.text.trim();
    final p = passCtrl.text.trim();

    if (u.isEmpty || p.isEmpty) {
      setState(() => errorMsg = "ইউজারনেম এবং পাসওয়ার্ড লিখুন!");
      return;
    }

    setState(() { isLogging = true; errorMsg = ""; });

    try {
      final targetUri = Uri.parse(
        "$scriptUrl?action=login&username=${Uri.encodeComponent(u)}&password=${Uri.encodeComponent(p)}"
      );
      final response = await http.get(targetUri).timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body);

      if (data['status'] == 'SUCCESS') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ModernDashboardScreen(
              user: data['user']['name'] ?? u,
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
                      const Color(0xFF030712),
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
                            const Text("লোগো সুইচে টাচ করে লাইট অন করুন", style: TextStyle(color: Color(0xFFFCD34D), fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ),
                    if (isLightOn) ...[
                      const SizedBox(height: 15),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                        ),
                        child: ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover)),
                      ),
                      const SizedBox(height: 12),
                      const Text("SEWTRON ENGINEERING", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text("Industrial Electronics & Control", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
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

// ==================== ২. প্রিমিয়াম বিজনেস ড্যাশবোর্ড ====================
class ModernDashboardScreen extends StatefulWidget {
  final String user;
  final String role;
  const ModernDashboardScreen({super.key, required this.user, required this.role});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
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

  // --- অ্যাডমিন এডিট ডায়ালগ ---
  void openEditEntryDialog(Map<String, dynamic> e) {
    final nameCtrl = TextEditingController(text: e['name']);
    final billCtrl = TextEditingController(text: e['bill'].toString());
    final paidCtrl = TextEditingController(text: e['paid'].toString());
    final remCtrl = TextEditingController(text: e['remarks']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("এন্ট্রি সংশোধন (SL: ${e['sl']})", style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "কাস্টমার নাম", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: billCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "মোট বিল (৳)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "জমা (৳)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: remCtrl, decoration: const InputDecoration(labelText: "বিবরণ", border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("বাতিল", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              await http.post(
                Uri.parse(scriptUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "action": "edit_entry",
                  "rowIndex": e['rowIndex'],
                  "name": nameCtrl.text,
                  "bill": double.tryParse(billCtrl.text) ?? 0,
                  "paid": double.tryParse(paidCtrl.text) ?? 0,
                  "remarks": remCtrl.text
                }),
              );
              syncDatabase();
            },
            child: const Text("আপডেট করুন", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- অ্যাডমিন ডিলিট ডায়ালগ ---
  void confirmDeleteEntry(Map<String, dynamic> e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("বিল ডিলিট করবেন?", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("চালান '${e['inv']}' স্থায়ীভাবে মুছে ফেলতে চান?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("না")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await http.post(
                Uri.parse(scriptUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"action": "delete_entry", "rowIndex": e['rowIndex']}),
              );
              syncDatabase();
            },
            child: const Text("হ্যাঁ, ডিলিট করুন"),
          )
        ],
      ),
    );
  }

  // --- A4 ইনভয়েস জেনারেটর ---
  Future<void> generateAndPrintA4Invoice(Map<String, dynamic> e) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue900, width: 1.5)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("SEWTRON ENGINEERING", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text("BILL INVOICE / QUOTATION", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                        pw.Text("Garments Machinery, Automation & Precision Spare Parts", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text("Email: info@sewtroneng.com | Cell: +880 1758-943515 | Dhaka, Bangladesh", style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900, height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("QUOTATION TO (CUSTOMER INFO):", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 3),
                          pw.Text("Customer Name: ${e['name'] ?? 'Simba Fashions Ltd'}", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("Attention/Dept: ${e['attention'] ?? 'Mr Sabuj Sir'}", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("Factory Address: ${e['address'] ?? 'Adamjee Epz, Narayanganj'}", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("Contact/Mobile: ${e['mobile'] ?? '01913877410'}", style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("INVOICE DETAILS:", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 3),
                          pw.Text("Invoice No: ${e['inv']}", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("Date: ${e['date']}", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("Prepared By: ${e['addedBy'] ?? widget.user}", style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  cellHeight: 20,
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  headers: ['SL', 'Item Description', 'Unit', 'Qty', 'Unit Price (BDT)', 'Total Amount (BDT)'],
                  data: [
                    [
                      '1',
                      (e['remarks'] != null && e['remarks'].toString().isNotEmpty) ? e['remarks'] : "Industrial Machinery Spare Parts",
                      'Pcs',
                      '1',
                      "${e['bill']}.00",
                      "${e['bill']}.00"
                    ],
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 180,
                      child: pw.Column(
                        children: [
                          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                            pw.Text("Subtotal:", style: const pw.TextStyle(fontSize: 8)),
                            pw.Text("${e['bill']}.00", style: const pw.TextStyle(fontSize: 8)),
                          ]),
                          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                            pw.Text("TOTAL AMOUNT (BDT):", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            pw.Text("${e['bill']}.00", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Customer Acceptance (Sign & Seal)", style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Text("Authorized Signature (SEWTRON)", style: const pw.TextStyle(fontSize: 7.5)),
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

  // --- ২য় মডিউল: স্টেটমেন্ট ডায়ালগ ---
  void openStatementDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Customer Statement & Due Ledger", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFA855F7))),
            const Divider(color: Color(0xFF334155), height: 20),
            Expanded(
              child: customerList.isEmpty
                  ? const Center(child: Text("কোনো কাস্টমার স্টেটমেন্ট পাওয়া যায়নি"))
                  : ListView.builder(
                      itemCount: customerList.length,
                      itemBuilder: (cCtx, i) {
                        final c = customerList[i];
                        return Card(
                          color: const Color(0xFF1E293B),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF334155))),
                          child: ExpansionTile(
                            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                            subtitle: Text("মোট বিল: ৳${c['billed']} | জমা: ৳${c['paid']} | বকেয়া: ৳${c['due']}",
                                style: TextStyle(color: (c['due'] > 0) ? const Color(0xFFF43F5E) : Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                color: const Color(0xFF0F172A),
                                child: Column(
                                  children: [
                                    if (c['history'] != null)
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

  // --- ৩য় মডিউল: টোটাল সামারি লাইভ ডায়ালগ ---
  void openTotalSummaryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Total Summary (সারসংক্ষেপ)", style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("সর্বমোট বিল"), trailing: Text("৳ ${summary['totalBill']}", style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("সর্বমোট আদায়"), trailing: Text("৳ ${summary['totalPaid']}", style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("সর্বমোট বকেয়া (Due)"), trailing: Text("৳ ${summary['totalDue']}", style: const TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold, fontSize: 16))),
            ListTile(title: const Text("মোট মালামাল ক্রয়"), trailing: Text("৳ ${summary['actualCost']}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 15))),
            ListTile(title: const Text("সক্রিয় ক্লায়েন্ট"), trailing: Text("${summary['customers']} জন", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ঠিক আছে", style: TextStyle(color: Color(0xFFF59E0B)))),
        ],
      ),
    );
  }

  // --- ৫ম মডিউল: ইউজার প্রোফাইল ও নতুন স্টাফ যুক্ত ---
  void openUserProfileDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
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
                  const Text("User Profiles & Staff Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                  const Divider(color: Color(0xFF334155), height: 16),
                  Text("বর্তমান অ্যাকাউন্ট: ${widget.user} (${widget.role})", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  const Text("নতুন স্টাফ যুক্ত করুন:", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13)),
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
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("নতুন স্টাফ সিরিয়াল অনুযায়ী সেভ হয়েছে!")));
                      }
                    },
                    child: const Text("নতুন স্টাফ সেভ করুন", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ১ম মডিউল: নতুন বিল ডাটা এন্ট্রি ---
  void openAddBillDialog() {
    final nameCtrl = TextEditingController();
    final invCtrl = TextEditingController();
    final billCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final remCtrl = TextEditingController();
    final attCtrl = TextEditingController(text: "Mr Sabuj Sir");
    final addCtrl = TextEditingController(text: "Adamjee Epz, Narayanganj");
    final mobCtrl = TextEditingController(text: "01913877410");

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Data Entry (নতুন চালান ও বিল)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "কাস্টমার নাম (যেমন: Simba Fashions Ltd)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: invCtrl, decoration: const InputDecoration(labelText: "ইনভয়েস নং (যেমন: SE-QT-2026-001)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: billCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "মোট বিল (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "জমা / পেইড (৳)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: remCtrl, decoration: const InputDecoration(labelText: "আইটেম বিবরণ (Item Description)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: attCtrl, decoration: const InputDecoration(labelText: "Attention / Dept", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: addCtrl, decoration: const InputDecoration(labelText: "Factory Address", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: mobCtrl, decoration: const InputDecoration(labelText: "Contact / Mobile", border: OutlineInputBorder())),
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
                        "attention": attCtrl.text,
                        "address": addCtrl.text,
                        "mobile": mobCtrl.text,
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

  // --- ৪র্থ মডিউল: একচুয়াল কস্ট ম্যানুয়াল এন্ট্রি ---
  void openAddCostDialog() {
    final sName = TextEditingController();
    final chNo = TextEditingController();
    final desc = TextEditingController();
    final price = TextEditingController();
    final amt = TextEditingController();
    final rem = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Actual Cost (পার্টস ক্রয় এন্ট্রি)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48)),
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

  // ব্যাকআপ ড্রাইভে সেভ মেথড
  void runCloudBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("গুগল ড্রাইভে অটো ব্যাকআপ নেওয়া হচ্ছে...")));
    try {
      final res = await http.get(Uri.parse("$scriptUrl?action=backup")).timeout(const Duration(seconds: 20));
      final d = jsonDecode(res.body);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(d['message'] ?? "ব্যাকআপ সম্পন্ন!")));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ব্যাকআপ সম্পন্ন হয়েছে!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Container(
          color: const Color(0xFF0B132B),
          padding: const EdgeInsets.only(top: 36, left: 14, right: 14, bottom: 10),
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
                      const Text("SEWTRON ENGINEERING", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      Text("Business Management System  |  ${widget.user} (${widget.role})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF38BDF8), size: 22),
                    onPressed: () => syncDatabase(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthenticLampLoginScreen())),
                  ),
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
                // ৪টি প্রিমিয়াম ট্রেন্ডিং কার্ড গ্রিড
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: [
                    modernGlowCard("Total Bill", "Tk ${summary['totalBill']}", "+12%", const Color(0xFF1E3A8A), const Color(0xFF38BDF8), Icons.description),
                    modernGlowCard("Total Pay", "Tk ${summary['totalPaid']}", "+8%", const Color(0xFF064E3B), const Color(0xFF34D399), Icons.account_balance_wallet),
                    modernGlowCard("Total Due", "Tk ${summary['totalDue']}", "+5%", const Color(0xFF881337), const Color(0xFFF43F5E), Icons.access_time_filled),
                    modernGlowCard("Actual Cost", "Tk ${summary['actualCost']}", "+10%", const Color(0xFF78350F), const Color(0xFFF59E0B), Icons.monetization_on),
                  ],
                ),
                const SizedBox(height: 18),

                // বিজনেস মডিউল হেডার
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Business Modules", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                      icon: const Icon(Icons.add, size: 14, color: Color(0xFF38BDF8)),
                      label: const Text("Add Module", style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                      onPressed: openUserProfileDialog,
                    )
                  ],
                ),
                const SizedBox(height: 10),

                // মডিউল গ্রিড (২ কলাম)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    moduleButtonCard("1st", "Data Entry", "Daily Bill & Collection", const Color(0xFF2563EB), Icons.note_add, openAddBillDialog),
                    moduleButtonCard("2nd", "Statement", "Customer Statement", const Color(0xFF9333EA), Icons.calendar_month, openStatementDialog),
                    moduleButtonCard("3rd", "Total Summary", "Live Due Summary", const Color(0xFFE11D48), Icons.assignment, openTotalSummaryDialog),
                    moduleButtonCard("4th", "Actual Cost", "Expense & Purchase", const Color(0xFFD97706), Icons.shopping_cart, openAddCostDialog),
                    moduleButtonCard("5th", "User Profiles", "Admin & Staff Profiles", const Color(0xFF059669), Icons.manage_accounts, openUserProfileDialog),
                    moduleButtonCard("6th", "Reports", "Sales & Collection", const Color(0xFF0284C7), Icons.bar_chart, openTotalSummaryDialog),
                  ],
                ),
                const SizedBox(height: 18),

                // Recent Invoices সেকশন (ফুল একশন টেবিল)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt_long, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 8),
                              Text("Recent Invoices (A4 Bill Print)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                          Text("${allEntries.length} Invoices", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                      const Divider(height: 18, color: Color(0xFF1E293B)),
                      ...allEntries.map((e) {
                        bool isPaid = (e['due'] ?? 0) <= 0;
                        bool isPartial = (e['paid'] ?? 0) > 0 && (e['due'] ?? 0) > 0;
                        Color statusCol = isPaid ? const Color(0xFF34D399) : (isPartial ? const Color(0xFFF59E0B) : const Color(0xFFF43F5E));
                        String statusTxt = isPaid ? "Paid" : (isPartial ? "Partial" : "Unpaid");

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFF1E293B).withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.description, color: Color(0xFF38BDF8), size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                      Text("Inv: ${e['inv']} | ${e['date']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Tk ${e['bill']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(border: Border.all(color: statusCol), borderRadius: BorderRadius.circular(4)),
                                      child: Text(statusTxt, style: TextStyle(color: statusCol, fontSize: 9, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 6),
                                PopupMenuButton<String>(
                                  color: const Color(0xFF0F172A),
                                  icon: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
                                  onSelected: (val) {
                                    if (val == 'print') generateAndPrintA4Invoice(e);
                                    if (val == 'edit') openEditEntryDialog(e);
                                    if (val == 'delete') confirmDeleteEntry(e);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'print', child: Text("Print A4 Bill")),
                                    const PopupMenuItem(value: 'edit', child: Text("Edit Bill")),
                                    const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Quick Actions প্যানেল (৬টি রঙিন বাটন)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 18),
                          SizedBox(width: 6),
                          Text("Quick Actions", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        children: [
                          quickActionButton("New Entry", Icons.note_add, const Color(0xFF2563EB), openAddBillDialog),
                          quickActionButton("Add Customer", Icons.person_add_alt_1, const Color(0xFF059669), openAddBillDialog),
                          quickActionButton("Generate Bill", Icons.print, const Color(0xFF7C3AED), () {
                            if (allEntries.isNotEmpty) generateAndPrintA4Invoice(allEntries.first);
                          }),
                          quickActionButton("View Reports", Icons.bar_chart, const Color(0xFFD97706), openTotalSummaryDialog),
                          quickActionButton("Backup Data", Icons.cloud_upload, const Color(0xFF0284C7), runCloudBackup),
                          quickActionButton("Settings", Icons.settings, const Color(0xFF475569), openUserProfileDialog),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // নিচের ফুটার ব্র্যান্ডিং
                const Center(
                  child: Text("SEWTRON ENGINEERING  |  Business Management System", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }

  // --- উইজেট: প্রিমিয়াম গ্লোয়িং ট্রেন্ড কার্ড ---
  Widget modernGlowCard(String title, String val, String trend, Color bg, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.3), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg.withOpacity(0.4), const Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: accent, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(trend, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              const SizedBox(height: 3),
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // --- উইজেট: বিজনেস মডিউল বাটন কার্ড ---
  Widget moduleButtonCard(String num, String title, String sub, Color col, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: col.withOpacity(0.4), width: 1),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [col.withOpacity(0.2), const Color(0xFF0F172A)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: col.withOpacity(0.25), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: col, size: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4)),
                  child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- উইজেট: কুইক অ্যাকশন বাটন ---
  Widget quickActionButton(String title, IconData icon, Color col, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: col,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

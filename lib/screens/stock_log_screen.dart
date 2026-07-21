import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kBlue, kBlueSoft, kLine;

class StockLogScreen extends StatefulWidget {
  const StockLogScreen({super.key});
  @override
  State<StockLogScreen> createState() => _StockLogScreenState();
}

class _StockLogScreenState extends State<StockLogScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('stock_log')
          .select('*, items(icon), by:by_user(full_name)')
          .order('created_at', ascending: false)
          .limit(200);
      if (mounted) {
        setState(() {
          rows = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String fmt(String? iso) {
    if (iso == null) return '';
    return DateFormat('dd.MM HH:mm').format(DateTime.parse(iso).toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.stockLog),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noStockLog,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final r = rows[i];
            final type = r['move_type'] as String;
            final by = r['by']?['full_name'];

            final (label, color, bg, sign) = switch (type) {
              'in' => (t.moveIn, kAccent, kAccentSoft, '+'),
              'out' => (t.moveOut, kAmber, kAmberSoft, '−'),
              'install' => (t.moveInstall, kBlue, kBlueSoft, '−'),
              'reserve' => (t.reserved, kBlue, kBlueSoft, ''),
              _ => (t.moveIn, kAccent, kAccentSoft, '+'),
            };

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kLine),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconFor(r['items']?['icon']),
                        color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['item_name'] ?? '—',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(
                          by != null
                              ? '$label · $by · ${fmt(r['created_at'])}'
                              : '$label · ${fmt(r['created_at'])}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text('$sign${r['qty']}',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
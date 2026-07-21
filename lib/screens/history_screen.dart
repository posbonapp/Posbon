import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import 'admin_tasks_screen.dart' show kAccent, kAccentSoft, kLine;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String? filterApt;
  List<Map<String, dynamic>> apartments = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final a = await supabase.from('apartments').select().order('number');
      var q = supabase
          .from('installations')
          .select('*, items(name, icon), apartments(number), worker:installed_by(full_name)');
      if (filterApt != null) q = q.eq('apartment_id', filterApt!);
      final data = await q.order('installed_at', ascending: false);
      if (mounted) {
        setState(() {
          apartments = List<Map<String, dynamic>>.from(a);
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
    final d = DateTime.parse(iso).toLocal();
    final diff = DateTime.now().difference(d).inDays;
    final date = DateFormat('dd.MM.yyyy').format(d);
    if (diff == 0) return date;
    return '$date · ${AppLocalizations.of(context)!.daysAgo(diff)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownButtonFormField<String?>(
              initialValue: filterApt,
              decoration: InputDecoration(
                labelText: t.apartment,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kLine),
                ),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(t.wholeBuilding)),
                ...apartments.map((a) => DropdownMenuItem(
                    value: a['id'] as String,
                    child: Text('${t.apartment} ${a['number']}'))),
              ],
              onChanged: (v) {
                setState(() => filterApt = v);
                load();
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty
                ? Center(
                child: Text(t.noHistory,
                    style: const TextStyle(color: Colors.grey)))
                : RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final r = rows[i];
                  final item = r['items'];
                  final apt = r['apartments']?['number'];
                  final worker = r['worker']?['full_name'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 11),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kLine),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kAccentSoft,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(iconFor(item?['icon']),
                              color: kAccent, size: 21),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                apt != null
                                    ? '${item?['name']} — ${t.apartment} $apt'
                                    : '${item?['name']}',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                worker != null
                                    ? '${t.installedBy} $worker · ${fmt(r['installed_at'])}'
                                    : fmt(r['installed_at']),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
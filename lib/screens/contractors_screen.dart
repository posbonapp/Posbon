import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'admin_tasks_screen.dart' show kAccent, kAccentSoft, kRed, kLine;

class ContractorsScreen extends StatefulWidget {
  const ContractorsScreen({super.key});
  @override
  State<ContractorsScreen> createState() => _ContractorsScreenState();
}

class _ContractorsScreenState extends State<ContractorsScreen> {
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
      final data =
      await supabase.from('contractors').select().order('name');
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

  Future<void> call(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.contractors),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noContractors,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final c = rows[i];
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kAccentSoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.engineering,
                        color: kAccent),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600)),
                        if ((c['specialty'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(c['specialty'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                        if ((c['phone'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(c['phone'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                  if ((c['phone'] ?? '').isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone, color: kAccent),
                      onPressed: () => call(c['phone']),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: kRed),
                    onPressed: () async {
                      await supabase
                          .from('contractors')
                          .delete()
                          .eq('id', c['id']);
                      load();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => const NewContractorDialog(),
          );
          if (ok == true) load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NewContractorDialog extends StatefulWidget {
  const NewContractorDialog({super.key});
  @override
  State<NewContractorDialog> createState() => _NewContractorDialogState();
}

class _NewContractorDialogState extends State<NewContractorDialog> {
  final name = TextEditingController();
  final specialty = TextEditingController();
  final phone = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    if (name.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final me = await supabase
          .from('profiles')
          .select('building_id')
          .eq('id', uid)
          .single();
      await supabase.from('contractors').insert({
        'building_id': me['building_id'],
        'name': name.text.trim(),
        'specialty': specialty.text.trim(),
        'phone': phone.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.newContractor),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: name,
              decoration: InputDecoration(labelText: t.contractorName)),
          const SizedBox(height: 12),
          TextField(
              controller: specialty,
              decoration: InputDecoration(labelText: t.specialty)),
          const SizedBox(height: 12),
          TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: t.phone)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: loading ? null : save,
          style: FilledButton.styleFrom(backgroundColor: kAccent),
          child: Text(t.create),
        ),
      ],
    );
  }
}
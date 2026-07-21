import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'admin_tasks_screen.dart' show kAccent, kAccentSoft, kLine;

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});
  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<Map<String, dynamic>> workers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final data = await supabase.from('profiles').select().eq('role', 'worker');
    if (mounted) {
      setState(() {
        workers = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.workers,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: .7,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 9),
          if (workers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('—', style: TextStyle(color: Colors.grey)),
            ),
          ...workers.map((w) => Container(
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kAccentSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      (w['full_name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                          color: kAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(w['full_name'] ?? '—',
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccent,
        onPressed: () async {
          final added = await showDialog<bool>(
            context: context,
            builder: (_) => const AddWorkerDialog(),
          );
          if (added == true) load();
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(t.addWorker, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class AddWorkerDialog extends StatefulWidget {
  const AddWorkerDialog({super.key});
  @override
  State<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<AddWorkerDialog> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> save() async {
    if (email.text.trim().isEmpty || password.text.length < 6) return;
    setState(() => loading = true);
    try {
      final res = await supabase.functions.invoke('create-user', body: {
        'email': email.text.trim(),
        'password': password.text,
        'full_name': name.text.trim(),
        'role': 'worker',
      });

      final data = res.data as Map<String, dynamic>;
      if (data['error'] != null) throw data['error'];

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
      title: Text(t.addWorker),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: name,
              decoration: InputDecoration(labelText: t.fullName)),
          const SizedBox(height: 12),
          TextField(
              controller: email,
              decoration: InputDecoration(labelText: t.email)),
          const SizedBox(height: 12),
          TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(labelText: t.password)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('✕')),
        FilledButton(
          onPressed: loading ? null : save,
          style: FilledButton.styleFrom(backgroundColor: kAccent),
          child: Text(t.create),
        ),
      ],
    );
  }
}
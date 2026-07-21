import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'worker_report_screen.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kRed, kRedSoft, kBlue, kBlueSoft, kLine;

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({super.key});
  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> myReports = [];
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
          .from('tasks')
          .select('*, apartments(number)')
          .order('created_at', ascending: false);
      final reports = await supabase
          .from('requests')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(data);
          myReports = List<Map<String, dynamic>>.from(reports);
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final todo = tasks.where((x) => x['status'] == 'new' || x['status'] == 'in_progress').toList();
    final review = tasks.where((x) => x['status'] == 'review').toList();
    final redo = tasks.where((x) => x['status'] == 'redo').toList();

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (redo.isNotEmpty) ...[
              _section(t.returned, redo.length),
              ...redo.map((x) => _card(x, t, tappable: true)),
            ],
            _section(t.toDo, todo.length),
            if (todo.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(t.noTasks,
                    style: const TextStyle(color: Colors.grey)),
              ),
            ...todo.map((x) => _card(x, t, tappable: true)),
            if (review.isNotEmpty) ...[
              _section(t.waitingReview, review.length),
              ...review.map((x) => _card(x, t)),
            ],
            if (myReports.isNotEmpty) ...[
              _section(t.myRequests, myReports.length),
              ...myReports.map((r) => _reportCard(r, t)),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _section(String label, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: .7,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: kAccentSoft, borderRadius: BorderRadius.circular(20)),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 10, color: kAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  Widget _reportCard(Map<String, dynamic> r, AppLocalizations t) {
    final status = r['status'] as String;
    final canEdit = status == 'new';
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  status == 'new'
                      ? t.requestNew
                      : status == 'done'
                      ? t.requestDone
                      : t.requestInProgress,
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'new'
                        ? kBlue
                        : status == 'done'
                        ? kAccent
                        : kAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: kAccent),
              onPressed: () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => WorkerReportScreen(request: r),
                  ),
                );

                if (ok == true) {
                  load();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: kRed),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(t.deleteTaskConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(t.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(backgroundColor: kRed),
                        child: Text(t.delete),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await supabase.from('requests').delete().eq('id', r['id']);
                  load();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> task, AppLocalizations t,
      {bool tappable = false}) {
    final apt = task['apartments']?['number'];
    final status = task['status'] as String;
    return GestureDetector(
      onTap: tappable
          ? () async {
        final done = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => DoTaskScreen(task: task)),
        );
        if (done == true) load();
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tag(apt != null ? '${t.apartment} $apt' : t.wholeBuilding,
                    apt != null ? kAccent : kBlue,
                    apt != null ? kAccentSoft : kBlueSoft),
                if (task['is_urgent'] == true) ...[
                  const SizedBox(width: 6),
                  _tag(t.urgent, kRed, kRedSoft),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: Text(task['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w600)),
                ),
                if (status == 'review')
                  _tag(t.waitingReview, kAmber, kAmberSoft),
              ],
            ),
            if (status == 'redo' && task['admin_comment'] != null) ...[
              const SizedBox(height: 8),
              Text(task['admin_comment'],
                  style: const TextStyle(fontSize: 12, color: kRed)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
  );
}

// ============ ЭКРАН ВЫПОЛНЕНИЯ ЗАДАЧИ ============
class DoTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const DoTaskScreen({super.key, required this.task});
  @override
  State<DoTaskScreen> createState() => _DoTaskScreenState();
}

class _DoTaskScreenState extends State<DoTaskScreen> {
  File? photo;
  bool loading = false;

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (img != null) setState(() => photo = File(img.path));
  }

  Future<void> submit() async {
    final t = AppLocalizations.of(context)!;
    if (photo == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.photoRequired)));
      return;
    }
    setState(() => loading = true);
    try {
      final buildingId = widget.task['building_id'];
      final taskId = widget.task['id'];
      final path =
          '$buildingId/tasks/$taskId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('photos').upload(path, photo!);

      await supabase.from('tasks').update({
        'status': 'review',
        'photo_url': path,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', taskId);

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
    final apt = widget.task['apartments']?['number'];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task['title'] ?? ''),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kLine),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apt != null ? '${t.apartment} $apt' : t.wholeBuilding,
                      style: const TextStyle(
                          fontSize: 12,
                          color: kAccent,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.task['title'] ?? '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if ((widget.task['description'] ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.task['description'],
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: takePhoto,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF101A19),
                  borderRadius: BorderRadius.circular(14),
                  image: photo != null
                      ? DecorationImage(
                      image: FileImage(photo!), fit: BoxFit.cover)
                      : null,
                ),
                child: photo == null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt,
                          color: Color(0xFF8FB0A8), size: 32),
                      const SizedBox(height: 8),
                      Text(t.takePhoto,
                          style: const TextStyle(
                              color: Color(0xFF8FB0A8), fontSize: 13)),
                    ],
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : submit,
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : Text(t.submitWork),
            ),
          ],
        ),
      ),
    );
  }
}
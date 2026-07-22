import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../locale_provider.dart';
import '../i18n_text.dart';
import '../theme.dart';
import 'worker_report_screen.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kRed, kRedSoft, kBlue, kBlueSoft;

class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({super.key});
  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> myReports = [];
  bool loading = true;
  int tab = 0; // 0 = Назначенные, 1 = История

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

  // Срочные — первыми, затем по времени (без времени — в конец).
  int _cmp(Map<String, dynamic> a, Map<String, dynamic> b) {
    final au = a['is_urgent'] == true, bu = b['is_urgent'] == true;
    if (au != bu) return au ? -1 : 1;
    final at = a['scheduled_time'] as String?, bt = b['scheduled_time'] as String?;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return at.compareTo(bt);
  }

  void _showMyRequests(AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: .7,
        maxChildSize: .9,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: palette(context).line,
                    borderRadius: BorderRadius.circular(4)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.myRequests,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: myReports.isEmpty
                    ? Center(
                        child: Text(t.noRequests,
                            style: TextStyle(color: palette(context).muted)))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: myReports.length,
                        itemBuilder: (_, i) =>
                            _reportCard(myReports[i], t, sheetContext),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final active = tasks.where((x) => x['status'] != 'done').toList()
      ..sort(_cmp);
    final history = tasks.where((x) => x['status'] == 'done').toList()
      ..sort((a, b) => (b['completed_at'] ?? b['created_at'] ?? '')
          .compareTo(a['completed_at'] ?? a['created_at'] ?? ''));
    final timed = active.where((x) => x['scheduled_time'] != null).toList();
    final untimed = active.where((x) => x['scheduled_time'] == null).toList();

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => _showMyRequests(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kBlueSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_outlined,
                                size: 16, color: kBlue),
                            const SizedBox(width: 6),
                            Text('${t.myRequests} (${myReports.length})',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: kBlue)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: palette(context).line,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _seg(t.assignedTab, 0),
                        _seg(t.historyTab, 1),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: load,
                    child: tab == 0
                        ? _assignedList(t, timed, untimed)
                        : _historyList(t, history),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _seg(String label, int i) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => tab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: tab == i ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tab == i ? Colors.white : palette(context).muted)),
        ),
      ),
    ),
  );

  Widget _assignedList(AppLocalizations t, List<Map<String, dynamic>> timed,
      List<Map<String, dynamic>> untimed) {
    if (timed.isEmpty && untimed.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
                child: Text(t.noTasks,
                    style: TextStyle(color: palette(context).muted))),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: [
        if (timed.isNotEmpty) ...[
          _groupLabel(t.today),
          for (int i = 0; i < timed.length; i++)
            _timelineRow(
              (timed[i]['scheduled_time'] as String).substring(0, 5),
              _taskCard(timed[i], t),
              isLast: i == timed.length - 1,
            ),
        ],
        if (untimed.isNotEmpty) ...[
          _groupLabel(t.noTimeGroup),
          for (int i = 0; i < untimed.length; i++)
            _timelineRow(
              '—',
              _taskCard(untimed[i], t),
              isLast: i == untimed.length - 1,
            ),
        ],
      ],
    );
  }

  Widget _historyList(AppLocalizations t, List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
                child: Text(t.noTasks,
                    style: TextStyle(color: palette(context).muted))),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: history.length,
      itemBuilder: (_, i) => _taskCard(history[i], t, margin: true),
    );
  }

  Widget _groupLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
    child: Text(label.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            letterSpacing: .7,
            fontWeight: FontWeight.bold,
            color: palette(context).muted)),
  );

  Widget _timelineRow(String time, Widget card, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(time,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: palette(context).muted)),
            ),
          ),
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 9),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: kBlue),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: palette(context).line),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> task, AppLocalizations t,
      {bool margin = false}) {
    final apt = task['apartments']?['number'];
    final status = task['status'] as String;
    final urgent = task['is_urgent'] == true;
    final done = status == 'done';
    final (statusLabel, statusColor, statusBg) = done
        ? (t.statusDone, kAccent, kAccentSoft)
        : status == 'new'
            ? (t.statusAssigned, kBlue, kBlueSoft)
            : (t.statusInProgress, kAmber, kAmberSoft);

    return GestureDetector(
      onTap: status == 'review'
          ? null
          : () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => DoTaskScreen(task: task)),
              );
              if (result == true) load();
            },
      child: Container(
        margin: margin ? const EdgeInsets.only(bottom: 11) : null,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette(context).card,
          border: Border.all(
              color: urgent ? kRed.withValues(alpha: .5) : palette(context).line,
              width: urgent ? 1.4 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                      pickTranslated(task['title_i18n'], task['title'] ?? '',
                          localeProvider.effectiveCode),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(apt != null ? '${t.apartment} $apt' : t.wholeBuilding,
                    style:
                        TextStyle(fontSize: 12.5, color: palette(context).muted)),
                if (urgent) ...[
                  const SizedBox(width: 8),
                  _tag(t.urgent, kRed, kRedSoft),
                ],
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

  Widget _reportCard(
      Map<String, dynamic> r, AppLocalizations t, BuildContext sheetContext) {
    final status = r['status'] as String;
    final canEdit = status == 'new';
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(sheetContext).scaffoldBackgroundColor,
        border: Border.all(color: palette(context).line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    pickTranslated(r['title_i18n'], r['title'] ?? '',
                        localeProvider.effectiveCode),
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
                Navigator.pop(sheetContext);
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => WorkerReportScreen(request: r),
                  ),
                );
                if (ok == true) load();
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
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  load();
                }
              },
            ),
          ],
        ],
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
    final locale = localeProvider.effectiveCode;
    final title = pickTranslated(
        widget.task['title_i18n'], widget.task['title'] ?? '', locale);
    final description = pickTranslated(widget.task['description_i18n'],
        widget.task['description'] ?? '', locale);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                color: palette(context).card,
                border: Border.all(color: palette(context).line),
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(description,
                        style: TextStyle(color: palette(context).muted)),
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
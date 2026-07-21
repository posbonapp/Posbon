import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../icons.dart';

const kAccent = Color(0xFF2F7D6B);
const kAccentSoft = Color(0xFFE6F0EC);
const kAmber = Color(0xFFC1892F);
const kAmberSoft = Color(0xFFF6ECD6);
const kRed = Color(0xFFC05A4D);
const kRedSoft = Color(0xFFF6E1DD);
const kBlue = Color(0xFF3A6B8F);
const kBlueSoft = Color(0xFFE1ECF3);
const kLine = Color(0xFFE6E1D6);

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({super.key});
  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  List<Map<String, dynamic>> tasks = [];
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
          .select('*, apartments(number), assigned:assigned_to(full_name)')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(data);
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

  Color statusColor(String s) => switch (s) {
    'review' => kAmber,
    'done' => kAccent,
    'redo' => kRed,
    _ => kBlue,
  };

  Color statusBg(String s) => switch (s) {
    'review' => kAmberSoft,
    'done' => kAccentSoft,
    'redo' => kRedSoft,
    _ => kBlueSoft,
  };

  String statusLabel(AppLocalizations t, String s) => switch (s) {
    'review' => t.statusReview,
    'done' => t.statusDone,
    'redo' => t.statusRedo,
    _ => t.statusNew,
  };

  String fmtDate(String? iso) {
    if (iso == null) return '';
    return DateFormat('dd.MM HH:mm').format(DateTime.parse(iso).toLocal());
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    try {
      if (task['item_id'] != null && task['status'] != 'done') {
        await supabase.rpc('release_item', params: {
          'p_item_id': task['item_id'],
          'p_building_id': task['building_id'],
        });
      }
      await supabase.from('tasks').delete().eq('id', task['id']);
      load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void showTaskMenu(Map<String, dynamic> task) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kAccent),
              title: Text(t.edit),
              onTap: () async {
                Navigator.pop(context);
                final saved = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => NewTaskScreen(task: task)),
                );
                if (saved == true) load();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: kRed),
              title: Text(t.delete, style: const TextStyle(color: kRed)),
              onTap: () async {
                Navigator.pop(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(t.deleteTaskConfirm),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(t.cancel)),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(backgroundColor: kRed),
                        child: Text(t.delete),
                      ),
                    ],
                  ),
                );
                if (ok == true) deleteTask(task);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(
          child: Text(t.noTasks,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, i) {
            final task = tasks[i];
            final status = task['status'] as String;
            final apt = task['apartments']?['number'];
            final worker = task['assigned']?['full_name'];
            return GestureDetector(
              onTap: status == 'review'
                  ? () async {
                final done = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => ReviewTaskScreen(task: task)),
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
                      _tag(
                        apt != null ? '${t.apartment} $apt' : t.wholeBuilding,
                        apt != null ? kAccent : kBlue,
                        apt != null ? kAccentSoft : kBlueSoft,
                      ),
                      if (task['is_urgent'] == true) ...[
                        const SizedBox(width: 6),
                        _tag(t.urgent, kRed, kRedSoft),
                      ],
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(task['title'] ?? '',
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600)),
                      ),
                      _badge(statusLabel(t, status),
                          statusColor(status), statusBg(status)),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () => showTaskMenu(task),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (worker != null)
                        Text(worker,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      Text('${t.created} ${fmtDate(task['created_at'])}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      if (task['completed_at'] != null)
                        Text('${t.submitted} ${fmtDate(task['completed_at'])}',
                            style: const TextStyle(
                                fontSize: 12, color: kAmber)),
                      if (task['accepted_at'] != null)
                        Text('${t.accepted} ${fmtDate(task['accepted_at'])}',
                            style: const TextStyle(
                                fontSize: 12, color: kAccent)),
                    ],
                  ),
                ],
              ),
             ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewTaskScreen()),
          );
          if (created == true) load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _tag(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
  );

  Widget _badge(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
  );
}

// ============ СОЗДАНИЕ ЗАДАЧИ ============
class NewTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;
  final String? presetApartmentId;
  final String? presetTitle;
  final String? requestId;
  const NewTaskScreen({
    super.key,
    this.task,
    this.presetApartmentId,
    this.presetTitle,
    this.requestId,
  });
  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  List<Map<String, dynamic>> workers = [];
  List<Map<String, dynamic>> apartments = [];
  List<Map<String, dynamic>> items = [];
  String? itemId;
  String? workerId;
  String? apartmentId;
  bool urgent = false;
  bool loading = false;

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      title.text = widget.task!['title'] ?? '';
      desc.text = widget.task!['description'] ?? '';
      workerId = widget.task!['assigned_to'];
      apartmentId = widget.task!['apartment_id'];
      itemId = widget.task!['item_id'];
      urgent = widget.task!['is_urgent'] ?? false;
    } else {
      apartmentId = widget.presetApartmentId;
      if (widget.presetTitle != null) title.text = widget.presetTitle!;
    }
    loadData();
  }

  Future<void> loadData() async {
    final w = await supabase.from('profiles').select().eq('role', 'worker');
    final a = await supabase.from('apartments').select().order('number');
    final it = await supabase
        .from('items')
        .select('*, stock(qty_available)')
        .order('name');
    if (mounted) {
      setState(() {
        workers = List<Map<String, dynamic>>.from(w);
        apartments = List<Map<String, dynamic>>.from(a);
        items = List<Map<String, dynamic>>.from(it);
      });
    }
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final oldItemId = isEdit ? widget.task!['item_id'] : null;

      final data = {
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'scope': apartmentId != null ? 'apartment' : 'building',
        'apartment_id': apartmentId,
        'assigned_to': workerId,
        'item_id': itemId,
        'is_urgent': urgent,
      };

      if (isEdit) {
        final buildingId = widget.task!['building_id'];
        await supabase.from('tasks').update(data).eq('id', widget.task!['id']);
        // товар изменился — вернуть старый, зарезервировать новый
        if (oldItemId != itemId) {
          if (oldItemId != null) {
            await supabase.rpc('release_item',
                params: {'p_item_id': oldItemId, 'p_building_id': buildingId});
          }
          if (itemId != null) {
            await supabase.rpc('reserve_item',
                params: {'p_item_id': itemId, 'p_building_id': buildingId});
          }
        }
      } else {
        final me = await supabase
            .from('profiles')
            .select('building_id')
            .eq('id', uid)
            .single();
        final newTask = await supabase.from('tasks').insert({
          ...data,
          'building_id': me['building_id'],
          'created_by': uid,
          'status': 'new',
        }).select().single();

        if (widget.requestId != null) {
          await supabase
              .from('requests')
              .update({'task_id': newTask['id']}).eq('id', widget.requestId!);
        }

        if (itemId != null) {
          await supabase.rpc('reserve_item', params: {
            'p_item_id': itemId,
            'p_building_id': me['building_id'],
          });
        }
        if (itemId != null) {
          await supabase.rpc('reserve_item', params: {
            'p_item_id': itemId,
            'p_building_id': me['building_id'],
          });
        }
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? t.edit : t.newTask),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: t.taskTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: desc,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.description),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: workerId,
              decoration: InputDecoration(labelText: t.assignTo),
              items: workers
                  .map((w) => DropdownMenuItem(
                  value: w['id'] as String,
                  child: Text(w['full_name'] ?? '—')))
                  .toList(),
              onChanged: (v) => setState(() => workerId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: apartmentId,
              decoration: InputDecoration(labelText: t.apartment),
              items: [
                DropdownMenuItem(value: null, child: Text(t.wholeBuilding)),
                ...apartments.map((a) => DropdownMenuItem(
                    value: a['id'] as String,
                    child: Text('${t.apartment} ${a['number']}'))),
              ],
              onChanged: (v) => setState(() => apartmentId = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: itemId,
              decoration: InputDecoration(labelText: t.linkItem),
              items: [
                DropdownMenuItem(value: null, child: Text(t.none)),
                ...items.map((it) {
                  final avail =
                      (it['stock'] as List?)?.firstOrNull?['qty_available'] ?? 0;
                  return DropdownMenuItem(
                    value: it['id'] as String,
                    child: Row(
                      children: [
                        Icon(iconFor(it['icon']), size: 18, color: kAccent),
                        const SizedBox(width: 8),
                        Text('${it['name']} ($avail)'),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (v) => setState(() => itemId = v),
            ),
            SwitchListTile(
              title: Text(t.urgent),
              value: urgent,
              activeThumbColor: kAccent,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => urgent = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : save,
              style: FilledButton.styleFrom(backgroundColor: kAccent),
              child: loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? t.save : t.create),
            ),
          ],
        ),
      ),
    );
  }
}
// ============ ЭКРАН ПРИЁМКИ ============
class ReviewTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const ReviewTaskScreen({super.key, required this.task});
  @override
  State<ReviewTaskScreen> createState() => _ReviewTaskScreenState();
}

class _ReviewTaskScreenState extends State<ReviewTaskScreen> {
  String? photoUrl;
  bool loading = false;
  final comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPhoto();
  }

  Future<void> loadPhoto() async {
    final path = widget.task['photo_url'];
    if (path == null) return;
    try {
      final url = await supabase.storage
          .from('photos')
          .createSignedUrl(path, 3600);
      if (mounted) setState(() => photoUrl = url);
    } catch (e) {
      debugPrint('photo error: $e');
    }
  }

  Future<void> decide(String status) async {
    setState(() => loading = true);
    try {
      if (status == 'done') {
        await supabase.rpc('accept_task',
            params: {'p_task_id': widget.task['id']});
      } else {
        await supabase.from('tasks').update({
          'status': 'redo',
          'admin_comment': comment.text.trim(),
        }).eq('id', widget.task['id']);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t.review),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.task['title'] ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(photoUrl!,
                    height: 260, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E1D6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: comment,
              decoration: InputDecoration(labelText: t.adminComment),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: loading ? null : () => decide('redo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kRedSoft,
                      foregroundColor: kRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(t.redo),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: loading ? null : () => decide('done'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(t.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'admin_tasks_screen.dart' show kAccent;

class WorkerReportScreen extends StatefulWidget {
  final Map<String, dynamic>? request;
  const WorkerReportScreen({super.key, this.request});
  @override
  State<WorkerReportScreen> createState() => _WorkerReportScreenState();
}

class _WorkerReportScreenState extends State<WorkerReportScreen> {
  final title = TextEditingController();
  final location = TextEditingController();
  final desc = TextEditingController();
  File? photo;
  bool loading = false;

  bool get isEdit => widget.request != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      // заголовок мог быть "текст · место" — разберём обратно
      final full = widget.request!['title'] ?? '';
      if (full.contains(' · ')) {
        final parts = full.split(' · ');
        title.text = parts.first;
        location.text = parts.sublist(1).join(' · ');
      } else {
        title.text = full;
      }
      desc.text = widget.request!['description'] ?? '';
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 70, maxWidth: 1600);
    if (img != null) setState(() => photo = File(img.path));
  }

  Future<void> send() async {
    if (title.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final loc = location.text.trim();
      final fullTitle =
      loc.isEmpty ? title.text.trim() : '${title.text.trim()} · $loc';

      if (isEdit) {
        await supabase.from('requests').update({
          'title': fullTitle,
          'description': desc.text.trim(),
        }).eq('id', widget.request!['id']);
      } else {
        final me = await supabase
            .from('profiles')
            .select('building_id')
            .eq('id', uid)
            .single();
        final buildingId = me['building_id'];
        String? path;
        if (photo != null) {
          path =
          '$buildingId/requests/${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase.storage.from('photos').upload(path, photo!);
        }
        await supabase.from('requests').insert({
          'building_id': buildingId,
          'apartment_id': null,
          'created_by': uid,
          'title': fullTitle,
          'description': desc.text.trim(),
          'photo_url': path,
          'status': 'new',
        });
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
        title: Text(isEdit ? t.edit : t.reportProblem),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: t.whatHappened),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: location,
              decoration: InputDecoration(labelText: t.problemLocation),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: desc,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.description),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: takePhoto,
              child: Container(
                height: 180,
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
                          color: Color(0xFF8FB0A8), size: 30),
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
              onPressed: loading ? null : send,
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
                  : Text(t.sendRequest),
            ),
          ],
        ),
      ),
    );
  }
}
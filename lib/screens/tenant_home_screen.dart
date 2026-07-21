import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import '../locale_provider.dart';
import '../i18n_text.dart';
import 'settings_screen.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kBlue, kBlueSoft, kLine;

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});
  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  Map<String, dynamic>? apartment;
  Map<String, dynamic>? building;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final apt = await supabase
          .from('apartments')
          .select()
          .eq('tenant_id', uid)
          .maybeSingle();
      final b = await supabase.from('buildings').select().limit(1).maybeSingle();
      final r = await supabase
          .from('requests')
          .select()
          .order('created_at', ascending: false);
      final h = await supabase
          .from('installations')
          .select('*, items(name, icon), worker:installed_by(full_name)')
          .order('installed_at', ascending: false);
      if (mounted) {
        setState(() {
          apartment = apt;
          building = b;
          requests = List<Map<String, dynamic>>.from(r);
          history = List<Map<String, dynamic>>.from(h);
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
    return DateFormat('dd.MM.yyyy').format(DateTime.parse(iso).toLocal());
  }

  Future<void> callDispatcher() async {
    final phone = building?['dispatcher_phone'];
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noPhone)),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.apartment} ${apartment?['number'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            Text(building?['address'] ?? '',
                style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Кнопка звонка
            GestureDetector(
              onTap: callDispatcher,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone, color: Colors.white),
                    ),
                    const SizedBox(width: 13),
                    Text(t.callDispatcher,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            _section(t.myRequests),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.noRequests,
                    style: const TextStyle(color: Colors.grey)),
              ),
            ...requests.map((r) => _requestCard(r, t)),

            _section(t.myHistory),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.noHistory,
                    style: const TextStyle(color: Colors.grey)),
              ),
            ...history.map((h) => _historyCard(h, t)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccent,
        onPressed: () async {
          if (apartment == null) return;
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
                builder: (_) => NewRequestScreen(apartment: apartment!)),
          );
          if (ok == true) load();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(t.newRequest, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
    child: Text(label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            letterSpacing: .7,
            fontWeight: FontWeight.bold,
            color: Colors.grey)),
  );

  Widget _requestCard(Map<String, dynamic> r, AppLocalizations t) {
    final status = r['status'] as String;
    final (label, fg, bg) = switch (status) {
      'done' => (t.requestDone, kAccent, kAccentSoft),
      'in_progress' => (t.requestInProgress, kAmber, kAmberSoft),
      _ => (t.requestNew, kBlue, kBlueSoft),
    };
    return Container(
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
            children: [
              Expanded(
                child: Text(
                    pickTranslated(r['title_i18n'], r['title'] ?? '',
                        localeProvider.effectiveCode),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(20)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: fg)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(fmt(r['created_at']),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (status == 'done' && r['rating'] == null) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                    (i) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34),
                  iconSize: 22,
                  icon: Icon(Icons.star_border, color: kAmber),
                  onPressed: () async {
                    await supabase
                        .from('requests')
                        .update({'rating': i + 1}).eq('id', r['id']);
                    load();
                  },
                ),
              ),
            ),
          ],
          if (r['rating'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < r['rating'] ? Icons.star : Icons.star_border,
                  size: 18,
                  color: kAmber,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> h, AppLocalizations t) {
    final item = h['items'];
    final worker = h['worker']?['full_name'];
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kAccentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconFor(item?['icon']), color: kAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item?['name'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  worker != null
                      ? '${t.installedBy} $worker · ${fmt(h['installed_at'])}'
                      : fmt(h['installed_at']),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ НОВАЯ ЗАЯВКА ============
class NewRequestScreen extends StatefulWidget {
  final Map<String, dynamic> apartment;
  const NewRequestScreen({super.key, required this.apartment});
  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  File? photo;
  bool loading = false;

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
      final buildingId = widget.apartment['building_id'];
      String? path;

      if (photo != null) {
        path =
        '$buildingId/requests/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('photos').upload(path, photo!);
      }

      await supabase.from('requests').insert({
        'building_id': buildingId,
        'apartment_id': widget.apartment['id'],
        'created_by': uid,
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'photo_url': path,
        'status': 'new',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t.newRequest),
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
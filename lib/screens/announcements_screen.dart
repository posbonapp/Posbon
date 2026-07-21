import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../locale_provider.dart';
import '../i18n_text.dart';
import 'admin_tasks_screen.dart' show kAccent, kLine;

class AnnouncementsScreen extends StatefulWidget {
  final bool isAdmin;
  const AnnouncementsScreen({super.key, required this.isAdmin});
  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
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
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
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
    return DateFormat('dd.MM.yyyy · HH:mm')
        .format(DateTime.parse(iso).toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noAnnouncements,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final a = rows[i];
            final locale = localeProvider.effectiveCode;
            final title = pickTranslated(a['title_i18n'], a['title'] ?? '', locale);
            final body = pickTranslated(a['body_i18n'], a['body'] ?? '', locale);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF14211F), Color(0xFF20302D)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.fromManager.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: .6,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8FB3A8))),
                      if (widget.isAdmin)
                        GestureDetector(
                          onTap: () async {
                            await supabase
                                .from('announcements')
                                .delete()
                                .eq('id', a['id']);
                            load();
                          },
                          child: const Icon(Icons.delete_outline,
                              size: 18, color: Color(0xFF8FB3A8)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEAF0EE))),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(body,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFFBCCBC6))),
                  ],
                  const SizedBox(height: 10),
                  Text(fmt(a['created_at']),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6E827D))),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: kAccent,
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewAnnouncementScreen()),
          );
          if (ok == true) load();
        },
        icon: const Icon(Icons.campaign_outlined, color: Colors.white),
        label: Text(t.newAnnouncement,
            style: const TextStyle(color: Colors.white)),
      )
          : null,
    );
  }
}

// ============ НОВОЕ ОБЪЯВЛЕНИЕ ============
class NewAnnouncementScreen extends StatefulWidget {
  const NewAnnouncementScreen({super.key});
  @override
  State<NewAnnouncementScreen> createState() => _NewAnnouncementScreenState();
}

class _NewAnnouncementScreenState extends State<NewAnnouncementScreen> {
  final title = TextEditingController();
  final body = TextEditingController();
  bool loading = false;

  Future<void> publish() async {
    if (title.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final me = await supabase
          .from('profiles')
          .select('building_id')
          .eq('id', uid)
          .single();
      final buildingId = me['building_id'];
      await supabase.from('announcements').insert({
        'building_id': buildingId,
        'title': title.text.trim(),
        'body': body.text.trim(),
        'created_by': uid,
      });
      // Push отправляется DB-триггером trg_new_announcement -> notify-announcement
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
        title: Text(t.newAnnouncement),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: t.announcementTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: body,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: t.announcementBody,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : publish,
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
                  : Text(t.publish),
            ),
          ],
        ),
      ),
    );
  }
}
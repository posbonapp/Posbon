import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import '../locale_provider.dart';
import '../i18n_text.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kBlue, kBlueSoft, NewTaskScreen;

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});
  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
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
          .from('requests')
          .select('*, apartments(id, number), tasks(title, status)')
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
    return DateFormat('dd.MM HH:mm').format(DateTime.parse(iso).toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noRequests,
              style: TextStyle(color: palette(context).muted)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final r = rows[i];
            final status = r['status'] as String;
            final apt = r['apartments']?['number'];
            final (label, fg, bg) = switch (status) {
              'done' => (t.requestDone, kAccent, kAccentSoft),
              'in_progress' => (t.requestInProgress, kAmber, kAmberSoft),
              _ => (t.requestNew, kBlue, kBlueSoft),
            };
            return GestureDetector(
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(request: r)),
                );
                if (changed == true) load();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: palette(context).card,
                  border: Border.all(color: palette(context).line),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: kAccentSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                              apt != null ? '${t.apartment} $apt' : t.generalIssue,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: kAccent)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              pickTranslated(r['title_i18n'], r['title'] ?? '',
                                  localeProvider.effectiveCode),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (r['photo_url'] != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.photo_camera_outlined,
                                size: 16, color: palette(context).muted),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: fg)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text(fmt(r['created_at']),
                            style: TextStyle(
                                fontSize: 12, color: palette(context).muted)),
                        if (r['tasks'] != null)
                          Text('→ ${r['tasks']['title']}',
                              style: const TextStyle(
                                  fontSize: 12, color: kAccent)),
                        if (r['rating'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              r['rating'],
                                  (_) => const Icon(Icons.star,
                                  size: 12, color: kAmber),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============ ДЕТАЛИ ЗАЯВКИ ============
class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const RequestDetailScreen({super.key, required this.request});
  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  String? photoUrl;
  List<Map<String, dynamic>> history = [];
  bool loading = true;
  String? contractorName;
  bool showOriginal = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final path = widget.request['photo_url'];
      if (path != null) {
        photoUrl =
        await supabase.storage.from('photos').createSignedUrl(path, 3600);
      }
      final aptId = widget.request['apartment_id'];
      final h = await supabase
          .from('installations')
          .select('*, items(name, icon), worker:installed_by(full_name)')
          .eq('apartment_id', aptId)
          .order('installed_at', ascending: false);
      if (widget.request['contractor_id'] != null) {
        final c = await supabase
            .from('contractors')
            .select('name')
            .eq('id', widget.request['contractor_id'])
            .maybeSingle();
        contractorName = c?['name'];
      }
      if (mounted) {
        setState(() {
          history = List<Map<String, dynamic>>.from(h);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  String ago(String? iso) {
    if (iso == null) return '';
    final d = DateTime.parse(iso).toLocal();
    final days = DateTime.now().difference(d).inDays;
    final date = DateFormat('dd.MM.yyyy').format(d);
    if (days == 0) return date;
    return '$date · ${AppLocalizations.of(context)!.daysAgo(days)}';
  }

  Future<void> pickContractor() async {
    final list = await supabase.from('contractors').select().order('name');
    final contractors = List<Map<String, dynamic>>.from(list);
    if (!mounted) return;

    if (contractors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noContractors)),
      );
      return;
    }

    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(t.selectContractor,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...contractors.map((c) => ListTile(
              leading: const Icon(Icons.engineering, color: kAccent),
              title: Text(c['name'] ?? ''),
              subtitle: Text(c['specialty'] ?? ''),
              trailing: const Icon(Icons.phone, color: kAccent),
              onTap: () async {
                Navigator.pop(context);
                // помечаем заявку
                await supabase.from('requests').update({
                  'contractor_id': c['id'],
                  'status': 'in_progress',
                }).eq('id', widget.request['id']);
                // звоним
                final phone = c['phone'];
                if (phone != null && phone.toString().isNotEmpty) {
                  try {
                    await launchUrl(Uri.parse('tel:$phone'));
                  } catch (_) {}
                }
                if (mounted) Navigator.pop(context, true);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> setStatus(String status) async {
    await supabase
        .from('requests')
        .update({'status': status}).eq('id', widget.request['id']);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final apt = widget.request['apartments']?['number'];
    final viewerLocale = localeProvider.effectiveCode;
    final originalLocale = widget.request['original_locale'] as String?;
    final canToggle = hasTranslationFor(originalLocale, viewerLocale);
    final useOriginal = showOriginal || !canToggle;
    final String title = useOriginal
        ? (widget.request['title'] ?? '') as String
        : pickTranslated(widget.request['title_i18n'],
            widget.request['title'] ?? '', viewerLocale);
    final String description = useOriginal
        ? (widget.request['description'] ?? '') as String
        : pickTranslated(widget.request['description_i18n'],
            widget.request['description'] ?? '', viewerLocale);
    return Scaffold(
      appBar: AppBar(
        title: Text('${t.requestDetails} · ${t.apartment} $apt'),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                style: TextStyle(color: palette(context).muted)),
          ],
          if (canToggle) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => showOriginal = !showOriginal),
              icon: const Icon(Icons.translate, size: 18),
              label: Text(showOriginal ? t.showTranslation : t.showOriginal),
            ),
          ],
          if (photoUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(photoUrl!,
                  height: 240, width: double.infinity, fit: BoxFit.cover),
            ),
          ],

          // ФИШКА: история квартиры прямо здесь
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAmberSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECDCB8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: kAmber),
                    const SizedBox(width: 6),
                    Text('${t.myHistory} $apt'.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: kAmber)),
                  ],
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Text(t.noHistory,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6D5A34)))
                else
                  ...history.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(iconFor(h['items']?['icon']),
                            size: 18, color: const Color(0xFF6D5A34)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(h['items']?['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A3D1F))),
                              Text(
                                '${t.installedBy} ${h['worker']?['full_name'] ?? '—'} · ${ago(h['installed_at'])}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6D5A34)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Если уже передано подрядчику — показываем это
          if (widget.request['contractor_id'] != null &&
              contractorName != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBlueSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering, color: kBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${t.handedToContractor}: $contractorName',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kBlue)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 1. Поручить консьержу
          FilledButton.icon(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => NewTaskScreen(
                    presetApartmentId: widget.request['apartment_id'],
                    presetTitle: widget.request['title'],
                    requestId: widget.request['id'],
                  ),
                ),
              );
              if (created == true && mounted) {
                await setStatus('in_progress');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.person_outline, color: Colors.white),
            label: Text(t.assignToWorker),
          ),
          const SizedBox(height: 10),

          // 2. Вызвать мастера
          FilledButton.icon(
            onPressed: pickContractor,
            style: FilledButton.styleFrom(
              backgroundColor: kBlueSoft,
              foregroundColor: kBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.engineering_outlined),
            label: Text(t.callContractor),
          ),
          const SizedBox(height: 10),

          // 3. Закрыть
          FilledButton(
            onPressed: () => setStatus('done'),
            style: FilledButton.styleFrom(
              backgroundColor: kAccentSoft,
              foregroundColor: kAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(t.closeRequest),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../main.dart';
import '../locale_provider.dart';
import '../notifications.dart';
import '../l10n/app_localizations.dart';
import 'contractors_screen.dart';
import 'purchase_screen.dart';
import 'stock_log_screen.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kRed, kRedSoft, kLine;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? profile;
  Map<String, dynamic>? building;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final p = await supabase.from('profiles').select().eq('id', uid).maybeSingle();
      Map<String, dynamic>? b;
      if (p?['role'] == 'admin') {
        b = await supabase.from('buildings').select().limit(1).maybeSingle();
      }
      if (mounted) {
        setState(() {
          profile = p;
          building = b;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isAdmin = profile?['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          _section(t.profile),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDeco(),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      (profile?['full_name'] ?? '?')
                          .toString()
                          .characters
                          .first
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?['full_name'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        supabase.auth.currentUser?.email ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Язык
          _section(t.language),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDeco(),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _lang(t.systemLanguage, null),
                _lang('English', const Locale('en')),
                _lang('Русский', const Locale('ru')),
                _lang('Français', const Locale('fr')),
              ],
            ),
          ),

          // Настройки дома — только админ
          if (isAdmin) ...[
            _section(t.buildingSettings),
            Container(
              decoration: _cardDeco(),
              child: Column(
                children: [
                  _tile(
                    Icons.phone_outlined,
                    t.dispatcherPhone,
                    building?['dispatcher_phone'] ?? '—',
                        () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => PhoneDialog(
                            current: building?['dispatcher_phone'],
                            buildingId: building?['id']),
                      );
                      if (ok == true) load();
                    },
                  ),
                  const Divider(height: 1, color: kLine),
                  _tile(
                    Icons.apartment_outlined,
                    t.structure,
                    '${building?['entrances'] ?? 0} · ${building?['floors'] ?? 0}',
                    null,
                  ),
                  const Divider(height: 1, color: kLine),
                  _tile(
                    Icons.engineering_outlined,
                    t.contractors,
                    '',
                        () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ContractorsScreen()),
                    ),
                  ),
                  const Divider(height: 1, color: kLine),
                  _tile(
                    Icons.receipt_long_outlined,
                    t.stockLog,
                    '',
                        () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const StockLogScreen()),
                    ),
                  ),
                  const Divider(height: 1, color: kLine),
                  _tile(
                    Icons.shopping_cart_outlined,
                    t.purchaseRequests,
                    '',
                        () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                          const PurchaseScreen(isAdmin: true)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ВРЕМЕННАЯ КНОПКА — тест пуша
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final tokens = await supabase
                  .from('device_tokens')
                  .select('token');
              final list = (tokens as List)
                  .map((e) => e['token'] as String)
                  .toList();
              final res = await supabase.functions.invoke('send-push',
                  body: {
                    'tokens': list,
                    'title': 'Posbon',
                    'body': 'Тест уведомления',
                  });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Отправлено: ${res.data}')),
                );
              }
            },
            child: const Text('ТЕСТ ПУША'),
          ),

          // Выход
          const SizedBox(height: 24),
          Container(
            decoration: _cardDeco(),
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kRedSoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.logout, size: 18, color: kRed),
              ),
              title: Text(t.signOut,
                  style: const TextStyle(
                      color: kRed, fontWeight: FontWeight.w600)),
              onTap: () async {
                await Notifications.removeToken();
                await supabase.auth.signOut();
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: kLine),
    borderRadius: BorderRadius.circular(18),
  );

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
    child: Text(label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            letterSpacing: .7,
            fontWeight: FontWeight.bold,
            color: Colors.grey)),
  );

  Widget _lang(String label, Locale? locale) {
    final selected = localeProvider.locale?.languageCode == locale?.languageCode;
    return GestureDetector(
      onTap: () async {
        await localeProvider.set(locale);
        // синхронизируем язык на сервере, чтобы пуши приходили на нём
        Notifications.syncToken();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kAccent : Colors.white,
          border: Border.all(color: selected ? kAccent : kLine),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value, VoidCallback? onTap) =>
      ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kAccentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: kAccent),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w600)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: onTap,
      );
}

// ============ ТЕЛЕФОН ДИСПЕТЧЕРА ============
class PhoneDialog extends StatefulWidget {
  final String? current;
  final String? buildingId;
  const PhoneDialog({super.key, this.current, this.buildingId});
  @override
  State<PhoneDialog> createState() => _PhoneDialogState();
}

class _PhoneDialogState extends State<PhoneDialog> {
  late final phone = TextEditingController(text: widget.current ?? '');
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);
    try {
      await supabase
          .from('buildings')
          .update({'dispatcher_phone': phone.text.trim()}).eq(
          'id', widget.buildingId!);
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
      title: Text(t.dispatcherPhone),
      content: TextField(
        controller: phone,
        keyboardType: TextInputType.phone,
        autofocus: true,
        decoration: InputDecoration(labelText: t.phone),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: loading ? null : save,
          style: FilledButton.styleFrom(backgroundColor: kAccent),
          child: Text(t.save),
        ),
      ],
    );
  }
}
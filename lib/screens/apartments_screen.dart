import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'tenant_card.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'admin_tasks_screen.dart' show kAccent, kAccentSoft, kAmber, kAmberSoft;

/// Генератор пароля: Kv38-7f2a
String genPassword(String aptNumber) {
  const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
  final r = Random.secure();
  final tail = List.generate(4, (_) => chars[r.nextInt(chars.length)]).join();
  return 'Kv$aptNumber-$tail';
}

/// Фиктивная почта квартиры: kv38.sm2@posbon.app
String genEmail(String aptNumber, String buildingCode) {
  final code = buildingCode
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .padRight(2, 'x');
  return 'kv$aptNumber.$code@posbon.app';
}

class ApartmentsScreen extends StatefulWidget {
  const ApartmentsScreen({super.key});
  @override
  State<ApartmentsScreen> createState() => _ApartmentsScreenState();
}

class _ApartmentsScreenState extends State<ApartmentsScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String buildingName = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final b = await supabase.from('buildings').select().limit(1).maybeSingle();
      final data = await supabase
          .from('apartments')
          .select('*, tenant:tenant_id(full_name)')
          .order('number');
      if (mounted) {
        setState(() {
          buildingName = b?['name'] ?? '';
          rows = List<Map<String, dynamic>>.from(data);
          rows.sort((a, b) => (int.tryParse(a['number'] ?? '0') ?? 0)
              .compareTo(int.tryParse(b['number'] ?? '0') ?? 0));
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
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: load,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final apt = rows[i];
            final hasTenant = apt['tenant_id'] != null;
            return GestureDetector(
              onTap: () => openApartment(apt),
              child: Container(
                decoration: BoxDecoration(
                  color: hasTenant ? kAccent : palette(context).card,
                  border: Border.all(
                      color: hasTenant ? kAccent : palette(context).line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(apt['number'] ?? '',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: hasTenant
                                ? Colors.white
                                : null)),
                    const SizedBox(height: 3),
                    Text(
                      hasTenant
                          ? (apt['tenant']?['full_name'] ?? t.tenant)
                          : t.noTenant,
                      style: TextStyle(
                          fontSize: 10.5,
                          color: hasTenant
                              ? Colors.white70
                              : palette(context).muted),
                      overflow: TextOverflow.ellipsis,
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

  void openApartment(Map<String, dynamic> apt) {
    final t = AppLocalizations.of(context)!;
    final hasTenant = apt['tenant_id'] != null;
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
            Text('${t.apartment} ${apt['number']}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (!hasTenant)
              ListTile(
                leading: const Icon(Icons.person_add_outlined, color: kAccent),
                title: Text(t.addTenant),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AddTenantDialog(
                        apartment: apt, buildingCode: buildingName),
                  );
                  if (ok == true) load();
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined, color: kAmber),
                title: Text(t.newPassword),
                onTap: () async {
                  Navigator.pop(context);
                  final newPass = genPassword(apt['number']);
                  try {
                    final res = await supabase.functions.invoke('reset-password',
                        body: {
                          'user_id': apt['tenant_id'],
                          'password': newPass,
                        });
                    final data = res.data as Map<String, dynamic>;
                    if (data['error'] != null) throw data['error'];
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(t.newPassword),
                        content: SelectableText(newPass,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(backgroundColor: kAccent),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.person_remove_outlined,
                    color: palette(context).muted),
                title: Text(t.delete),
                onTap: () async {
                  Navigator.pop(context);
                  await supabase
                      .from('apartments')
                      .update({'tenant_id': null}).eq('id', apt['id']);
                  load();
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ============ СОЗДАНИЕ ЖИЛЬЦА ============
class AddTenantDialog extends StatefulWidget {
  final Map<String, dynamic> apartment;
  final String buildingCode;
  const AddTenantDialog(
      {super.key, required this.apartment, required this.buildingCode});
  @override
  State<AddTenantDialog> createState() => _AddTenantDialogState();
}

class _AddTenantDialogState extends State<AddTenantDialog> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool loading = false;
  String? createdLogin;
  String? createdPassword;

  Future<void> save() async {
    setState(() => loading = true);
    try {
      final aptNum = widget.apartment['number'];
      final email = genEmail(aptNum, widget.buildingCode);
      final password = genPassword(aptNum);

      final res = await supabase.functions.invoke('create-user', body: {
        'email': email,
        'password': password,
        'full_name': name.text.trim().isEmpty ? '№$aptNum' : name.text.trim(),
        'phone': phone.text.trim(),
        'role': 'tenant',
        'apartment_id': widget.apartment['id'],
      });

      final data = res.data as Map<String, dynamic>;
      if (data['error'] != null) throw data['error'];

      if (mounted) {
        setState(() {
          createdLogin = email;
          createdPassword = password;
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

    // Показываем данные после создания
    if (createdLogin != null) {
      return AlertDialog(
        title: Text(t.credentials),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _credRow(t.login, createdLogin!),
            const SizedBox(height: 12),
            _credRow(t.password, createdPassword!),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAmberSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.savePasswordWarning,
                style: const TextStyle(
                  fontSize: 12,
                  color: kAmber,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final navigator = Navigator.of(context);

              navigator.pop(true);

              navigator.push(
                MaterialPageRoute(
                  builder: (_) => TenantCardScreen(
                    apartmentNumber: widget.apartment['number'],
                    buildingName: widget.buildingCode,
                    login: createdLogin!,
                    password: createdPassword!,
                  ),
                ),
              );
            },
            child: Text(t.printCard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
            ),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('${t.addTenant} · ${t.apartment} ${widget.apartment['number']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: name,
              decoration: InputDecoration(labelText: t.fullName)),
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
          child: loading
              ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : Text(t.create),
        ),
      ],
    );
  }

  Widget _credRow(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: palette(context).muted)),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.copy),
                duration: const Duration(seconds: 1)),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kAccentSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace')),
              ),
              const Icon(Icons.copy, size: 16, color: kAccent),
            ],
          ),
        ),
      ),
    ],
  );
}
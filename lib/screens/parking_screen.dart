import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft;

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});
  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  List<Map<String, dynamic>> spots = [];
  List<Map<String, dynamic>> apartments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final s = await supabase
          .from('parking_spots')
          .select('*, apartments(number)')
          .order('number');
      final a = await supabase.from('apartments').select().order('number');
      if (mounted) {
        setState(() {
          spots = List<Map<String, dynamic>>.from(s);
          apartments = List<Map<String, dynamic>>.from(a);
          apartments.sort((x, y) => (int.tryParse(x['number'] ?? '0') ?? 0)
              .compareTo(int.tryParse(y['number'] ?? '0') ?? 0));
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

  Future<void> setSpot(String id, String status, String? aptId) async {
    try {
      await supabase.from('parking_spots').update({
        'status': status,
        'apartment_id': aptId,
      }).eq('id', id);
      load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final free = spots.where((s) => s['status'] == 'free').length;
    final occupied = spots.where((s) => s['status'] == 'occupied').length;
    final guest = spots.where((s) => s['status'] == 'guest').length;

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Легенда
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: [
                _legend(kAccentSoft, kAccent, '${t.free} $free'),
                const SizedBox(width: 16),
                _legend(kAccent, kAccent, '${t.occupied} $occupied',
                    filled: true),
                const SizedBox(width: 16),
                _legend(kAmberSoft, kAmber, '${t.guest} $guest'),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: load,
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.92,
                ),
                itemCount: spots.length,
                itemBuilder: (context, i) {
                  final s = spots[i];
                  final status = s['status'] as String;
                  final aptNum = s['apartments']?['number'];

                  final (bg, fg, border) = switch (status) {
                    'occupied' => (kAccent, Colors.white, kAccent),
                    'guest' => (kAmberSoft, kAmber, const Color(0xFFE6D1A3)),
                    _ => (kAccentSoft, kAccent, const Color(0xFFBCDCCF)),
                  };

                  final label = switch (status) {
                    'occupied' => aptNum != null ? '№$aptNum' : t.occupied,
                    'guest' => t.guest,
                    _ => t.free,
                  };

                  return GestureDetector(
                    onTap: () => openSpot(s),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('М${s['number']}',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: fg.withValues(alpha: .6))),
                          const SizedBox(height: 2),
                          Text(label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: fg),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color bg, Color border, String text, {bool filled = false}) =>
      Row(
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: bg,
              border: filled ? null : Border.all(color: border),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: palette(context).muted)),
        ],
      );

  void openSpot(Map<String, dynamic> spot) {
    final t = AppLocalizations.of(context)!;
    final status = spot['status'] as String;
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
            Text('${t.spot} №${spot['number']}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (status != 'occupied')
              ListTile(
                leading: const Icon(Icons.home_outlined, color: kAccent),
                title: Text(t.assignToApartment),
                onTap: () async {
                  Navigator.pop(context);
                  final aptId = await showDialog<String>(
                    context: context,
                    builder: (_) => SelectApartmentDialog(apartments: apartments),
                  );
                  if (aptId != null) setSpot(spot['id'], 'occupied', aptId);
                },
              ),
            if (status != 'guest')
              ListTile(
                leading: const Icon(Icons.person_outline, color: kAmber),
                title: Text(t.makeGuest),
                onTap: () {
                  Navigator.pop(context);
                  setSpot(spot['id'], 'guest', null);
                },
              ),
            if (status != 'free')
              ListTile(
                leading: Icon(Icons.check_circle_outline,
                    color: palette(context).muted),
                title: Text(t.release),
                onTap: () {
                  Navigator.pop(context);
                  setSpot(spot['id'], 'free', null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ============ ВЫБОР КВАРТИРЫ ============
class SelectApartmentDialog extends StatelessWidget {
  final List<Map<String, dynamic>> apartments;
  const SelectApartmentDialog({super.key, required this.apartments});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.selectApartment),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.3,
          ),
          itemCount: apartments.length,
          itemBuilder: (context, i) {
            final a = apartments[i];
            return GestureDetector(
              onTap: () => Navigator.pop(context, a['id'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: kAccentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(a['number'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: kAccent)),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

class SetupBuildingScreen extends StatefulWidget {
  const SetupBuildingScreen({super.key});
  @override
  State<SetupBuildingScreen> createState() => _SetupBuildingScreenState();
}

class _SetupBuildingScreenState extends State<SetupBuildingScreen> {
  final name = TextEditingController();
  final address = TextEditingController();
  int entrances = 1;
  int floors = 9;
  int apartments = 48;
  int parking = 40;
  bool loading = false;

  Future<void> create() async {
    if (name.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;

      final building = await supabase.from('buildings').insert({
        'name': name.text.trim(),
        'address': address.text.trim(),
        'entrances': entrances,
        'floors': floors,
      }).select().single();

      final buildingId = building['id'];

      // 2. Привязываем админа к дому
      await supabase.from('profiles')
          .update({'building_id': buildingId}).eq('id', uid);

      // 3. Создаём квартиры
      final flats = List.generate(apartments, (i) => {
        'building_id': buildingId,
        'number': '${i + 1}',
        'floor': (i ~/ (apartments / floors).ceil()) + 1,
        'entrance': 1,
      });
      if (flats.isNotEmpty) await supabase.from('apartments').insert(flats);

      // 4. Создаём парковочные места
      final spots = List.generate(parking, (i) => {
        'building_id': buildingId,
        'number': i + 1,
        'status': 'free',
      });
      if (spots.isNotEmpty) await supabase.from('parking_spots').insert(spots);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileGate()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Widget stepper(String label, int value, ValueChanged<int> onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600))),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: palette(context).line),
              borderRadius: BorderRadius.circular(12),
              color: palette(context).card,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: value > 1 ? () => onChange(value - 1) : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 44,
                  child: Text('$value',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () => onChange(value + 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.createBuilding),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: t.buildingName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: address,
                decoration: InputDecoration(labelText: t.address),
              ),
              const SizedBox(height: 24),
              stepper(t.entrances, entrances, (v) => setState(() => entrances = v)),
              stepper(t.floors, floors, (v) => setState(() => floors = v)),
              stepper(t.apartments, apartments, (v) => setState(() => apartments = v)),
              stepper(t.parkingSpots, parking, (v) => setState(() => parking = v)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loading ? null : create,
                child: loading
                    ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(t.createBuilding),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
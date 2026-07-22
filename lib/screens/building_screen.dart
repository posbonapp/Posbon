import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'apartments_screen.dart';
import 'parking_screen.dart';
import '../theme.dart';
import 'admin_tasks_screen.dart' show kAccent;

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});
  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: palette(context).line,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _seg(t.apartmentsTab, 0),
                _seg(t.parking, 1),
              ],
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: const [
              ApartmentsScreen(),
              ParkingScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seg(String label, int i) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => tab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: tab == i ? palette(context).card : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: tab == i
              ? [
            BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 4)
          ]
              : null,
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tab == i ? kAccent : palette(context).muted)),
        ),
      ),
    ),
  );
}
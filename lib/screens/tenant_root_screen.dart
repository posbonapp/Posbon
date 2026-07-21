import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../notifications.dart';
import 'tenant_home_screen.dart';
import 'announcements_screen.dart';
import 'settings_screen.dart';

class TenantRootScreen extends StatefulWidget {
  const TenantRootScreen({super.key});
  @override
  State<TenantRootScreen> createState() => _TenantRootScreenState();
}

class _TenantRootScreenState extends State<TenantRootScreen> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    Notifications.pendingType.addListener(_onPendingNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPendingNotification());
  }

  @override
  void dispose() {
    Notifications.pendingType.removeListener(_onPendingNotification);
    super.dispose();
  }

  void _onPendingNotification() {
    final type = Notifications.pendingType.value;
    if (type == null || !mounted) return;
    Notifications.pendingType.value = null;
    switch (type) {
      case 'task_done':
        setState(() => index = 0);
        break;
      case 'announcement_new':
        setState(() => index = 1);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          TenantHomeScreen(),
          AnnouncementsScreen(isAdmin: false),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.myApartment,
          ),
          NavigationDestination(
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign),
            label: t.announcements,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: t.settings,
          ),
        ],
      ),
    );
  }
}
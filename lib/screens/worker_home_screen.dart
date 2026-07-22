import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../notifications.dart';
import '../theme.dart';
import 'worker_tasks_screen.dart';
import 'worker_report_screen.dart';
import 'purchase_screen.dart';
import 'stock_screen.dart';
import 'announcements_screen.dart';
import 'settings_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});
  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int index = 0;
  String? myName;

  @override
  void initState() {
    super.initState();
    load();
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
      case 'task_new':
      case 'task_redo':
      case 'request_new':
        setState(() => index = 0);
        break;
      case 'announcement_new':
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const AnnouncementsScreen(isAdmin: false)),
        );
        break;
    }
  }

  Future<void> load() async {
    final uid = supabase.auth.currentUser!.id;
    final me = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', uid)
        .maybeSingle();
    if (mounted) setState(() => myName = me?['full_name']);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.myTasks, t.purchase, t.stock, t.settings];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[index], style: const TextStyle(fontSize: 18)),
            if (myName != null && index == 0)
              Text(myName!,
                  style: TextStyle(fontSize: 11.5, color: palette(context).muted)),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const AnnouncementsScreen(isAdmin: false)),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          WorkerTasksScreen(),
          PurchaseScreen(isAdmin: false),
          StockScreen(isAdmin: false),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2F7D6B),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkerReportScreen()),
        ),
        icon: const Icon(Icons.report_problem_outlined,
            color: Colors.white),
        label: Text(t.reportProblem,
            style: const TextStyle(color: Colors.white)),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: t.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: t.purchase,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: t.stock,
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
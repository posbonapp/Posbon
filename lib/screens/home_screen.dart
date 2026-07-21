import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../notifications.dart';
import 'admin_tasks_screen.dart';
import 'people_screen.dart';
import 'stock_screen.dart';
import 'building_screen.dart';
import 'admin_requests_screen.dart';
import 'settings_screen.dart';
import 'announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  Map<String, dynamic>? building;
  int newRequests = 0;
  int reviewTasks = 0;
  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    load();
    loadCounts();
    subscribe();
    Notifications.pendingType.addListener(_onPendingNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPendingNotification());
  }

  @override
  void dispose() {
    if (channel != null) supabase.removeChannel(channel!);
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
      case 'task_done':
        setState(() => index = 0);
        break;
      case 'request_new':
        setState(() => index = 1);
        break;
      case 'announcement_new':
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const AnnouncementsScreen(isAdmin: true)),
        );
        break;
    }
  }

  Future<void> load() async {
    final b = await supabase.from('buildings').select().limit(1).maybeSingle();
    if (mounted) setState(() => building = b);
  }

  Future<void> loadCounts() async {
    try {
      final r = await supabase.from('requests').count().eq('status', 'new');
      final t = await supabase.from('tasks').count().eq('status', 'review');
      if (mounted) {
        setState(() {
          newRequests = r;
          reviewTasks = t;
        });
      }
    } catch (_) {}
  }

  void subscribe() {
    channel = supabase
        .channel('admin-counts')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'requests',
      callback: (_) => loadCounts(),
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tasks',
      callback: (_) => loadCounts(),
    )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.tasks, t.requests, t.stock, t.apartmentsTab, t.people];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[index], style: const TextStyle(fontSize: 18)),
            if (building != null)
              Text(building!['name'] ?? '',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const AnnouncementsScreen(isAdmin: true)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          AdminTasksScreen(),
          AdminRequestsScreen(),
          StockScreen(),
          BuildingScreen(),   // ← было ApartmentsScreen()
          PeopleScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: reviewTasks > 0,
              label: Text('$reviewTasks'),
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: reviewTasks > 0,
              label: Text('$reviewTasks'),
              child: const Icon(Icons.assignment),
            ),
            label: t.tasks,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: newRequests > 0,
              label: Text('$newRequests'),
              child: const Icon(Icons.report_problem_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newRequests > 0,
              label: Text('$newRequests'),
              child: const Icon(Icons.report_problem),
            ),
            label: t.requests,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: t.stock,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.apartmentsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: t.people,
          ),
        ],
      ),
    );
  }
}
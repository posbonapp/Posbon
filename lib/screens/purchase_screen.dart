import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import '../theme.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kRed, kRedSoft, kBlue, kBlueSoft;

class PurchaseScreen extends StatefulWidget {
  final bool isAdmin;
  const PurchaseScreen({super.key, required this.isAdmin});
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
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
          .from('purchase_requests')
          .select('*, worker:created_by(full_name), purchase_items(count)')
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

  Future<void> createRequest() async {
    final uid = supabase.auth.currentUser!.id;
    final me = await supabase
        .from('profiles')
        .select('building_id')
        .eq('id', uid)
        .single();
    final created = await supabase.from('purchase_requests').insert({
      'building_id': me['building_id'],
      'created_by': uid,
      'items_text': '',
      'status': 'new',
    }).select().single();
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => PurchaseDetailScreen(
                request: created, isAdmin: widget.isAdmin)),
      );
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noPurchases,
              style: TextStyle(color: palette(context).muted)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final p = rows[i];
            final count =
                (p['purchase_items'] as List?)?.firstOrNull?['count'] ?? 0;
            final status = p['status'] as String;
            final (label, fg, bg) = switch (status) {
              'approved' => (t.purchaseApproved, kAccent, kAccentSoft),
              'rejected' => (t.purchaseRejected, kRed, kRedSoft),
              _ => (t.purchasePending, kAmber, kAmberSoft),
            };
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => PurchaseDetailScreen(
                          request: p, isAdmin: widget.isAdmin)),
                );
                load();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: palette(context).card,
                  border: Border.all(color: palette(context).line),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kAccentSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: kAccent),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p['worker']?['full_name'] ?? ''} · $count',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(fmt(p['created_at']),
                              style: TextStyle(
                                  fontSize: 12, color: palette(context).muted)),
                        ],
                      ),
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccent,
        onPressed: createRequest,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label:
        Text(t.newPurchase, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ============ ДЕТАЛИ ЗАЯВКИ — СПИСОК ПОКУПОК ============
class PurchaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool isAdmin;
  const PurchaseDetailScreen({super.key, required this.request, this.isAdmin = false});
  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final data = await supabase
        .from('purchase_items')
        .select('*, items(name, icon)')
        .eq('request_id', widget.request['id'])
        .order('created_at');
    if (mounted) {
      setState(() {
        items = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    }
  }

  Future<void> setStatus(Map<String, dynamic> item, String status) async {
    await supabase.rpc('buy_purchase_item', params: {
      'p_item': item['id'],
      'p_status': status,
    });
    load();
  }

  Future<void> deleteItem(String id) async {
    await supabase.from('purchase_items').delete().eq('id', id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.purchaseList),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
          child: Text(t.addFirst,
              style: TextStyle(color: palette(context).muted)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          final status = it['status'] as String;
          final linked = it['items'];
          final name = linked?['name'] ?? it['name'];

          final (sLabel, sColor, sBg) = switch (status) {
            'bought' => (t.statusBought, kAccent, kAccentSoft),
            'unavailable' => (t.statusUnavailable, kRed, kRedSoft),
            'ordered' => (t.statusOrdered, kBlue, kBlueSoft),
            _ => (t.statusNeeded, kAmber, kAmberSoft),
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette(context).card,
              border: Border.all(color: palette(context).line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (linked != null)
                      Icon(iconFor(linked['icon']),
                          size: 20, color: kAccent),
                    if (linked != null) const SizedBox(width: 8),
                    Expanded(
                      child: Text('$name × ${it['qty']}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () => deleteItem(it['id']),
                      child: Icon(Icons.close,
                          size: 18, color: palette(context).muted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _statusChip(t.statusNeeded, 'needed', status, it),
                    _statusChip(t.statusBought, 'bought', status, it),
                    _statusChip(
                        t.statusUnavailable, 'unavailable', status, it),
                    _statusChip(
                        t.statusOrdered, 'ordered', status, it),
                  ],
                ),
                if (widget.isAdmin && linked == null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => LinkItemDialog(
                            purchaseItem: it,
                            buildingId: widget.request['building_id']),
                      );
                      if (ok == true) load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: kBlueSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link, size: 15, color: kBlue),
                          const SizedBox(width: 6),
                          Text(t.linkToStock,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kBlue)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (linked != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: kAccent),
                      const SizedBox(width: 5),
                      Text(t.linkToStock,
                          style: const TextStyle(
                              fontSize: 11, color: kAccent)),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccent,
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AddPurchaseItemDialog(request: widget.request),
          );
          if (ok == true) load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statusChip(
      String label, String value, String current, Map<String, dynamic> item) {
    final selected = current == value;
    final color = switch (value) {
      'bought' => kAccent,
      'unavailable' => kRed,
      'ordered' => kBlue,
      _ => kAmber,
    };
    return GestureDetector(
      onTap: () => setStatus(item, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : palette(context).card,
          border: Border.all(color: selected ? color : palette(context).line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : palette(context).muted)),
      ),
    );
  }
}

// ============ ДОБАВИТЬ ПОЗИЦИЮ (простой список) ============
class AddPurchaseItemDialog extends StatefulWidget {
  final Map<String, dynamic> request;
  const AddPurchaseItemDialog({super.key, required this.request});
  @override
  State<AddPurchaseItemDialog> createState() => _AddPurchaseItemDialogState();
}

class _AddPurchaseItemDialogState extends State<AddPurchaseItemDialog> {
  final name = TextEditingController();
  List<Map<String, dynamic>> stockItems = [];
  String? selectedId;
  int qty = 1;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final data = await supabase.from('items').select().order('name');
    if (mounted) {
      setState(() => stockItems = List<Map<String, dynamic>>.from(data));
    }
  }

  Future<void> save() async {
    final query = name.text.trim();
    if (selectedId == null && query.isEmpty) return;
    setState(() => loading = true);
    try {
      String itemName;
      String? itemId;
      if (selectedId != null) {
        final sel = stockItems.firstWhere((x) => x['id'] == selectedId);
        itemName = sel['name'];
        itemId = sel['id'];
      } else {
        itemName = query;
        itemId = null; // новый — текстом, привяжет админ
      }
      await supabase.from('purchase_items').insert({
        'request_id': widget.request['id'],
        'building_id': widget.request['building_id'],
        'name': itemName,
        'qty': qty,
        'item_id': itemId,
        'added_by': supabase.auth.currentUser!.id,
        'status': 'needed',
      });
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
    final query = name.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? stockItems
        : stockItems
        .where((x) => (x['name'] ?? '').toLowerCase().contains(query))
        .toList();

    return AlertDialog(
      title: Text(t.addItem),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: t.itemNameField,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
              onChanged: (_) => setState(() => selectedId = null),
            ),
            const SizedBox(height: 12),
            if (filtered.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView(
                  children: filtered.map((it) {
                    final sel = selectedId == it['id'];
                    return ListTile(
                      dense: true,
                      leading:
                      Icon(iconFor(it['icon']), size: 20, color: kAccent),
                      title: Text(it['name'] ?? ''),
                      trailing: sel
                          ? const Icon(Icons.check_circle, color: kAccent)
                          : null,
                      onTap: () => setState(() {
                        selectedId = it['id'];
                        name.text = it['name'];
                      }),
                    );
                  }).toList(),
                ),
              ),
            const Divider(),
            Row(
              children: [
                Text(t.qtyLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  onPressed: qty > 1 ? () => setState(() => qty--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$qty',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => qty++),
                  icon: const Icon(Icons.add_circle_outline, color: kAccent),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: loading ? null : save,
          style: FilledButton.styleFrom(backgroundColor: kAccent),
          child: Text(t.addItem),
        ),
      ],
    );
  }
}

// ============ ПРИВЯЗКА ПОЗИЦИИ К ТОВАРУ (админ) ============
class LinkItemDialog extends StatefulWidget {
  final Map<String, dynamic> purchaseItem;
  final String buildingId;
  const LinkItemDialog(
      {super.key, required this.purchaseItem, required this.buildingId});
  @override
  State<LinkItemDialog> createState() => _LinkItemDialogState();
}

class _LinkItemDialogState extends State<LinkItemDialog> {
  final search = TextEditingController();
  List<Map<String, dynamic>> stockItems = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    search.text = widget.purchaseItem['name'] ?? '';
    loadItems();
  }

  Future<void> loadItems() async {
    final data = await supabase.from('items').select().order('name');
    if (mounted) {
      setState(() => stockItems = List<Map<String, dynamic>>.from(data));
    }
  }

  Future<void> link(String itemId) async {
    setState(() => loading = true);
    await supabase
        .from('purchase_items')
        .update({'item_id': itemId}).eq('id', widget.purchaseItem['id']);
    // если позиция уже куплена — сразу зачисляем на склад
    if (widget.purchaseItem['status'] == 'bought') {
      await supabase.rpc('link_bought_item', params: {
        'p_item': widget.purchaseItem['id'],
      });
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> createAndLink() async {
    setState(() => loading = true);
    final nm = search.text.trim();
    final created = await supabase.from('items').insert({
      'building_id': widget.buildingId,
      'name': nm,
      'icon': guessIcon(nm),
      'min_stock': 0,
      'unit': 'pcs',
    }).select().single();
    await supabase.from('stock').insert({
      'building_id': widget.buildingId,
      'item_id': created['id'],
      'qty_available': 0,
    });
    await link(created['id']);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final query = search.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? stockItems
        : stockItems
        .where((x) => (x['name'] ?? '').toLowerCase().contains(query))
        .toList();
    final exactMatch =
    stockItems.any((x) => (x['name'] ?? '').toLowerCase() == query);

    return AlertDialog(
      title: Text(t.linkToStock),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: search,
              decoration: InputDecoration(
                labelText: t.itemNameField,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView(
                children: [
                  ...filtered.map((it) => ListTile(
                    dense: true,
                    leading: Icon(iconFor(it['icon']),
                        size: 20, color: kAccent),
                    title: Text(it['name'] ?? ''),
                    onTap: loading ? null : () => link(it['id']),
                  )),
                  if (query.isNotEmpty && !exactMatch)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline,
                          size: 20, color: kAmber),
                      title:
                      Text('${t.createNewItem}: "${search.text.trim()}"'),
                      onTap: loading ? null : createAndLink,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
      ],
    );
  }
}
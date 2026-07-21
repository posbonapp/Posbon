import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_tasks_screen.dart'
    show kAccent, kAccentSoft, kAmber, kAmberSoft, kRed, kLine;

String unitLabel(AppLocalizations t, String? unit) => switch (unit) {
  'box' => t.unitBox,
  'pack' => t.unitPack,
  'tube' => t.unitTube,
  'm' => t.unitMeter,
  'L' => t.unitLiter,
  'roll' => t.unitRoll,
  'set' => t.unitSet,
  _ => t.unitPcs,
};

class StockScreen extends StatefulWidget {
  final bool isAdmin;

  const StockScreen({
    super.key,
    this.isAdmin = true,
  });

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    load();
    channel = supabase
        .channel('stock-changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'stock',
      callback: (_) => load(),
    )
        .subscribe();
  }

  @override
  void dispose() {
    if (channel != null) supabase.removeChannel(channel!);
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('items')
          .select('*, stock(qty_available, qty_reserved, qty_installed)')
          .order('name');
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? Center(
          child: Text(t.noItems,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final item = rows[i];
            final s = (item['stock'] as List?)?.firstOrNull;
            final avail = s?['qty_available'] ?? 0;
            final res = s?['qty_reserved'] ?? 0;
            final inst = s?['qty_installed'] ?? 0;
            final min = item['min_stock'] ?? 0;
            final low = avail < min;
            final total = avail + res + inst;
            final pct = total > 0 ? avail / total : 0.0;

            return GestureDetector(
              onTap: () => showItemMenu(item, avail),
              child: Container(
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kLine),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: kAccentSoft,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(iconFor(item['icon']),
                              color: kAccent, size: 22),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                '${t.inStock} $avail ${unitLabel(t, item['unit'])} · ${t.reserved} $res · ${t.installed} $inst',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (low)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: kAmberSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t.lowStock,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: kAmber)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: kLine,
                        color: low ? kAmber : kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
        backgroundColor: kAccent,
        onPressed: () async {
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const NewItemScreen(),
            ),
          );

          if (ok == true) {
            load();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  void showItemMenu(Map<String, dynamic> item, int avail) {
    final t = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Списание доступно и консьержу, и администратору
            ListTile(
              leading: const Icon(
                Icons.remove_circle_outline,
                color: kAmber,
              ),
              title: Text(t.writeOff),
              onTap: () async {
                Navigator.pop(context);

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => WriteOffDialog(
                    item: item,
                    current: avail,
                  ),
                );

                if (ok == true) {
                  load();
                }
              },
            ),

            // Эти действия доступны только администратору
            if (widget.isAdmin) ...[
              ListTile(
                leading: const Icon(
                  Icons.add_box_outlined,
                  color: kAccent,
                ),
                title: Text(t.addStock),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AddStockDialog(item: item),
                  );

                  if (ok == true) {
                    load();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: kAccent,
                ),
                title: Text(t.edit),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => NewItemScreen(item: item),
                    ),
                  );

                  if (ok == true) {
                    load();
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: kRed,
                ),
                title: Text(
                  t.delete,
                  style: const TextStyle(color: kRed),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  await supabase
                      .from('items')
                      .delete()
                      .eq('id', item['id']);

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

// ============ ИЗМЕНИТЬ КОЛИЧЕСТВО НА СКЛАДЕ ============
class AddStockDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  const AddStockDialog({super.key, required this.item});
  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  int delta = 0;
  int current = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final s = await supabase
        .from('stock')
        .select('qty_available')
        .eq('item_id', widget.item['id'])
        .maybeSingle();
    if (mounted) setState(() => current = s?['qty_available'] ?? 0);
  }

  Future<void> save() async {
    if (delta == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => loading = true);
    try {
      final existing = await supabase
          .from('stock')
          .select()
          .eq('item_id', widget.item['id'])
          .maybeSingle();
      final newQty = (current + delta).clamp(0, 999999);
      if (existing == null) {
        await supabase.from('stock').insert({
          'building_id': widget.item['building_id'],
          'item_id': widget.item['id'],
          'qty_available': newQty,
        });
      } else {
        await supabase.from('stock').update({
          'qty_available': newQty,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      }
      // запись в журнал прихода
      await supabase.from('stock_log').insert({
        'building_id': widget.item['building_id'],
        'item_id': widget.item['id'],
        'item_name': widget.item['name'],
        'move_type': delta > 0 ? 'in' : 'out',
        'qty': delta.abs(),
        'by_user': supabase.auth.currentUser!.id,
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
    final result = (current + delta).clamp(0, 999999);
    return AlertDialog(
      title: Text(widget.item['name'] ?? ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${t.inStock}: $current',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 34,
                onPressed: () => setState(() => delta--),
                icon: const Icon(Icons.remove_circle_outline, color: kRed),
              ),
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text('$result',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    if (delta != 0)
                      Text(delta > 0 ? '+$delta' : '$delta',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: delta > 0 ? kAccent : kRed)),
                  ],
                ),
              ),
              IconButton(
                iconSize: 34,
                onPressed: () => setState(() => delta++),
                icon: const Icon(Icons.add_circle_outline, color: kAccent),
              ),
            ],
          ),
        ],
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

// ============ НОВЫЙ ТОВАР ============
class NewItemScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const NewItemScreen({super.key, this.item});
  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final name = TextEditingController();
  String iconKey = 'other';
  bool iconTouched = false;
  int minStock = 2;
  String unit = 'pcs';
  bool loading = false;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      name.text = widget.item!['name'] ?? '';
      iconKey = widget.item!['icon'] ?? 'other';
      minStock = widget.item!['min_stock'] ?? 2;
      unit = widget.item!['unit'] ?? 'pcs';
    }
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) return;
    setState(() => loading = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final data = {
        'name': name.text.trim(),
        'icon': iconKey,
        'min_stock': minStock,
        'unit': unit,
      };

      if (isEdit) {
        await supabase.from('items').update(data).eq('id', widget.item!['id']);
      } else {
        final me = await supabase
            .from('profiles')
            .select('building_id')
            .eq('id', uid)
            .single();
        final created = await supabase
            .from('items')
            .insert({...data, 'building_id': me['building_id']})
            .select()
            .single();
        // сразу создаём запись склада с нулями
        await supabase.from('stock').insert({
          'building_id': me['building_id'],
          'item_id': created['id'],
          'qty_available': 0,
        });
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Widget _unitChip(String label, String value) {
    final selected = unit == value;

    return GestureDetector(
      onTap: () => setState(() => unit = value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? kAccent : Colors.white,
          border: Border.all(
            color: selected ? kAccent : kLine,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? t.edit : t.newItem),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: t.itemName),
              onChanged: (v) {
                final guess = guessIcon(v);
                if (!iconTouched && guess != 'other') {
                  setState(() => iconKey = guess);
                } else {
                  setState(() {}); // обновить превью названия
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(iconFor(iconKey), color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name.text.trim().isEmpty ? t.icon : name.text.trim(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(t.icon,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Text(t.icon,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 230,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kIcons.entries.map((e) {
                        final selected = iconKey == e.key;

                        return GestureDetector(
                          onTap: () => setState(() {
                            iconKey = e.key;
                            iconTouched = true;
                          }),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected ? kAccent : Colors.white,
                              border: Border.all(
                                color: selected ? kAccent : kLine,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              e.value,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.scrollForMore,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              t.unit,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _unitChip(t.unitPcs, 'pcs'),
                _unitChip(t.unitBox, 'box'),
                _unitChip(t.unitPack, 'pack'),
                _unitChip(t.unitTube, 'tube'),
                _unitChip(t.unitMeter, 'm'),
                _unitChip(t.unitLiter, 'L'),
                _unitChip(t.unitRoll, 'roll'),
                _unitChip(t.unitSet, 'set'),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                    child: Text(t.minStock,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kLine),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: minStock > 0
                            ? () => setState(() => minStock--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text('$minStock',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => minStock++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: loading ? null : save,
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? t.save : t.create),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ СПИСАНИЕ РАСХОДНИКА ============
class WriteOffDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final int current;

  const WriteOffDialog({
    super.key,
    required this.item,
    required this.current,
  });

  @override
  State<WriteOffDialog> createState() => _WriteOffDialogState();
}

class _WriteOffDialogState extends State<WriteOffDialog> {
  int qty = 1;
  bool loading = false;

  Future<void> save() async {
    setState(() => loading = true);

    try {
      await supabase.rpc(
        'write_off_item',
        params: {
          'p_item_id': widget.item['id'],
          'p_qty': qty,
        },
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.item['name'] ?? ''),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.writeOffHint,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${t.inStock}: ${widget.current}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                onPressed: qty > 1
                    ? () => setState(() => qty--)
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: kAmber,
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                iconSize: 32,
                onPressed: qty < widget.current
                    ? () => setState(() => qty++)
                    : null,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: kAmber,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: loading || widget.current == 0
              ? null
              : save,
          style: FilledButton.styleFrom(
            backgroundColor: kAmber,
          ),
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(t.writeOff),
        ),
      ],
    );
  }
}
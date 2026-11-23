import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/boq.dart';
import '../core/economy.dart';
import '../core/format.dart';
import '../core/numbers.dart';
import '../shop_page.dart';
import '../workspace.dart';

/// Bill of quantities: items collected from estimates or typed by hand,
/// with unit prices, totals and a spreadsheet-ready export.
class BoqPage extends StatefulWidget {
  const BoqPage({super.key});

  @override
  State<BoqPage> createState() => _BoqPageState();
}

class _BoqPageState extends State<BoqPage> {
  late Future<List<BoqItem>> _data;
  WorkProject? _project;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _data = () async {
      _project = await WorkspaceStore.activeProject();
      final all = await BoqStore.all();
      return all.where((e) => e.projectId == _project?.id).toList();
    }();
  }

  Future<void> _edit([BoqItem? item]) async {
    final title = TextEditingController(text: item?.title ?? '');
    final unit = TextEditingController(text: item?.unit ?? '');
    final qty = TextEditingController(text: item == null ? '' : formatBoqNumber(item.qty));
    final price = TextEditingController(text: item == null || item.unitPrice == 0 ? '' : formatBoqNumber(item.unitPrice));
    String? error;
    final saved = await showDialog<BoqItem>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(item == null ? 'ردیف جدید' : 'ویرایش ردیف'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'شرح کار')),
                const SizedBox(height: 8),
                TextField(controller: unit, decoration: const InputDecoration(labelText: 'واحد (مثلاً مترمکعب)')),
                const SizedBox(height: 8),
                TextField(controller: qty, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'مقدار')),
                const SizedBox(height: 8),
                TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'قیمت واحد (تومان)')),
                if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error))),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
              FilledButton(
                onPressed: () {
                  try {
                    if (title.text.trim().isEmpty) throw const FormatException('شرح کار را وارد کنید.');
                    final q = parseEstimateNumber(qty.text, label: 'مقدار', allowZero: true);
                    final p = price.text.trim().isEmpty ? 0.0 : parseEstimateNumber(price.text, label: 'قیمت واحد', allowZero: true);
                    Navigator.pop(
                      ctx,
                      BoqItem(
                        id: item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                        title: title.text.trim(),
                        unit: unit.text.trim(),
                        qty: q,
                        unitPrice: p,
                        projectId: item?.projectId ?? _project?.id,
                      ),
                    );
                  } on FormatException catch (e) {
                    setLocal(() => error = e.message);
                  }
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
    title.dispose();
    unit.dispose();
    qty.dispose();
    price.dispose();
    if (saved == null) return;
    await BoqStore.upsert(saved);
    if (mounted) setState(_reload);
  }

  Future<void> _export(List<BoqItem> items) async {
    if (items.isEmpty) return;
    final ok = await payWithCoins(context, Cost.boqExport, 'خروجی صورت‌مقادیر',
        openShop: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ShopPage())));
    if (!ok || !mounted) return;
    await Clipboard.setData(ClipboardData(text: boqToTsv(items)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صورت‌مقادیر کپی شد؛ در اکسل Paste کنید.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('صورت‌مقادیر و برآورد')),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('boq-add'),
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('ردیف جدید'),
        ),
        body: FutureBuilder<List<BoqItem>>(
          future: _data,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            final items = snap.data ?? [];
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
              children: [
                Text(
                  _project == null ? 'پروژه فعالی انتخاب نشده؛ ردیف‌ها در «بدون پروژه» ثبت می‌شوند.' : 'پروژه: ${_project!.name}',
                  style: TextStyle(color: scheme.secondary),
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('هنوز ردیفی ندارید. از هر ابزار برآورد، دکمه «افزودن به صورت‌مقادیر» را بزنید یا ردیف دستی بسازید.', style: TextStyle(height: 1.8)),
                  ),
                for (var i = 0; i < items.length; i++)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _edit(items[i]),
                      leading: CircleAvatar(child: Text(fa(i + 1))),
                      title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${fa(formatBoqNumber(items[i].qty))} ${items[i].unit} × ${formatToman(items[i].unitPrice)}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${formatToman(items[i].total)}\nتومان', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        IconButton(
                          tooltip: 'حذف',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await BoqStore.remove(items[i].id);
                            if (mounted) setState(_reload);
                          },
                        ),
                      ]),
                    ),
                  ),
                if (items.isNotEmpty) ...[
                  Card(
                    color: scheme.primary.withValues(alpha: .15),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        const Expanded(child: Text('جمع کل', style: TextStyle(fontWeight: FontWeight.w900))),
                        Text('${formatToman(boqTotal(items))} تومان', key: const Key('boq-total'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _export(items),
                    icon: const Icon(Icons.copy_all),
                    label: Text(context.economy.isPro ? 'کپی برای اکسل' : 'کپی برای اکسل (${fa(Cost.boqExport)} سکه)'),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

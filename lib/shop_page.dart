import 'dart:async';

import 'package:flutter/material.dart';

import 'core/economy.dart';
import 'core/format.dart';
import 'core/purchase.dart';

Future<void> _message(BuildContext context, String text) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('باشه')),
        ],
      ),
    );

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  Future<void> _buy(BuildContext context, ProductInfo info) async {
    final economy = context.economy;
    final navigator = Navigator.of(context, rootNavigator: true);

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(width: 16),
              Expanded(child: Text('در حال اتصال به بازار…')),
            ],
          ),
        ),
      ),
    ));

    PurchaseResult result;
    try {
      result = await economy.buy(info.product).timeout(
            const Duration(seconds: 90),
            onTimeout: () => PurchaseResult.unavailable,
          );
    } catch (_) {
      result = PurchaseResult.unavailable;
    }
    if (navigator.canPop()) navigator.pop();
    if (!context.mounted) return;

    final text = switch (result) {
      PurchaseResult.success => 'خرید انجام شد. سپاس!',
      PurchaseResult.cancelled => 'خرید لغو شد.',
      PurchaseResult.unavailable =>
        'اتصال به کافه بازار برقرار نشد. مطمئن شوید بازار نصب است و وارد حساب شده‌اید.',
    };
    await _message(context, text);
  }

  Future<void> _restore(BuildContext context) async {
    final economy = context.economy;
    final before = economy.coins;
    try {
      await economy.restorePurchases().timeout(const Duration(seconds: 30));
    } catch (_) {}
    if (!context.mounted) return;
    final gained = economy.coins - before;
    await _message(
      context,
      gained > 0
          ? 'خریدها بازیابی شد: ${fa(gained)} سکه اضافه شد.'
          : 'بررسی خریدها انجام شد.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final economy = context.economy;
    final expiry = economy.proExpiry;
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اشتراک و سکه')),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('وضعیت شما', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(economy.isPro
                        ? 'اشتراک ویژه فعال است: بدون تبلیغ، همه خروجی‌ها و پروژه‌ها نامحدود'
                        : 'موجودی سکه: ${fa(economy.coins)}'),
                    if (economy.isPro && expiry != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'پایان اشتراک: ${fa(expiry.year)}/${fa(expiry.month)}/${fa(expiry.day)} (میلادی)',
                          style: TextStyle(color: scheme.secondary),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'مصرف سکه: خروجی صورت‌مقادیر ${fa(Cost.boqExport)}، خروجی دفتر ترازیابی ${fa(Cost.levelingExport)}، '
                      'پروژه بیش از ${fa(freeProjects)} عدد ${fa(Cost.extraProject)} سکه. ماشین‌حساب‌ها و ابزارها رایگان است.',
                      style: TextStyle(fontSize: 12, color: scheme.secondary, height: 1.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final info in productCatalog) ...[
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
                  leading: Icon(
                    info.isSubscription ? Icons.workspace_premium_rounded : Icons.monetization_on_rounded,
                    color: scheme.primary,
                    size: 32,
                  ),
                  title: Text(info.titleFa, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(info.descriptionFa),
                  trailing: FilledButton(
                    key: Key('buy-${info.storeId}'),
                    onPressed: () => _buy(context, info),
                    child: Text(info.priceFa),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () => _restore(context),
              icon: const Icon(Icons.restore_rounded),
              label: const Text('بازیابی خریدها'),
            ),
            const SizedBox(height: 10),
            Text(
              'خریدها از طریق کافه بازار انجام می‌شود. سکه‌ها یک‌بار مصرف و اشتراک‌ها قابل تمدید هستند.',
              style: TextStyle(fontSize: 12, color: scheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

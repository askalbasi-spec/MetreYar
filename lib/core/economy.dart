import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads.dart';
import 'format.dart';
import 'purchase.dart';

/// Projects that can be created for free.
const freeProjects = 3;

/// Coins given once on first launch.
const welcomeCoins = 10;

/// Coin price of each paid action. Pro members pay nothing.
class Cost {
  static const boqExport = 5;
  static const levelingExport = 5;
  static const extraProject = 10;
}

/// Coins and the Pro subscription, stored on the device.
class Economy extends ChangeNotifier {
  Economy({
    DateTime Function()? clock,
    PurchaseService? purchases,
    AdService? ads,
  })  : _clock = clock ?? DateTime.now,
        purchases = purchases ?? StubPurchaseService(),
        ads = ads ?? const NoAdService();

  static const _kPro = 'eco.pro_expiry_ms';
  static const _kCoins = 'eco.coins';
  static const _kWelcome = 'eco.welcome_done';

  final DateTime Function() _clock;
  final PurchaseService purchases;
  final AdService ads;

  DateTime? proExpiry;
  int coins = 0;

  bool get isPro {
    final expiry = proExpiry;
    return expiry != null && expiry.isAfter(_clock());
  }

  /// Coins an action costs this user (zero for Pro).
  int priceOf(int cost) => isPro ? 0 : cost;

  bool canAfford(int cost) => isPro || coins >= cost;

  /// Takes [cost] coins. Returns false (and takes nothing) when short.
  Future<bool> spend(int cost) async {
    if (isPro || cost <= 0) return true;
    if (coins < cost) return false;
    coins -= cost;
    await _commit();
    return true;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_kPro);
      proExpiry = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
      coins = prefs.getInt(_kCoins) ?? 0;
      if (prefs.getBool(_kWelcome) != true) {
        coins += welcomeCoins;
        await prefs.setBool(_kWelcome, true);
        await prefs.setInt(_kCoins, coins);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _commit() async {
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry = proExpiry;
      if (expiry != null) {
        await prefs.setInt(_kPro, expiry.millisecondsSinceEpoch);
      }
      await prefs.setInt(_kCoins, coins);
    } catch (_) {}
  }

  Future<PurchaseResult> buy(Product product) async {
    final result = await purchases.purchase(product);
    if (result == PurchaseResult.success) await applyPurchase(product);
    return result;
  }

  Future<void> applyPurchase(Product product) async {
    final info = productCatalog.firstWhere((p) => p.product == product);
    if (info.proDays > 0) {
      final now = _clock();
      final current = proExpiry;
      final base = current != null && current.isAfter(now) ? current : now;
      proExpiry = base.add(Duration(days: info.proDays));
    }
    coins += info.coins;
    await _commit();
  }

  /// Delivers paid packs once each and keeps Pro on while a subscription is
  /// active in the store. Safe to call repeatedly.
  Future<void> restorePurchases() async {
    final result = await purchases.restore();
    if (result.isEmpty) return;
    for (final product in result.consumables) {
      final info = productCatalog.firstWhere((p) => p.product == product);
      coins += info.coins;
    }
    final now = _clock();
    for (final product in result.activeSubscriptions) {
      final info = productCatalog.firstWhere((p) => p.product == product);
      final until = now.add(Duration(days: info.proDays));
      final current = proExpiry;
      if (current == null || current.isBefore(until)) proExpiry = until;
    }
    await _commit();
  }
}

class EconomyScope extends InheritedNotifier<Economy> {
  const EconomyScope({
    super.key,
    required Economy economy,
    required super.child,
  }) : super(notifier: economy);

  static Economy of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EconomyScope>()!.notifier!;
}

extension EconomyContext on BuildContext {
  Economy get economy => EconomyScope.of(this);
}

/// Asks to spend [cost] coins for [what]. Offers the shop when short.
/// Returns true when the action may go ahead.
Future<bool> payWithCoins(BuildContext context, int cost, String what,
    {required VoidCallback openShop}) async {
  final economy = context.economy;
  if (economy.isPro || cost <= 0) return true;
  if (!economy.canAfford(cost)) {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سکه کافی نیست'),
        content: Text('$what به ${fa(cost)} سکه نیاز دارد و موجودی شما ${fa(economy.coins)} است.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('بستن')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خرید سکه / اشتراک')),
        ],
      ),
    );
    if (go == true) openShop();
    return false;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(what),
      content: Text('${fa(cost)} سکه از موجودی شما (${fa(economy.coins)}) کم می‌شود. ادامه می‌دهید؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تایید')),
      ],
    ),
  );
  if (ok != true) return false;
  return economy.spend(cost);
}

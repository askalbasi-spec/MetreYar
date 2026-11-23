import 'dart:async';

import 'package:flutter_poolakey/flutter_poolakey.dart';

import 'purchase.dart';

/// Purchases through Cafe Bazaar (Poolakey).
///
/// Coin packs are consumable: after a successful payment the purchase is
/// consumed in Bazaar first and only then granted, so a purchase can never be
/// granted twice. If the app is closed between payment and grant, [restore]
/// (run at start-up and from the store page) delivers it.
///
/// Subscriptions follow Bazaar: Pro is active while Bazaar reports the
/// subscription as active. The RSA public key from the Bazaar developer panel
/// lets the SDK verify purchase signatures.
class BazaarPurchaseService implements PurchaseService {
  BazaarPurchaseService({required this.rsaKey});

  final String rsaKey;
  Future<bool>? _connection;

  Future<bool> _ensureConnected() => _connection ??= _connect();

  Future<bool> _connect() async {
    final done = Completer<bool>();
    // Not awaited: when Bazaar is not installed the native call may never
    // answer, and waiting for it would hang forever.
    unawaited(
      FlutterPoolakey.connect(
        rsaKey,
        onSucceed: () {
          if (!done.isCompleted) done.complete(true);
        },
        onFailed: () {
          if (!done.isCompleted) done.complete(false);
        },
        onDisconnected: () {
          _connection = null;
        },
      ).then<void>((_) {}, onError: (Object _) {
        if (!done.isCompleted) done.complete(false);
      }),
    );
    final ok = await done.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => false,
    );
    if (!ok) _connection = null;
    return ok;
  }

  ProductInfo? _byStoreId(String storeId) {
    for (final info in productCatalog) {
      if (info.storeId == storeId) return info;
    }
    return null;
  }

  @override
  Future<PurchaseResult> purchase(Product product) async {
    if (!await _ensureConnected()) return PurchaseResult.unavailable;
    final info = productCatalog.firstWhere((p) => p.product == product);
    try {
      final PurchaseInfo result = info.isSubscription
          ? await FlutterPoolakey.subscribe(info.storeId, payload: '')
          : await FlutterPoolakey.purchase(info.storeId, payload: '');
      if (info.isSubscription) return PurchaseResult.success;
      final consumed = await FlutterPoolakey.consume(result.purchaseToken);
      return consumed == true
          ? PurchaseResult.success
          : PurchaseResult.unavailable;
    } catch (_) {
      // Closing the payment screen or a failed payment both surface as errors.
      return PurchaseResult.cancelled;
    }
  }

  @override
  Future<RestoreResult> restore() async {
    if (!await _ensureConnected()) return const RestoreResult();
    final consumables = <Product>[];
    final subscriptions = <Product>[];
    try {
      final owned =
          await FlutterPoolakey.getAllPurchasedProducts();
      for (final purchase in owned) {
        final info = _byStoreId(purchase.productId);
        if (info == null || info.isSubscription) continue;
        final consumed = await FlutterPoolakey.consume(purchase.purchaseToken);
        if (consumed == true) consumables.add(info.product);
      }
      final subscribed =
          await FlutterPoolakey.getAllSubscribedProducts();
      for (final purchase in subscribed) {
        final info = _byStoreId(purchase.productId);
        if (info != null && info.isSubscription) {
          subscriptions.add(info.product);
        }
      }
    } catch (_) {
      // Keep whatever was already collected.
    }
    return RestoreResult(
      consumables: consumables,
      activeSubscriptions: subscriptions,
    );
  }
}

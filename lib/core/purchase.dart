import 'package:flutter/foundation.dart';

enum Product { proMonthly, proYearly, coins50, coins150, coins500 }

enum PurchaseResult { success, cancelled, unavailable }

class ProductInfo {
  const ProductInfo({
    required this.product,
    required this.storeId,
    required this.titleFa,
    required this.descriptionFa,
    required this.priceFa,
    this.coins = 0,
    this.proDays = 0,
  });

  final Product product;

  /// Product id to define in the Cafe Bazaar panel.
  final String storeId;
  final String titleFa;
  final String descriptionFa;

  /// Display price only; the real price is set in the Bazaar panel.
  final String priceFa;

  /// Coins this consumable pack adds.
  final int coins;
  final int proDays;

  bool get isSubscription => proDays > 0;
}

const productCatalog = <ProductInfo>[
  ProductInfo(
    product: Product.proMonthly,
    storeId: 'metre_pro_monthly',
    titleFa: 'اشتراک ماهانه',
    descriptionFa: 'بدون تبلیغ، خروجی و پروژه نامحدود',
    priceFa: '۴۹٬۰۰۰ تومان',
    proDays: 31,
  ),
  ProductInfo(
    product: Product.proYearly,
    storeId: 'metre_pro_yearly',
    titleFa: 'اشتراک سالانه',
    descriptionFa: 'همه امکانات ویژه یک سال، به‌صرفه‌تر',
    priceFa: '۳۹۹٬۰۰۰ تومان',
    proDays: 366,
  ),
  ProductInfo(
    product: Product.coins50,
    storeId: 'metre_coins_50',
    titleFa: '۵۰ سکه',
    descriptionFa: 'برای خروجی صورت‌مقادیر، دفتر ترازیابی و پروژه اضافه',
    priceFa: '۱۹٬۰۰۰ تومان',
    coins: 50,
  ),
  ProductInfo(
    product: Product.coins150,
    storeId: 'metre_coins_150',
    titleFa: '۱۵۰ سکه',
    descriptionFa: 'بسته اقتصادی با سکه بیشتر',
    priceFa: '۴۹٬۰۰۰ تومان',
    coins: 150,
  ),
  ProductInfo(
    product: Product.coins500,
    storeId: 'metre_coins_500',
    titleFa: '۵۰۰ سکه',
    descriptionFa: 'بزرگ‌ترین بسته، بیشترین صرفه',
    priceFa: '۱۲۹٬۰۰۰ تومان',
    coins: 500,
  ),
];

/// What a restore found in the store.
class RestoreResult {
  const RestoreResult({
    this.consumables = const [],
    this.activeSubscriptions = const [],
  });

  /// Paid, already consumed packs that still have to be granted.
  final List<Product> consumables;

  /// Subscriptions that are active in the store right now.
  final List<Product> activeSubscriptions;

  bool get isEmpty => consumables.isEmpty && activeSubscriptions.isEmpty;
}

abstract class PurchaseService {
  Future<PurchaseResult> purchase(Product product);

  Future<RestoreResult> restore();
}

/// Used when no store key is configured. Debug builds simulate a purchase;
/// release builds never grant anything.
class StubPurchaseService implements PurchaseService {
  @override
  Future<PurchaseResult> purchase(Product product) async =>
      kDebugMode ? PurchaseResult.success : PurchaseResult.unavailable;

  @override
  Future<RestoreResult> restore() async => const RestoreResult();
}

import 'package:adivery/adivery.dart';
import 'package:adivery/adivery_ads.dart';
import 'package:flutter/material.dart';

import 'ads.dart';

/// Banner ads from the Adivery network.
///
/// Create the app and a banner placement in the Adivery panel, then pass
/// their ids at build time (see README). Pro members never see ads; that is
/// handled by [AdSlot].
class AdiveryAdService implements AdService {
  AdiveryAdService({required String appId, required this.bannerId}) {
    AdiveryPlugin.initialize(appId);
  }

  final String bannerId;

  @override
  Widget? buildBanner(BuildContext context) =>
      BannerAd(bannerId, BannerAdSize.BANNER);
}

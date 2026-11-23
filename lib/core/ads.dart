import 'package:flutter/material.dart';

import 'economy.dart';

/// Source of advertising banners. The default shows nothing.
abstract class AdService {
  Widget? buildBanner(BuildContext context);
}

class NoAdService implements AdService {
  const NoAdService();

  @override
  Widget? buildBanner(BuildContext context) => null;
}

/// A banner spot. Pro members never see ads, and nothing is shown while no
/// [AdService] provides a banner. It is only placed on the home page and on
/// result screens, never in the middle of play.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    final economy = context.economy;
    if (economy.isPro) return const SizedBox.shrink();
    final banner = economy.ads.buildBanner(context);
    if (banner == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(height: 50, child: banner),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../core/services/ads_service.dart';
import '../../l10n/app_localizations.dart';

/// Offers a short rewarded ad before an action (match result, switching
/// profile, opening another person's chart, exports). True means go ahead.
Future<bool> watchAdToContinue(BuildContext context) {
  final l = AppLocalizations.of(context);
  return AdsService.instance.rewardedGate(
    context,
    title: l.rewardTitle,
    body: l.rewardBody,
    watch: l.rewardWatch,
    notNow: l.rewardNotNow,
  );
}

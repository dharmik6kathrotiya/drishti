import '../../core/astro/chart.dart';
import '../../core/astro/constants.dart';
import '../../core/astro/settings.dart';
import '../../core/astro/vedic/dasha.dart';
import '../../core/astro/vedic/doshas.dart';

/// Why a remedy is traditionally suggested for this chart.
enum SuggestionReason { mahadasha, antardasha, debilitated, sadeSati, manglik }

class RemedySuggestion {
  const RemedySuggestion({required this.reason, this.planet, this.doshaId, this.phase});

  final SuggestionReason reason;

  /// Planet whose remedies apply (for planet-based reasons).
  final Planet? planet;

  /// Dosha remedies id (see RemediesContent.doshas).
  final String? doshaId;
  final int? phase;
}

/// Traditional suggestions for a sidereal [chart] at [now]. The rules are
/// deliberately simple and transparent: running dasha lords, debilitated
/// planets, Sade Sati and (for adults) Mangal dosha.
List<RemedySuggestion> personalRemedySuggestions({
  required Chart chart,
  required DateTime birthUtc,
  required DateTime now,
  required Ayanamsa ayanamsa,
  required bool includeMarriageTopics,
}) {
  final out = <RemedySuggestion>[];
  final running = Vimshottari().runningAt(birthUtc, chart.moon.longitude, now, depth: 2);
  if (running.isNotEmpty) {
    out.add(RemedySuggestion(reason: SuggestionReason.mahadasha, planet: running[0].lord));
  }
  if (running.length > 1 && running[1].lord != running[0].lord) {
    out.add(RemedySuggestion(reason: SuggestionReason.antardasha, planet: running[1].lord));
  }
  for (final p in Planet.vedic) {
    final placement = chart.planets[p];
    if (placement != null && placement.isDebilitated) {
      out.add(RemedySuggestion(reason: SuggestionReason.debilitated, planet: p));
    }
  }
  final ss = Doshas.sadeSati(chart.moon.sign, now, ayanamsa);
  if (ss.running) {
    out.add(
      RemedySuggestion(reason: SuggestionReason.sadeSati, planet: Planet.saturn, doshaId: 'sadeSati', phase: ss.phase),
    );
  }
  if (includeMarriageTopics && Doshas.manglik(chart).present) {
    out.add(const RemedySuggestion(reason: SuggestionReason.manglik, planet: Planet.mars, doshaId: 'manglik'));
  }
  return out;
}

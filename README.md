# Drishti

**Free, honest, open-source astrology for Android and iOS.** Vedic (Jyotish) and Western astrology, calculated entirely on your phone.

- **Accurate:** planetary positions from [Swiss Ephemeris](https://www.astro.com/swisseph/) (NASA JPL based), historical timezones from the IANA database, and an offline database of 170,000+ places.
- **Honest:** every reading shows *why* it says what it says (the rule, the tradition and the source), notes that traditions differ, and never uses fear or guarantees.
- **Free for everyone:** no paid features and no subscriptions. Respectful ads are the only income.
- **Private:** profiles, charts, journal and AI memory stay on the device. There are no accounts and no servers.

## Features

| Area | What's included |
|---|---|
| Profiles | Unlimited profiles. Each needs only a name and unlocks more as you add date, time and place. Unknown birth time is supported, as is birth-time rectification from life events. QR / code sharing goes phone to phone. |
| Vedic | Rashi chart in North, South and East Indian styles; 16 divisional charts (D1–D60); Vimshottari and Yogini dashas; yogas; Mangal dosha, Kaal Sarp and Sade Sati; KP (sub lords, significators, ruling planets, horary); Shadbala and Ashtakavarga; Jaimini (karakas, arudhas, Chara dasha); Lal Kitab. |
| Western | Tropical wheel, 8 house systems, aspects, synastry, progressions, solar and lunar returns, composite. |
| Daily | Personal daily, weekly, monthly and yearly horoscope from real transits (Gochara, Vedha, Tara Bala); Panchang, Choghadiya, Hora, Rahu Kaal; festivals and vrats; Muhurat finder. |
| Matching | Ashtakoot Guna Milan (36 points) with traditional exceptions; Western synastry. |
| AI helper | "Explain this" on every result, plus "Ask Drishti", which answers only from your chart's computed facts. An optional small on-device model can be downloaded; it is not required. |
| More | Numerology, remedies library (information only, never selling), tarot, journal and mood, breathing and meditation, palmistry guide, home-screen widget, opt-in reminders. |
| Languages | English, Hindi, Marathi, Bengali, Tamil, Telugu, Kannada, Malayalam. |
| Themes | Cosmic Night, Traditional, Minimal Light, Pure Black, Lotus. |

Every calculation option (ayanamsa, house system, chart style, node type) can be changed. Each has a short "What's this?" explanation, and the most widely used option is pre-selected and marked **Recommended**.

## Building

Requirements: Flutter (stable, 3.47+), Android SDK 36 and NDK (installed automatically), JDK 17+.

```bash
flutter pub get
flutter test            # 75+ tests, including astronomy accuracy checks
flutter run             # debug on a connected device
flutter build apk --release --target-platform android-arm64
```

Optional build-time settings:

| Setting | How | Default |
|---|---|---|
| AdMob app id (Android) | `ADMOB_APP_ID=...` in `android/local.properties` | Google test id |
| Ad unit ids | `--dart-define=ADMOB_BANNER_ANDROID=... --dart-define=ADMOB_INTERSTITIAL_ANDROID=...` | Google test units |
| Daily feed URL | `--dart-define=FEED_URL=https://<user>.github.io/<repo>/feed/latest.json` | disabled |

### iOS notes

The iOS build is untested so far (it needs a Mac). After the first `pod install`, enable the camera permission for `permission_handler` in `ios/Podfile` → `post_install`:

```ruby
target.build_configurations.each do |config|
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'PERMISSION_CAMERA=1', 'PERMISSION_PHOTOS=1']
end
```

## Project layout

```
lib/
  core/astro/        astronomy and astrology engine (pure Dart, tested)
  core/horoscope/    transit engine and horoscope text generation
  core/ai/           fact sheets, explanations, on-device model runtime
  core/services/     notifications, ads, home-screen widget
  features/          one folder per screen or feature (registered in app/feature_registry.dart)
  l10n/              app_*.arb translations; feature strings live in l10n/fragments/
tool/
  build_places.py    builds assets/geo/places.tsv.gz from GeoNames
  merge_arb.dart     merges feature string fragments into app_en.arb
  feed/              daily feed generator (static JSON for GitHub Pages)
  icon/              renders the app icon
  ai/                training pipeline for the optional on-device model
docs/                market research, product decisions, architecture, privacy policy
```

Adding UI text: put the strings in `lib/l10n/fragments/<feature>.json`, then run `dart run tool/merge_arb.dart && flutter gen-l10n`.

## Licence and credits

Drishti is licensed under the **GNU Affero General Public License v3.0** (see `LICENSE`).

- **Swiss Ephemeris** © Astrodienst AG, used under the AGPL ([sweph](https://pub.dev/packages/sweph) Dart bindings).
- **Places:** [GeoNames](https://www.geonames.org/), CC BY 4.0.
- **Time zones:** IANA tz database.
- **Guna Milan score tables** follow the widely published North Indian tables (as in PyJHora / saravali.de).

The classical texts referenced (BPHS, Phaladeepika and others) are cited by name. Interpretation texts in the app are original writing.

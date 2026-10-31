# Release checklist

## 1. Signing key (Android)

Generate the upload key once and keep it, plus its passwords, backed up somewhere safe. If you lose it you will need Google's key-reset process to ship updates.

```powershell
keytool -genkeypair -v -keystore "$env:USERPROFILE\drishti-upload.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties`. Git ignores this file, and `*.jks` too.

```properties
storeFile=C:/Users/<you>/drishti-upload.jks
storePassword=<store password>
keyAlias=upload
keyPassword=<key password>
```

`android/app/build.gradle.kts` signs release builds with this key whenever the file exists. Without it, release builds fall back to the debug key, which works only for local testing.

Enable **Play App Signing** when you create the app in Play Console. Google then holds the final app-signing key, and your key is only the upload key.

## 2. AdMob ids

Create the app in AdMob, once for Android and once for iOS, and add these ad units to each:

| Setting | Android | iOS |
|---|---|---|
| App id (`~`) | `ADMOB_APP_ID` in `android/local.properties` | `GADApplicationIdentifier` in `ios/Runner/Info.plist` |
| Banner unit (`/`) | `--dart-define=ADMOB_BANNER_ANDROID=...` | `--dart-define=ADMOB_BANNER_IOS=...` |
| Interstitial unit (`/`) | `--dart-define=ADMOB_INTERSTITIAL_ANDROID=...` | `--dart-define=ADMOB_INTERSTITIAL_IOS=...` |
| App open unit (`/`) | `--dart-define=ADMOB_APP_OPEN_ANDROID=...` | `--dart-define=ADMOB_APP_OPEN_IOS=...` |
| Rewarded unit (`/`) | `--dart-define=ADMOB_REWARDED_ANDROID=...` | `--dart-define=ADMOB_REWARDED_IOS=...` |
| Native advanced unit (`/`) | `--dart-define=ADMOB_NATIVE_ANDROID=...` | `--dart-define=ADMOB_NATIVE_IOS=...` |
| Test devices | `ADMOB_TEST_DEVICES` (comma-separated hashed ids from logcat "setTestDeviceIds") | same |

The Android ids are already set: the app id in `android/local.properties` and the four ad units in `config/admob.json`, passed with `--dart-define-from-file=config/admob.json`. Phones listed in `ADMOB_TEST_DEVICES` always get test ads, even with the real units, so the developer's own testing never counts as traffic; add every phone you test on (its id is printed in logcat on the first ad request). Without these ids, the app uses Google's public test ids. Never click your own live ads.

Ad frequency (in `lib/core/services/ads_service.dart`):
- Banners: at the end of Today, Panchang, Match, More, festivals, muhurat, numerology and remedy pages.
- Interstitial: when leaving a chart, tarot reading, festival, muhurat, numerology, composite or remedy page. At most one every 2 minutes and 12 a day.
- App open: when coming back to the app, never on a cold start. At most once an hour and 4 a day.
- Rewarded (opt-in, "Watch a short ad?"): before a match result, switching profile on Today, opening another person's chart, and data or journal exports. After one is watched, none for 10 minutes. If no ad is available, the action goes ahead.
- Never inside Ask Drishti answers or AI explanations.

In AdMob, also do the following:
- Set **Privacy & messaging → GDPR and US state messages**. The app already shows Google's UMP consent form.
- Set the max ad content rating to **PG** for the whole app. Teens additionally get G-rated, non-personalised ads, set in code.
- Publish `app-ads.txt` on the developer website listed in Play Console.

## 3. Build

```powershell
flutter build appbundle --release `
  --dart-define-from-file=config/admob.json
```

Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console. Play then delivers each phone only the code for its own CPU type, so a download is about a third of the universal APK (about 98 MB).

To share APKs outside the Play Store (testers, GitHub releases), build one APK per CPU type instead of one universal APK. Most phones need `app-arm64-v8a-release.apk`.

```powershell
flutter build apk --release --split-per-abi `
  --dart-define-from-file=config/admob.json
```

## 4. AI model

Train, export and evaluate the models as described in `tool/ai/README.md`. Upload each `.gguf` to a GitHub Release tagged `model-v1`. Then fill in the `url`, `sizeBytes` and `sha256` of each entry in `lib/core/ai/model_manager.dart`, and set `languages` to the app languages that model passed in (see "Languages" in `tool/ai/README.md`).

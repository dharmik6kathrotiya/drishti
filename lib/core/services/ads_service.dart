import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ads are the app's only income: banners at the end of lists, an
/// interstitial when leaving a finished screen (at most one every 2 minutes),
/// an app-open ad when returning to the app (at most once an hour), and an
/// opt-in rewarded ad before a few actions (see [AdsService.rewardedGate]). Never
/// inside an AI explanation or while a chart is being read. Teens only ever
/// get non-personalised, G-rated ads.
class AdsService {
  AdsService._();
  static final instance = AdsService._();

  // The app's real AdMob units, so every build (Android Studio or the command
  // line) shows real ads. iOS has no units yet, so it keeps Google's test ids.
  // Any unit can still be overridden with --dart-define.
  static const _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-5828307858131272/9358575644',
  );
  static const _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/2435281174',
  );
  static const _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: 'ca-app-pub-5828307858131272/8045493979',
  );
  static const _interstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );
  static const _appOpenAndroid = String.fromEnvironment(
    'ADMOB_APP_OPEN_ANDROID',
    defaultValue: 'ca-app-pub-5828307858131272/3213511683',
  );
  static const _appOpenIos = String.fromEnvironment(
    'ADMOB_APP_OPEN_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/5575463023',
  );
  static const _rewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: 'ca-app-pub-5828307858131272/2227733071',
  );
  static const _nativeAndroid = String.fromEnvironment(
    'ADMOB_NATIVE_ANDROID',
    defaultValue: 'ca-app-pub-5828307858131272/9481808070',
  );
  static const _nativeIos = String.fromEnvironment(
    'ADMOB_NATIVE_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/3986624511',
  );

  /// Hashed ids of the developers' own phones (comma separated). They get
  /// test ads even with the real units, so testing never counts as traffic.
  static const _testDevices = String.fromEnvironment(
    'ADMOB_TEST_DEVICES',
    defaultValue: 'B89AE5ECF59A2FED57F52ED72C9AA863',
  );
  static const _rewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );

  /// Interstitial frequency caps.
  static const minGap = Duration(minutes: 2);
  static const maxPerDay = 12;

  /// App-open ad caps. It also waits [minGap] after any interstitial.
  static const appOpenGap = Duration(hours: 1);
  static const appOpenMaxPerDay = 4;

  /// After a watched rewarded ad, gated actions run freely for this long.
  static const rewardedUnlock = Duration(minutes: 10);

  /// A loaded app-open ad expires after 4 hours (Google's guidance).
  static const _appOpenTtl = Duration(hours: 4);

  bool _initialised = false;
  bool _canRequest = false;
  bool _teen = false;
  InterstitialAd? _interstitial;
  DateTime? _lastShown;
  int _shownToday = 0;
  DateTime _countDay = DateTime.now();
  AppOpenAd? _appOpen;
  DateTime? _appOpenLoadedAt;
  DateTime? _appOpenShown;
  int _appOpenToday = 0;
  bool _showingFullScreen = false;
  RewardedAd? _rewarded;
  DateTime? _rewardedAt;

  /// Store screenshots are taken with `--dart-define=SCREENSHOT_MODE=true`,
  /// which shows no ads at all.
  static const _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

  bool get supported => !_screenshotMode && !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get enabled => supported && _initialised && _canRequest;

  /// Becomes true once ads may be requested, so slots built before the SDK
  /// and consent are ready can load then.
  final ready = ValueNotifier<bool>(false);

  String get bannerUnit => Platform.isIOS ? _bannerIos : _bannerAndroid;
  String get nativeUnit => Platform.isIOS ? _nativeIos : _nativeAndroid;
  String get _interstitialUnit => Platform.isIOS ? _interstitialIos : _interstitialAndroid;
  String get _appOpenUnit => Platform.isIOS ? _appOpenIos : _appOpenAndroid;
  String get _rewardedUnit => Platform.isIOS ? _rewardedIos : _rewardedAndroid;

  AdRequest get request => AdRequest(nonPersonalizedAds: _teen ? true : null);

  /// Called once after onboarding (so the age group is known).
  Future<void> init({required bool teen}) async {
    if (!supported) return;
    _teen = teen;
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: teen ? MaxAdContentRating.g : MaxAdContentRating.pg,
        ageRestrictedTreatment: teen ? AgeRestrictedTreatment.teen : AgeRestrictedTreatment.unspecified,
        testDeviceIds: [
          for (final id in _testDevices.split(','))
            if (id.trim().isNotEmpty) id.trim(),
        ],
      ),
    );
    if (_initialised) return;
    _canRequest = await _gatherConsent();
    await MobileAds.instance.initialize();
    _initialised = true;
    ready.value = enabled;
    if (_canRequest) {
      _loadInterstitial();
      _loadAppOpen();
      _loadRewarded();
      // Shown when the user comes back to the app, never on a cold start.
      await AppStateEventNotifier.startListening();
      AppStateEventNotifier.appStateStream.listen((s) {
        if (s == AppState.foreground) _maybeShowAppOpen();
      });
    }
  }

  /// Google UMP consent flow (shows a form only where regulations require it).
  Future<bool> _gatherConsent() {
    final done = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(), () async {
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
      done.complete(await ConsentInformation.instance.canRequestAds());
    }, (_) async => done.complete(await ConsentInformation.instance.canRequestAds()));
    return done.future.timeout(const Duration(seconds: 10), onTimeout: () => true);
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialUnit,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedUnit,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  /// Before an action such as a match result, switching profile or an
  /// export: offers a short rewarded ad and returns true once it was watched.
  /// The user may decline (returns false). Never blocks when no ad is
  /// available, ads are off, or one was watched in the last [rewardedUnlock].
  Future<bool> rewardedGate(
    BuildContext context, {
    required String title,
    required String body,
    required String watch,
    required String notNow,
  }) async {
    final ad = _rewarded;
    if (!enabled || ad == null || _showingFullScreen) {
      if (enabled && ad == null) _loadRewarded();
      return true;
    }
    if (_rewardedAt != null && DateTime.now().difference(_rewardedAt!) < rewardedUnlock) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.play_circle_outline),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(notNow)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(watch)),
        ],
      ),
    );
    if (ok != true) return false;
    final done = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _showingFullScreen = false;
        ad.dispose();
        _loadRewarded();
        if (!done.isCompleted) done.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _showingFullScreen = false;
        ad.dispose();
        _loadRewarded();
        // Our failure, not the user's: let the action go ahead.
        if (!done.isCompleted) done.complete(true);
      },
    );
    _rewarded = null;
    _showingFullScreen = true;
    await ad.show(
      onUserEarnedReward: (_, _) {
        earned = true;
        _rewardedAt = DateTime.now();
        // Counts as the latest full-screen ad for the interstitial gap too.
        _lastShown = _rewardedAt;
      },
    );
    return done.future;
  }

  void _rollDay(DateTime now) {
    if (now.day != _countDay.day) {
      _countDay = now;
      _shownToday = 0;
      _appOpenToday = 0;
    }
  }

  void _loadAppOpen() {
    AppOpenAd.load(
      adUnitId: _appOpenUnit,
      request: request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpen = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (_) => _appOpen = null,
      ),
    );
  }

  void _maybeShowAppOpen() {
    if (!enabled || _showingFullScreen) return;
    final now = DateTime.now();
    _rollDay(now);
    final ad = _appOpen;
    if (ad == null) return _loadAppOpen();
    if (now.difference(_appOpenLoadedAt!) > _appOpenTtl) {
      ad.dispose();
      _appOpen = null;
      return _loadAppOpen();
    }
    if (_appOpenToday >= appOpenMaxPerDay ||
        (_appOpenShown != null && now.difference(_appOpenShown!) < appOpenGap) ||
        (_lastShown != null && now.difference(_lastShown!) < minGap)) {
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _showingFullScreen = false;
        ad.dispose();
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _showingFullScreen = false;
        ad.dispose();
        _loadAppOpen();
      },
    );
    _appOpen = null;
    _appOpenShown = now;
    _appOpenToday++;
    _showingFullScreen = true;
    ad.show();
  }

  /// Shows an interstitial at a natural break (e.g. leaving a finished
  /// screen) when the frequency caps allow it. Never awaits the user.
  void maybeShowInterstitial() {
    if (!enabled) return;
    final now = DateTime.now();
    _rollDay(now);
    final ad = _interstitial;
    if (ad == null ||
        _showingFullScreen ||
        _shownToday >= maxPerDay ||
        (_lastShown != null && now.difference(_lastShown!) < minGap)) {
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _showingFullScreen = false;
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _showingFullScreen = false;
        ad.dispose();
        _loadInterstitial();
      },
    );
    _interstitial = null;
    _showingFullScreen = true;
    _lastShown = now;
    _shownToday++;
    ad.show();
  }
}

/// Shows a (frequency-capped) interstitial when the user leaves [child], a
/// finished screen such as a tarot reading or a festival page.
class InterstitialOnLeave extends StatelessWidget {
  const InterstitialOnLeave({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) AdsService.instance.maybeShowInterstitial();
    },
    child: child,
  );
}

/// An adaptive banner placed at the end of a list. Collapses to nothing when
/// ads are unavailable, so layouts never depend on it.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key});

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AdsService.instance.ready.addListener(_onReady);
  }

  void _onReady() {
    if (_ad == null && AdsService.instance.enabled && mounted) _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onReady();
  }

  Future<void> _load() async {
    final width = MediaQuery.sizeOf(context).width.truncate() - 32;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ?? AdSize.banner;
    if (!mounted) return;
    _ad = BannerAd(
      adUnitId: AdsService.instance.bannerUnit,
      size: size,
      request: AdsService.instance.request,
      listener: BannerAdListener(
        onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    AdsService.instance.ready.removeListener(_onReady);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}

/// A native ad in the app's own colours, placed between sections of a long
/// screen. The template marks it as an ad; nothing is shown until an ad has
/// loaded, so layouts never depend on it.
class NativeSlot extends StatefulWidget {
  const NativeSlot({super.key, this.medium = true});

  /// Medium shows a large image; small is a compact row.
  final bool medium;

  @override
  State<NativeSlot> createState() => _NativeSlotState();
}

class _NativeSlotState extends State<NativeSlot> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AdsService.instance.ready.addListener(_onReady);
  }

  void _onReady() {
    if (_ad == null && AdsService.instance.enabled && mounted) _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onReady();
  }

  void _load() {
    final scheme = Theme.of(context).colorScheme;
    NativeTemplateTextStyle text(Color color, double size, {Color? background}) => NativeTemplateTextStyle(
      textColor: color,
      backgroundColor: background,
      style: NativeTemplateFontStyle.normal,
      size: size,
    );
    _ad = NativeAd(
      adUnitId: AdsService.instance.nativeUnit,
      request: AdsService.instance.request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.medium ? TemplateType.medium : TemplateType.small,
        mainBackgroundColor: scheme.surfaceContainer,
        cornerRadius: 16,
        callToActionTextStyle: text(scheme.onPrimary, 15, background: scheme.primary),
        primaryTextStyle: text(scheme.onSurface, 15),
        secondaryTextStyle: text(scheme.onSurfaceVariant, 13),
        tertiaryTextStyle: text(scheme.onSurfaceVariant, 13),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    AdsService.instance.ready.removeListener(_onReady);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    // Template sizes from Google's guidance: medium 320-400, small 90-200.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ConstrainedBox(
        constraints: widget.medium
            ? const BoxConstraints(minWidth: 320, minHeight: 320, maxHeight: 400)
            : const BoxConstraints(minWidth: 320, minHeight: 90, maxHeight: 120),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

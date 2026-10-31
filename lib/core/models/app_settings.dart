import '../astro/settings.dart';
import 'profile.dart';

enum AgeGroup { teen, adult }

enum AppThemeId {
  cosmic('Cosmic Night', 'Deep night sky with gold accents.', recommended: true),
  devotional('Traditional', 'Warm saffron, maroon and gold, inspired by temple art.'),
  minimal('Minimal Light', 'Clean, calm and light.'),
  midnight('Pure Black', 'True black, easy on the eyes and battery (AMOLED).'),
  lotus('Lotus', 'Soft pink and teal, gentle and modern.');

  const AppThemeId(this.label, this.description, {this.recommended = false});
  final String label;
  final String description;
  final bool recommended;
}

/// Notification types. All are off by default; the user opts in.
enum NotificationType {
  dailyHoroscope('Daily horoscope', 'A short reading every morning.'),
  transitAlerts('Important transits', 'When a slow planet changes sign or turns retrograde for you.'),
  festivals('Festivals and vrats', 'Upcoming festivals and fasting days.'),
  rahuKaal('Rahu Kaal', 'A reminder when Rahu Kaal begins for your location.'),
  panchang('Daily Panchang', 'Tithi, nakshatra and auspicious times each morning.');

  const NotificationType(this.label, this.description);
  final String label;
  final String description;
}

class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.ageGroup,
    this.localeCode,
    this.theme = AppThemeId.cosmic,
    this.calc = const CalcSettings(),
    this.chartStyle = ChartStyle.northIndian,
    this.activeProfileId,
    this.notifications = const {},
    this.showDescriptions = true,
    this.panchangPlace,
  });

  final bool onboardingDone;
  final AgeGroup? ageGroup;

  /// Null = follow the device language.
  final String? localeCode;
  final AppThemeId theme;
  final CalcSettings calc;
  final ChartStyle chartStyle;
  final String? activeProfileId;
  final Set<NotificationType> notifications;

  /// Show the small "what's this?" info buttons next to options.
  final bool showDescriptions;

  /// Location used for Panchang and daily timings (defaults to the user's
  /// own birthplace until they choose one).
  final Place? panchangPlace;

  bool get isTeen => ageGroup == AgeGroup.teen;

  AppSettings copyWith({
    bool? onboardingDone,
    AgeGroup? ageGroup,
    String? Function()? localeCode,
    AppThemeId? theme,
    CalcSettings? calc,
    ChartStyle? chartStyle,
    String? Function()? activeProfileId,
    Set<NotificationType>? notifications,
    bool? showDescriptions,
    Place? Function()? panchangPlace,
  }) => AppSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    ageGroup: ageGroup ?? this.ageGroup,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
    theme: theme ?? this.theme,
    calc: calc ?? this.calc,
    chartStyle: chartStyle ?? this.chartStyle,
    activeProfileId: activeProfileId != null ? activeProfileId() : this.activeProfileId,
    notifications: notifications ?? this.notifications,
    showDescriptions: showDescriptions ?? this.showDescriptions,
    panchangPlace: panchangPlace != null ? panchangPlace() : this.panchangPlace,
  );

  Map<String, dynamic> toJson() => {
    'onboardingDone': onboardingDone,
    if (ageGroup != null) 'ageGroup': ageGroup!.name,
    if (localeCode != null) 'locale': localeCode,
    'theme': theme.name,
    'calc': calc.toJson(),
    'chartStyle': chartStyle.name,
    if (activeProfileId != null) 'activeProfile': activeProfileId,
    'notifications': notifications.map((n) => n.name).toList(),
    'showDescriptions': showDescriptions,
    if (panchangPlace != null) 'panchangPlace': panchangPlace!.toJson(),
  };

  factory AppSettings.fromJson(Map json) => AppSettings(
    onboardingDone: (json['onboardingDone'] as bool?) ?? false,
    ageGroup: AgeGroup.values.where((a) => a.name == json['ageGroup']).firstOrNull,
    localeCode: json['locale'] as String?,
    theme: AppThemeId.values.where((t) => t.name == json['theme']).firstOrNull ?? AppThemeId.cosmic,
    calc: json['calc'] is Map ? CalcSettings.fromJson(json['calc'] as Map) : const CalcSettings(),
    chartStyle: ChartStyle.values.where((c) => c.name == json['chartStyle']).firstOrNull ?? ChartStyle.northIndian,
    activeProfileId: json['activeProfile'] as String?,
    notifications: {
      for (final n in (json['notifications'] as List?) ?? const [])
        ...NotificationType.values.where((t) => t.name == n),
    },
    showDescriptions: (json['showDescriptions'] as bool?) ?? true,
    panchangPlace: json['panchangPlace'] is Map ? Place.fromJson(json['panchangPlace'] as Map) : null,
  );
}

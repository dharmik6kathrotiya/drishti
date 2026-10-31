// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navToday => 'Today';

  @override
  String get navKundli => 'Kundli';

  @override
  String get navPanchang => 'Panchang';

  @override
  String get navMatch => 'Match';

  @override
  String get navMore => 'More';

  @override
  String get recommended => 'Recommended';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Share';

  @override
  String get clear => 'Clear';

  @override
  String get reset => 'Reset';

  @override
  String get automatic => 'Automatic';

  @override
  String get notProvided => 'Not provided';

  @override
  String get until => 'until';

  @override
  String get day => 'day';

  @override
  String get me => 'Me';

  @override
  String get present => 'Present';

  @override
  String get notPresent => 'Not present';

  @override
  String get notRunning => 'Not running';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Drishti';

  @override
  String get onboardingWelcomeBody =>
      'Accurate, honest astrology. Free for everyone, and your data stays on your phone.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get ageTitle => 'How old are you?';

  @override
  String get ageBody => 'This keeps the app suitable for you.';

  @override
  String get age18plus => '18 or older';

  @override
  String get age13to17 => '13 to 17';

  @override
  String get ageUnder13 => 'Under 13';

  @override
  String get teenModeInfo => 'Teen mode hides marriage matching and adult topics, and shows only non-personalised ads.';

  @override
  String get under13Message =>
      'Drishti is made for people aged 13 and above. Please ask a parent or guardian to use it with you.';

  @override
  String get systemTitle => 'Which astrology do you follow?';

  @override
  String get systemBody => 'You can switch at any time.';

  @override
  String get systemVedic => 'Vedic (Jyotish)';

  @override
  String get systemVedicInfo => 'Indian sidereal astrology: Kundli, Rashi, Nakshatra, Dasha, Panchang and Guna Milan.';

  @override
  String get systemWestern => 'Western';

  @override
  String get systemWesternInfo => 'Tropical zodiac astrology: Sun sign, birth chart wheel, aspects and transits.';

  @override
  String get changeLaterHint => 'Every setting can be changed later in Settings.';

  @override
  String get themeTitle => 'Pick a look';

  @override
  String get themeBody => 'Choose the theme you like. You can change it any time.';

  @override
  String get profileIntroTitle => 'Create your profile';

  @override
  String get profileIntroBody => 'Add only what you know. Each detail unlocks more.';

  @override
  String get profileIntroName => 'Name: numerology';

  @override
  String get profileIntroDate => 'Date of birth: Moon sign, daily horoscope, dashas';

  @override
  String get profileIntroTime => 'Time of birth: Ascendant, houses and the full Kundli';

  @override
  String get profileIntroPlace => 'Place of birth: exact timezone and accurate houses';

  @override
  String get privacyPromiseTitle => 'Your data stays with you';

  @override
  String get privacyPromise =>
      'Everything is stored only on this phone. Nothing is uploaded unless you choose to share it.';

  @override
  String get createMyProfile => 'Create my profile';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get addProfile => 'Add profile';

  @override
  String get scanProfile => 'Scan a profile';

  @override
  String get scanProfileSubtitle => 'Add a friend\'s profile from their QR code';

  @override
  String get noProfilesTitle => 'No profiles yet';

  @override
  String get noProfilesBody => 'Create profiles for yourself, family and friends. Add only the details you have.';

  @override
  String get onlyName => 'Name only';

  @override
  String get showOnToday => 'Show on Today';

  @override
  String get newProfile => 'New profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteProfileTitle => 'Delete profile?';

  @override
  String deleteProfileBody(String name) {
    return '$name will be removed from this phone.';
  }

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get name => 'Name';

  @override
  String get fullName => 'Full name';

  @override
  String get nameRequired => 'Please enter a name.';

  @override
  String get thisIsMe => 'This is me';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get otherGender => 'Other';

  @override
  String get optionalDetailsHint => 'All details below are optional. Add what you have.';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get birthTime => 'Time of birth';

  @override
  String get birthPlace => 'Place of birth';

  @override
  String get timeExact => 'Exact';

  @override
  String get timeApprox => 'Approximate';

  @override
  String get timezoneAtBirth => 'Timezone at birth';

  @override
  String get advanced => 'Advanced';

  @override
  String get utcOffsetOverride => 'Time zone correction';

  @override
  String get utcOffsetOverrideInfo =>
      'Only needed for old records that used a local time (for example Bombay or Calcutta time before 1955). Leave it on Automatic otherwise.';

  @override
  String get whatYouGet => 'What you\'ll get';

  @override
  String get unlockNameNumerology => 'Name numerology';

  @override
  String get unlockDate => 'Moon sign, nakshatra, dashas and daily horoscope';

  @override
  String get unlockPlace => 'Correct timezone for your birth date';

  @override
  String get unlockFullChart => 'Full Kundli: Lagna, houses, divisional charts and KP';

  @override
  String get unknownTimeNote =>
      'Without a birth time we use a Moon-based chart at noon. The Ascendant and houses are not shown, and the Moon\'s position may be off by a few degrees.';

  @override
  String get noPlaceNote => 'Without a birthplace we cannot calculate the Ascendant and houses.';

  @override
  String get searchPlaceHint => 'Search city, town or village';

  @override
  String get searchPlaceHelp =>
      'Type at least 2 letters. Add a comma to narrow it down, e.g. \"Aurangabad, Maharashtra\". Works offline.';

  @override
  String get noPlacesFound => 'No places found. Try another spelling, or enter coordinates.';

  @override
  String get enterCoordinates => 'Enter coordinates';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get tabChart => 'Chart';

  @override
  String get tabPlanets => 'Planets';

  @override
  String get tabDasha => 'Dasha';

  @override
  String get tabYogas => 'Yogas';

  @override
  String get tabDoshas => 'Doshas';

  @override
  String get tabKp => 'KP';

  @override
  String get needBirthDateTitle => 'Add a birth date';

  @override
  String get needBirthDateBody =>
      'A birth date is needed to calculate a chart. Add a time and place for the full Kundli.';

  @override
  String get addBirthDetails => 'Add birth details';

  @override
  String get partialChartTitle => 'Partial chart';

  @override
  String get chartStyle => 'Chart style';

  @override
  String get keyFacts => 'Key facts';

  @override
  String get lagna => 'Lagna (Ascendant)';

  @override
  String get ascendant => 'Ascendant';

  @override
  String get rashi => 'Rashi (Moon sign)';

  @override
  String get sunSign => 'Sun sign';

  @override
  String get moonSign => 'Moon sign';

  @override
  String get sunSignSidereal => 'Sun sign (sidereal)';

  @override
  String get nakshatra => 'Nakshatra';

  @override
  String get nakshatraLord => 'Nakshatra lord';

  @override
  String get pada => 'Pada';

  @override
  String get ayanamsaLabel => 'Ayanamsa';

  @override
  String get ayanamsaInfo =>
      'The ayanamsa is the offset between the tropical and sidereal zodiac. Different traditions use slightly different values.';

  @override
  String get houseSystem => 'House system';

  @override
  String get nodeType => 'Rahu/Ketu calculation';

  @override
  String get birthDetails => 'Birth details';

  @override
  String get house => 'House';

  @override
  String get planet => 'Planet';

  @override
  String get exalted => 'Exalted';

  @override
  String get debilitated => 'Debilitated';

  @override
  String get ownSign => 'Own sign';

  @override
  String get retrograde => 'retrograde';

  @override
  String get planetsFootnote =>
      'Positions from Swiss Ephemeris (NASA JPL data). Speed is in degrees per day; negative speed means retrograde.';

  @override
  String get runningNow => 'Running now';

  @override
  String get mahadasha => 'Mahadasha';

  @override
  String get antardasha => 'Antardasha';

  @override
  String get pratyantardasha => 'Pratyantardasha';

  @override
  String get dashaApproxNote =>
      'Birth time unknown: dasha dates may be off by several months, because the Moon moves about 13° a day.';

  @override
  String get doshaIntro =>
      'Doshas are traditional indicators, not verdicts. Different schools judge them differently, and most texts also list many cancelling factors.';

  @override
  String get mitigatingFactors => 'Softening factors found';

  @override
  String get sadeSati => 'Sade Sati';

  @override
  String sadeSatiRunning(int phase, String sign) {
    return 'Running now: phase $phase of 3, with Saturn in $sign.';
  }

  @override
  String sadeSatiNotRunning(String sign, int house) {
    return 'Not running. Saturn is in $sign, the ${house}th sign from your Moon.';
  }

  @override
  String sadeSatiPhase(int phase) {
    return 'Phase $phase of 3';
  }

  @override
  String dhaiyaNote(int house) {
    return 'Saturn is transiting the ${house}th from your Moon (Dhaiya, or small panoti), which tradition associates with extra responsibility.';
  }

  @override
  String get sadeSatiPeriods => 'Sade Sati periods';

  @override
  String get sadeSatiSource =>
      'Sade Sati is Saturn\'s transit through the 12th, 1st and 2nd signs from the natal Moon (about 7½ years). Tradition associates it with effort and maturity, not only difficulty.';

  @override
  String get yogasIntro =>
      'Yogas are planetary combinations described in classical texts. Their effects depend on the strength of the planets involved and on the whole chart.';

  @override
  String get noYogasFound => 'None of the yogas we check were found in this chart.';

  @override
  String get kpIntro => 'Krishnamurti Paddhati (KP) uses the KP ayanamsa and Placidus cusps, and focuses on sub lords.';

  @override
  String get kpNeedsTime => 'KP needs an exact birth time and place.';

  @override
  String get kpCusps => 'Cusps';

  @override
  String get kpPlanets => 'Planets';

  @override
  String get kpSignStarSubSub => 'Sign · Star · Sub · Sub-sub';

  @override
  String get kpSignificators => 'House significators';

  @override
  String get kpRulingPlanets => 'Ruling planets now';

  @override
  String kpRulingNote(String place) {
    return 'For this moment at $place. Used in KP horary and to confirm birth time.';
  }

  @override
  String get tithi => 'Tithi';

  @override
  String get yoga => 'Yoga';

  @override
  String get karana => 'Karana';

  @override
  String get lunarMonth => 'Lunar month';

  @override
  String get amanta => 'Amanta';

  @override
  String get purnimanta => 'Purnimanta';

  @override
  String get samvat => 'Samvat';

  @override
  String get sunMoon => 'Sun and Moon';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get moonrise => 'Moonrise';

  @override
  String get moonset => 'Moonset';

  @override
  String get sunriseSunset => 'Sunrise / Sunset';

  @override
  String get timings => 'Auspicious and inauspicious times';

  @override
  String get abhijit => 'Abhijit Muhurta';

  @override
  String get rahuKaal => 'Rahu Kaal';

  @override
  String get yamaganda => 'Yamaganda';

  @override
  String get gulika => 'Gulika Kaal';

  @override
  String get dayChoghadiya => 'Day Choghadiya';

  @override
  String get nightChoghadiya => 'Night Choghadiya';

  @override
  String get hora => 'Hora';

  @override
  String get changePlace => 'Change place';

  @override
  String get todaysPanchang => 'Today\'s Panchang';

  @override
  String get panchangNote =>
      'Calculated on your phone for the chosen place using Swiss Ephemeris and the Lahiri ayanamsa (or your chosen one). Sunrise is taken when the Sun\'s upper edge appears, with standard refraction.';

  @override
  String get matchTitle => 'Kundli Matching';

  @override
  String get matchIntro => 'Choose two profiles. Matching uses the Moon positions of both people.';

  @override
  String get groom => 'Groom';

  @override
  String get bride => 'Bride';

  @override
  String get matchNeedProfilesTitle => 'Add two profiles';

  @override
  String get matchNeedProfilesBody => 'Matching needs at least two profiles with birth dates.';

  @override
  String get matchTeenTitle => 'Available at 18+';

  @override
  String get matchTeenBody => 'Marriage matching is shown only to adults. You can still explore your own chart.';

  @override
  String get kootaDetails => 'Ashtakoot (8 kootas)';

  @override
  String get traditionalExceptions => 'Traditional exceptions';

  @override
  String get manglikComparison => 'Mangal dosha';

  @override
  String get manglikBalanced =>
      'Both charts have the same Mangal dosha status, which is traditionally considered balanced.';

  @override
  String get manglikUnbalanced =>
      'Only one chart has Mangal dosha. Many astrologers check further cancelling factors before drawing conclusions.';

  @override
  String get matchDisclaimer =>
      'Guna Milan is one traditional tool, and point tables vary slightly between almanacs. It cannot predict the success of a relationship. Mutual respect, values and communication matter most.';

  @override
  String get matchApproxNote => 'One or both birth times are unknown, so the result is approximate.';

  @override
  String get synastry => 'Synastry';

  @override
  String get harmoniousAspects => 'Harmonious aspects';

  @override
  String get challengingAspects => 'Challenging aspects';

  @override
  String get conjunctions => 'Conjunctions';

  @override
  String get aspectList => 'Aspects between the charts';

  @override
  String get numerology => 'Numerology';

  @override
  String get numerologySubtitle => 'Life path, destiny, Mulank and Bhagyank';

  @override
  String get numerologyEmpty => 'Enter a name or birth date.';

  @override
  String get numerologyNote =>
      'Numerology is a traditional system of symbolic meanings for numbers. Read it as reflection, not prediction.';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Language, theme, calculation options and privacy';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get astrology => 'Astrology';

  @override
  String get astrologySystem => 'Astrology system';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsInfo => 'All notifications are off by default. Turn on only what you want.';

  @override
  String get privacyData => 'Privacy and data';

  @override
  String get exportData => 'Export my data';

  @override
  String get exportDataInfo => 'Share a backup of all profiles and settings as text';

  @override
  String get importData => 'Import from clipboard';

  @override
  String importedProfiles(int count) {
    return '$count profiles imported';
  }

  @override
  String get importFailed => 'Could not read a backup from the clipboard.';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllDataConfirm => 'This permanently deletes all profiles and settings from this phone.';

  @override
  String get about => 'About Drishti';

  @override
  String get aboutSubtitle => 'Open-source licences and credits';

  @override
  String aboutLegal(String version) {
    return 'Free and open source (AGPL-3.0). Astronomical calculations by Swiss Ephemeris $version © Astrodienst AG. Places from GeoNames (CC BY 4.0).';
  }

  @override
  String get shareProfileTitle => 'Share profile';

  @override
  String shareProfileBody(String name) {
    return 'Let a friend scan this code to add $name\'s birth details. The code goes directly from phone to phone; no server is involved.';
  }

  @override
  String get shareAsText => 'Share as a text code';

  @override
  String shareText(String name, String code) {
    return 'Birth details of $name for the Drishti app:\n$code';
  }

  @override
  String get sharePrivacyNote =>
      'Only the name and birth details are shared. Notes and life events are never included.';

  @override
  String get pasteCode => 'Paste code';

  @override
  String get invalidCode => 'That is not a valid Drishti profile code.';

  @override
  String get welcome => 'Welcome';

  @override
  String get homeNoProfile => 'Create your profile to see your personal horoscope, chart and dashas.';

  @override
  String hello(String name) {
    return 'Namaste, $name';
  }

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get yourChart => 'Your chart';

  @override
  String get currentDasha => 'Current dasha';

  @override
  String get horoscopeTitle => 'Your horoscope';

  @override
  String get pickSignForHoroscope => 'Add a birth date for a personal reading, or pick a sign for a general one:';

  @override
  String get periodDay => 'Today';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get horoscopeUnavailable => 'A horoscope cannot be made with the available details.';

  @override
  String get keyEvents => 'Key sky events';

  @override
  String get whyThisReading => 'Why this reading?';

  @override
  String get horoscopeApproxNote => 'Some birth details are approximate, so parts of this reading are approximate too.';

  @override
  String get changeSign => 'Change sign';

  @override
  String notifPanchangTitle(String vara) {
    return 'Today\'s Panchang · $vara';
  }

  @override
  String get notifRahuKaalTitle => 'Rahu Kaal begins soon';

  @override
  String notifRahuKaalBody(String start, String end) {
    return 'Rahu Kaal today: $start – $end. Traditionally avoided for starting new work.';
  }

  @override
  String notifHoroscopeTitle(String name) {
    return '$name, your day';
  }

  @override
  String get notifTransitTitle => 'Sky update';

  @override
  String notifIngress(String planet, String sign) {
    return '$planet enters $sign today.';
  }

  @override
  String notifRetro(String planet, String sign) {
    return '$planet turns retrograde in $sign.';
  }

  @override
  String notifDirect(String planet, String sign) {
    return '$planet turns direct in $sign.';
  }

  @override
  String get notifFestivalTitle => 'Tomorrow';

  @override
  String notifFestivalBody(String name) {
    return '$name is tomorrow.';
  }

  @override
  String get widgetOpenApp => 'Open Drishti to refresh';

  @override
  String get notificationsDenied =>
      'Notifications are blocked for Drishti. You can allow them in your phone\'s settings.';

  @override
  String get skyNewsTitle => 'From the Drishti team';

  @override
  String feedUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get remedyTitle => 'Remedies';

  @override
  String get remedySubtitle => 'Mantras, charity, fasting and other traditional practices';

  @override
  String get remedyTabForYou => 'For you';

  @override
  String get remedyTabPlanets => 'Planets';

  @override
  String get remedyTabDoshas => 'Doshas';

  @override
  String get remedyTabBooks => 'Books';

  @override
  String get remedyDeity => 'Deity';

  @override
  String get remedyDay => 'Day';

  @override
  String get remedyColour => 'Colour';

  @override
  String get remedyDirection => 'Direction';

  @override
  String get remedyBeejMantra => 'Beej mantra';

  @override
  String get remedyStotra => 'Navagraha Stotra verse';

  @override
  String get remedyJapa => 'Japa count';

  @override
  String get remedyCharity => 'Charity (daan)';

  @override
  String get remedyFasting => 'Fasting';

  @override
  String get remedyGemstone => 'Gemstone (traditional association)';

  @override
  String get remedyUpratna => 'Substitute stones (upratna)';

  @override
  String get remedyRudraksha => 'Rudraksha';

  @override
  String get remedyYantra => 'Yantra';

  @override
  String get remedyLifestyle => 'Conduct and lifestyle';

  @override
  String get remedySignifies => 'Signifies';

  @override
  String get remedyMeaning => 'Meaning';

  @override
  String get remedyNeedProfile =>
      'Add a profile with a birth date to see remedies traditionally linked with your chart.';

  @override
  String remedyReasonDasha(String planet) {
    return 'You are running the $planet mahadasha.';
  }

  @override
  String remedyReasonAntardasha(String planet) {
    return 'You are running the $planet antardasha.';
  }

  @override
  String remedyReasonDebilitated(String planet) {
    return '$planet is debilitated in your chart.';
  }

  @override
  String remedyReasonSadeSati(int phase) {
    return 'Sade Sati is running (phase $phase of 3).';
  }

  @override
  String get remedyReasonManglik => 'Mangal dosha is present by the traditional rule.';

  @override
  String get remedyNoSuggestions =>
      'No specific traditional remedies stand out for your chart right now. General practices such as kindness, discipline and prayer are always considered beneficial.';

  @override
  String get remedyOpenDetails => 'Open details';

  @override
  String get remedySource => 'Source';

  @override
  String get tarotTitle => 'Tarot';

  @override
  String get tarotSubtitle => 'Card of the day and reflective spreads';

  @override
  String get tarotDailyCard => 'Card of the day';

  @override
  String get tarotTapToReveal => 'Tap to reveal';

  @override
  String get tarotUpright => 'Upright';

  @override
  String get tarotReversed => 'Reversed';

  @override
  String get tarotSpreads => 'Spreads';

  @override
  String get tarotSpreadThree => 'Past, present, future';

  @override
  String get tarotSpreadThreeInfo => 'Three cards for reflecting on how a situation has developed.';

  @override
  String get tarotSpreadCeltic => 'Celtic Cross';

  @override
  String get tarotSpreadCelticInfo => 'A ten-card spread for looking at a question in depth.';

  @override
  String get tarotSpreadRelationship => 'Relationship';

  @override
  String get tarotSpreadRelationshipInfo => 'Five cards about you, the other person and the connection between you.';

  @override
  String get tarotQuestionHint => 'Your question (optional)';

  @override
  String get tarotDraw => 'Shuffle and draw';

  @override
  String get tarotHistory => 'Past readings';

  @override
  String get tarotNoHistory => 'Your readings will be saved here, only on this phone.';

  @override
  String get tarotClearHistory => 'Clear history';

  @override
  String get tarotAstrology => 'Astrological attribution';

  @override
  String get tarotPositionPast => 'Past';

  @override
  String get tarotPositionPresent => 'Present';

  @override
  String get tarotPositionFuture => 'Future';

  @override
  String get tarotPositionSituation => 'The situation';

  @override
  String get tarotPositionChallenge => 'The challenge';

  @override
  String get tarotPositionFoundation => 'Foundation';

  @override
  String get tarotPositionRecentPast => 'Recent past';

  @override
  String get tarotPositionPossibility => 'What could be';

  @override
  String get tarotPositionNearFuture => 'Near future';

  @override
  String get tarotPositionSelf => 'You';

  @override
  String get tarotPositionEnvironment => 'Surroundings';

  @override
  String get tarotPositionHopesFears => 'Hopes and fears';

  @override
  String get tarotPositionOutcome => 'Likely direction';

  @override
  String get tarotPositionYou => 'You';

  @override
  String get tarotPositionThem => 'The other person';

  @override
  String get tarotPositionConnection => 'The connection';

  @override
  String get tarotPositionStrength => 'Strength to build on';

  @override
  String get tarotPositionAdvice => 'Advice';

  @override
  String get journalTitle => 'Journal and mood';

  @override
  String get journalSubtitle => 'Track your mood alongside the Moon\'s cycle';

  @override
  String get journalToday => 'How are you today?';

  @override
  String get journalMood => 'Mood';

  @override
  String get journalEnergy => 'Energy';

  @override
  String get journalTags => 'Tags';

  @override
  String get journalNote => 'Note';

  @override
  String get journalNoteHint => 'Anything on your mind?';

  @override
  String get journalSave => 'Save entry';

  @override
  String get journalSaved => 'Saved';

  @override
  String get journalEmpty => 'No entries yet. Add one a day to see patterns over time.';

  @override
  String get journalHistory => 'History';

  @override
  String get journalChart => 'Mood over time';

  @override
  String get journalInsights => 'Insights';

  @override
  String journalInsightsNeedMore(int count, int have) {
    return 'Insights appear after $count entries. You have $have.';
  }

  @override
  String get journalInsightsNote =>
      'These are simple averages from your own entries. A pattern here is a correlation, not proof that the Moon or anything else caused it.';

  @override
  String get journalAvgShukla => 'Average mood in Shukla paksha (waxing Moon)';

  @override
  String get journalAvgKrishna => 'Average mood in Krishna paksha (waning Moon)';

  @override
  String get journalAvgByElement => 'Average mood by the Moon\'s element';

  @override
  String get journalAvgByWeekday => 'Average mood by weekday';

  @override
  String get journalExport => 'Export';

  @override
  String get journalDeleteAll => 'Delete all entries';

  @override
  String get journalDeleteAllConfirm => 'This permanently deletes all journal entries from this phone.';

  @override
  String get journalDeleteEntry => 'Delete entry';

  @override
  String get journalSky => 'Sky that day';

  @override
  String get journalPrivacy => 'Your journal never leaves this phone unless you export it.';

  @override
  String get wellnessMeditationTitle => 'Meditation and breathing';

  @override
  String get wellnessMeditationSubtitle => 'Guided breathing, nadi shodhana and Om chanting';

  @override
  String get wellnessBreathIn => 'Breathe in';

  @override
  String get wellnessBreathOut => 'Breathe out';

  @override
  String get wellnessHold => 'Hold';

  @override
  String get wellnessInLeft => 'In through the left nostril';

  @override
  String get wellnessInRight => 'In through the right nostril';

  @override
  String get wellnessOutLeft => 'Out through the left nostril';

  @override
  String get wellnessOutRight => 'Out through the right nostril';

  @override
  String get wellnessChant => 'Chant Om';

  @override
  String get wellnessStart => 'Start';

  @override
  String get wellnessStop => 'Stop';

  @override
  String wellnessMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get wellnessSessionDone => 'Session complete. Notice how you feel.';

  @override
  String get wellnessPatternBox => 'Box breathing (4-4-4-4)';

  @override
  String get wellnessPatternBoxInfo => 'Equal counts of inhaling, holding, exhaling and holding. Steadies the mind.';

  @override
  String get wellnessPattern478 => '4-7-8 breathing';

  @override
  String get wellnessPattern478Info => 'Inhale for 4, hold for 7, exhale for 8. Often used to relax before sleep.';

  @override
  String get wellnessPatternNadi => 'Nadi shodhana';

  @override
  String get wellnessPatternNadiInfo =>
      'Alternate-nostril breathing from yoga. Close the right nostril with the right thumb to inhale on the left; close the left with the ring finger to exhale on the right; then reverse.';

  @override
  String get wellnessPatternOm => 'Om chanting';

  @override
  String get wellnessPatternOmInfo => 'Inhale deeply, then chant a long \"Ommm\" on the exhale, feeling the vibration.';

  @override
  String wellnessDayTheme(String planet, String theme) {
    return 'Today is ruled by $planet: $theme';
  }

  @override
  String get wellnessHealthNote =>
      'Stop if you feel dizzy or uncomfortable. If you have a medical condition, check with a doctor before breath-holding practices.';

  @override
  String get palmTitle => 'Palm reading guide';

  @override
  String get palmSubtitle => 'A guided, honest self-reading of your hand';

  @override
  String get palmAddPhoto => 'Add a photo of your palm (optional)';

  @override
  String get palmTakePhoto => 'Camera';

  @override
  String get palmChoosePhoto => 'Gallery';

  @override
  String get palmNext => 'Next';

  @override
  String get palmBack => 'Back';

  @override
  String get palmSeeReading => 'See my reading';

  @override
  String get palmReadingTitle => 'Your palm reading';

  @override
  String get palmStartOver => 'Start over';

  @override
  String palmStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get advTabStrength => 'Strength';

  @override
  String get advTabJaimini => 'Jaimini';

  @override
  String get advTabLalKitab => 'Lal Kitab';

  @override
  String get advTabForecast => 'Forecast';

  @override
  String get advNeedsTime => 'This needs an exact birth time and place.';

  @override
  String get advNone => 'None';

  @override
  String get advTotal => 'Total';

  @override
  String get advShadbala => 'Shadbala (six-fold strength)';

  @override
  String get advShadbalaIntro =>
      'Shadbala measures how able each planet is to deliver its results (BPHS ch. 27). The marker shows the classical minimum; a bar beyond it means the planet is considered strong.';

  @override
  String advRupas(String value) {
    return '$value rupas';
  }

  @override
  String advRequired(String value) {
    return 'minimum $value';
  }

  @override
  String advShadbalaParts(String sthana, String dig, String kala, String chesta, String nai, String drik) {
    return 'Sthana $sthana · Dig $dig · Kala $kala · Chesta $chesta · Naisargika $nai · Drik $drik';
  }

  @override
  String get advShadbalaNote =>
      'Calculated in virupas (60 = 1 rupa). Software differs in a few sub-parts (Chesta, Abda/Masa lords, Yuddha); our method choices are listed in the open-source code, so numbers may differ slightly from other programs.';

  @override
  String get advAshtakavarga => 'Ashtakavarga';

  @override
  String get advAshtakavargaIntro =>
      'Benefic points (bindus) each sign receives from the seven planets and the Lagna. Signs with 28 or more points in the Sarvashtakavarga are traditionally considered supportive for transits.';

  @override
  String get advSav => 'Sarvashtakavarga';

  @override
  String get advBav => 'Bhinnashtakavarga';

  @override
  String get advJaiminiIntro =>
      'Jaimini astrology uses movable significators (chara karakas), arudha padas and sign-based dashas.';

  @override
  String get advKarakas => 'Chara karakas';

  @override
  String get advKarakaScheme8 => '8-karaka scheme (include Rahu)';

  @override
  String get advKarakamsa => 'Karakamsa (navamsa of the Atmakaraka)';

  @override
  String get advArudhas => 'Arudha padas';

  @override
  String get advArudhaLagna => 'Arudha Lagna (AL)';

  @override
  String get advUpapada => 'Upapada (UL)';

  @override
  String get advCharaDasha => 'Chara dasha';

  @override
  String get advCharaDashaNote =>
      'Method of K.N. Rao: the direction follows the 9th sign from the Lagna; years are counted from each sign to its lord. Other Chara dasha variants exist.';

  @override
  String advYears(int count) {
    return '$count years';
  }

  @override
  String get advLalKitabIntro =>
      'In Lal Kitab the signs are fixed to the houses (Aries = 1st house) and each planet sits in the house of its sign. Meanings below are short summaries of the Lal Kitab tradition.';

  @override
  String get advPakkaGhar => 'In pakka ghar (permanent house)';

  @override
  String get advSleepingHouses => 'Sleeping houses';

  @override
  String get advSleepingNote =>
      'Simplified rule: an empty house that is not aspected from the opposite house. Lal Kitab commentators use further aspect rules.';

  @override
  String get advVarshphalNote =>
      'Lal Kitab Varshphal (annual chart) is not included yet: we only publish tables we have verified against a primary source.';

  @override
  String advHouseN(int house) {
    return 'House $house';
  }

  @override
  String get advProgressions => 'Secondary progressions';

  @override
  String get advProgressionsNote =>
      'A day after birth stands for a year of life. The MC is moved by the solar arc and the Ascendant derived from it.';

  @override
  String get advForDate => 'For date';

  @override
  String get advSolarReturn => 'Solar return';

  @override
  String get advSolarReturnNote =>
      'The chart for the moment the Sun returns to its birth position each year, cast for the birthplace.';

  @override
  String get advYear => 'Year';

  @override
  String advReturnMoment(String time) {
    return 'Exact return: $time';
  }

  @override
  String get advLunarReturn => 'Next lunar return';

  @override
  String get advComposite => 'Composite chart';

  @override
  String get advCompositeSubtitle => 'Midpoint chart of a relationship';

  @override
  String get advCompositeIntro =>
      'A composite chart places every planet at the midpoint between two people\'s positions. Western astrologers read it as the chart of the relationship itself.';

  @override
  String get advPersonA => 'First person';

  @override
  String get advPersonB => 'Second person';

  @override
  String get advCompositeNeedProfiles => 'Add at least two profiles with birth dates to make a composite chart.';

  @override
  String get advPositions => 'Positions';

  @override
  String get aiAskTitle => 'Ask Drishti';

  @override
  String get aiAskSubtitle => 'Questions about your chart, answered from its calculations';

  @override
  String get aiAskHint => 'Ask about career, studies, relationships…';

  @override
  String get aiSend => 'Send';

  @override
  String get aiStop => 'Stop';

  @override
  String get aiBasedOn => 'Based on';

  @override
  String get aiNotes => 'Please note';

  @override
  String get aiImproveWith => 'Make this more accurate';

  @override
  String get aiNoProfile => 'Create a profile with a birth date to ask questions about a chart.';

  @override
  String aiProfileFor(String name) {
    return 'Answers for $name';
  }

  @override
  String get aiRuleMode =>
      'Answers come from Drishti\'s built-in rules, which work offline on every phone. Download the on-phone AI model for conversational answers.';

  @override
  String get aiModelMode => 'Using the on-phone AI model. Every answer is checked against your calculated chart.';

  @override
  String get aiReplaced =>
      'The AI\'s draft did not pass Drishti\'s safety and accuracy check, so the rule-based answer is shown instead.';

  @override
  String get aiLoadFailed => 'The AI model could not be loaded on this phone, so rule-based answers are used.';

  @override
  String get aiExplain => 'Explain';

  @override
  String get aiAskMore => 'Ask more';

  @override
  String get aiSource => 'Source';

  @override
  String get aiTryAsking => 'Try asking';

  @override
  String get aiSuggestCareer => 'How does my chart look for career?';

  @override
  String get aiSuggestPersonality => 'What does my chart say about my nature?';

  @override
  String get aiSuggestPeriod => 'What does my current dasha mean?';

  @override
  String get aiSuggestStudies => 'When is a good period for studies?';

  @override
  String get aiHistory => 'Previous questions';

  @override
  String get aiModelTitle => 'On-phone AI model';

  @override
  String get aiModelSubtitle => 'Download, use or remove the AI model';

  @override
  String get aiModelIntro =>
      'The AI model runs entirely on your phone. Nothing you ask is sent anywhere. Without it, Drishti still answers using its built-in rules.';

  @override
  String get aiNotReleased => 'Not released yet';

  @override
  String get aiDownload => 'Download';

  @override
  String aiDownloading(String percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get aiPause => 'Pause';

  @override
  String get aiResume => 'Resume';

  @override
  String get aiDelete => 'Remove';

  @override
  String get aiInstalled => 'Installed';

  @override
  String get aiUse => 'Use this model';

  @override
  String get aiInUse => 'In use';

  @override
  String get aiStopUsing => 'Stop using';

  @override
  String get aiWifiOnly => 'Download only on Wi‑Fi';

  @override
  String aiMinRam(int gb) {
    return 'Needs about $gb GB of RAM';
  }

  @override
  String aiLicense(String license) {
    return 'Licence: $license';
  }

  @override
  String get aiMemoryTitle => 'AI memory';

  @override
  String get aiMemorySubtitle => 'See or delete what Drishti remembers';

  @override
  String get aiMemoryEmpty => 'Nothing remembered yet.';

  @override
  String get aiLifeFacts => 'Things you told Drishti';

  @override
  String get aiLifeFactsInfo =>
      'Optional notes (e.g. \"I work in teaching\") that help answers. Stored only on this phone.';

  @override
  String get aiAddLifeFact => 'Add a note';

  @override
  String get aiLifeFactHint => 'e.g. I am studying engineering';

  @override
  String get aiClearHistory => 'Clear this profile\'s memory';

  @override
  String get aiClearAll => 'Clear all AI memory';

  @override
  String get aiClearConfirm => 'This deletes the remembered questions and notes from this phone.';

  @override
  String get aiCancel => 'Cancel';

  @override
  String get aiConfirm => 'Delete';

  @override
  String get aiAdd => 'Add';

  @override
  String get rectTitle => 'Birth time rectification';

  @override
  String get rectSubtitle => 'Estimate an uncertain birth time from life events';

  @override
  String get rectIntro =>
      'If you know your birth time only roughly, Drishti can check which times in a range fit your major life events best, using traditional dasha and transit rules.';

  @override
  String get rectNeedsDatePlace => 'Rectification needs a birth date and birthplace in this profile.';

  @override
  String get rectChooseProfile => 'Profile';

  @override
  String get rectWindow => 'Possible birth time range';

  @override
  String get rectFrom => 'From';

  @override
  String get rectTo => 'To';

  @override
  String get rectEvents => 'Life events';

  @override
  String get rectEventsInfo => 'Add dated events you are sure about. Three or more give more meaningful results.';

  @override
  String get rectAddEvent => 'Add event';

  @override
  String get rectNoEvents => 'No events added yet.';

  @override
  String get rectEventType => 'Event';

  @override
  String get rectEventDate => 'Date';

  @override
  String get rectEventNote => 'Note (optional)';

  @override
  String get rectSaveEvent => 'Save event';

  @override
  String get rectRun => 'Find consistent times';

  @override
  String get rectRunning => 'Checking possible birth times…';

  @override
  String get rectResults => 'Time ranges that fit best';

  @override
  String rectScore(String score) {
    return 'Fit score $score';
  }

  @override
  String rectLagnas(String d1, String d9, String d10) {
    return 'Lagna $d1 · Navamsa $d9 · Dasamsa $d10';
  }

  @override
  String rectApply(String time) {
    return 'Use $time';
  }

  @override
  String rectApplied(String time) {
    return 'Birth time set to $time and marked approximate.';
  }

  @override
  String get rectCaveat =>
      'Rectification is an estimate based on traditional rules, not a measurement. Different astrologers use different methods and may reach different times. Prefer a recorded birth time (hospital or family records) whenever you have one.';

  @override
  String get rectNoMatch => 'No reasons found for this event at this time.';

  @override
  String get rectEventMarriage => 'Marriage';

  @override
  String get rectEventChildBirth => 'Birth of a child';

  @override
  String get rectEventJobStart => 'Started a job';

  @override
  String get rectEventJobLoss => 'Left or lost a job';

  @override
  String get rectEventRelocation => 'Moved home or city';

  @override
  String get rectEventAccident => 'Accident';

  @override
  String get rectEventIllness => 'Illness';

  @override
  String get rectEventParentDeath => 'Loss of a parent';

  @override
  String get rectEventEducation => 'Education milestone';

  @override
  String get rectEventOther => 'Other';

  @override
  String get festTitle => 'Festivals & Vrats';

  @override
  String get festSubtitle => 'Festivals, Ekadashis, sankrantis and eclipses for your place';

  @override
  String get festAll => 'All';

  @override
  String get festFestivals => 'Festivals';

  @override
  String get festVrats => 'Vrats';

  @override
  String get festSankrantis => 'Sankrantis';

  @override
  String get festEclipses => 'Eclipses';

  @override
  String get festNoEventsDay => 'No festivals or vrats on this day.';

  @override
  String get festNoEventsMonth => 'Nothing matches this filter in this month.';

  @override
  String get festHowDecided => 'How this date was decided';

  @override
  String get festRegionalNote => 'Regional and family traditions';

  @override
  String get festTimings => 'Timings';

  @override
  String festTithiSpan(String start, String end) {
    return 'Tithi: $start to $end';
  }

  @override
  String festWindow(String start, String end) {
    return 'Observance window: $start to $end';
  }

  @override
  String festMoment(String time) {
    return 'Exact moment: $time';
  }

  @override
  String festCalculatedFor(String place) {
    return 'Calculated for $place';
  }

  @override
  String get festDisclaimer =>
      'Dates follow the common North Indian (Smarta) panchang rules for the chosen place. Your family, temple or regional tradition may observe some days differently; both are valid.';

  @override
  String get festToday => 'Today';

  @override
  String get festLoading => 'Calculating the calendar on your phone…';

  @override
  String get festOpenMuhurat => 'Muhurat finder';

  @override
  String get muhuratTitle => 'Muhurat Finder';

  @override
  String get muhuratSubtitle => 'Auspicious times for important beginnings';

  @override
  String get muhuratActivity => 'Activity';

  @override
  String get muhuratFrom => 'From';

  @override
  String get muhuratTo => 'To';

  @override
  String get muhuratPersonalise => 'Personalise for';

  @override
  String get muhuratGeneral => 'General (no profile)';

  @override
  String get muhuratPersonaliseInfo =>
      'With a profile, Tara Bala and Chandra Bala (how the day\'s Moon relates to the birth Moon) are added to the checks.';

  @override
  String get muhuratFind => 'Find muhurats';

  @override
  String get muhuratSearching => 'Searching day by day…';

  @override
  String get muhuratNoResults =>
      'No window met all the rules in this range. Try a longer range or relax the seasonal rules.';

  @override
  String muhuratResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count windows found',
      one: '1 window found',
    );
    return '$_temp0';
  }

  @override
  String muhuratScore(int score) {
    return 'Score $score/100';
  }

  @override
  String get muhuratRangeTooLong => 'Please choose a range of up to 180 days.';

  @override
  String get muhuratRulesMet => 'Rules met';

  @override
  String get muhuratRulesMissed => 'Rules not met';

  @override
  String get muhuratDisclaimer =>
      'This follows general Panchang-shuddhi rules found in muhurta texts and popular panchangs. Lists of favourable days differ between traditions, and important ceremonies are often fixed together with a family priest or astrologer.';

  @override
  String get muhuratAvoidKharmas => 'Avoid Kharmas';

  @override
  String get muhuratAvoidKharmasInfo =>
      'When the Sun is in sidereal Sagittarius or Pisces (about mid-December to mid-January and mid-March to mid-April), many traditions pause weddings and similar ceremonies.';

  @override
  String get muhuratAvoidCombust => 'Avoid Guru/Shukra asta';

  @override
  String get muhuratAvoidCombustInfo =>
      'When Jupiter or Venus is too close to the Sun (combust), they are traditionally considered too weak for weddings and house-warming.';

  @override
  String get muhuratAvoidChaturmas => 'Avoid Chaturmas';

  @override
  String get muhuratAvoidChaturmasInfo =>
      'From Devshayani to Prabodhini Ekadashi, North Indian practice usually avoids weddings and house-warming. Many South Indian traditions do not follow this.';

  @override
  String get muhuratActMarriage => 'Marriage';

  @override
  String get muhuratActGrihaPravesh => 'Griha Pravesh (house-warming)';

  @override
  String get muhuratActVehicle => 'Vehicle purchase';

  @override
  String get muhuratActProperty => 'Property purchase';

  @override
  String get muhuratActBusiness => 'Starting a business';

  @override
  String get muhuratActTravel => 'Travel';

  @override
  String get muhuratActNaming => 'Naming ceremony (Namakarana)';

  @override
  String get muhuratActMundan => 'Mundan (first haircut)';

  @override
  String get muhuratActEducation => 'Starting education (Vidyarambha)';

  @override
  String muhuratChkNakshatra(String value) {
    return 'Favourable nakshatra: $value';
  }

  @override
  String muhuratChkTithi(String value) {
    return 'Favourable tithi: $value';
  }

  @override
  String muhuratChkVara(String value) {
    return 'Favourable weekday: $value';
  }

  @override
  String muhuratChkYoga(String value) {
    return 'Yoga not on the avoid list: $value';
  }

  @override
  String get muhuratChkVyatipata => 'Not Vyatipata or Vaidhriti yoga';

  @override
  String get muhuratChkVishti => 'Not Vishti (Bhadra) karana';

  @override
  String get muhuratChkRahuKaal => 'Outside Rahu Kaal';

  @override
  String get muhuratChkYamaganda => 'Outside Yamaganda';

  @override
  String get muhuratChkGulika => 'Outside Gulika Kaal';

  @override
  String get muhuratChkEclipse => 'Not an eclipse day';

  @override
  String get muhuratChkKharmas => 'Not in Kharmas';

  @override
  String get muhuratChkCombustJupiter => 'Jupiter not combust';

  @override
  String get muhuratChkCombustVenus => 'Venus not combust';

  @override
  String get muhuratChkChaturmas => 'Not in Chaturmas';

  @override
  String muhuratChkTara(String value) {
    return 'Tara Bala: $value';
  }

  @override
  String muhuratChkChandra(String value) {
    return 'Chandra Bala: Moon in house $value from the birth Moon';
  }

  @override
  String get wellnessThemeSun => 'steady confidence; try a sunrise practice';

  @override
  String get wellnessThemeMoon => 'calm and soothing; try 4-7-8 breathing';

  @override
  String get wellnessThemeMars => 'energy and courage; try box breathing';

  @override
  String get wellnessThemeMercury => 'clarity and focus; try nadi shodhana';

  @override
  String get wellnessThemeJupiter => 'gratitude and wisdom; try Om chanting';

  @override
  String get wellnessThemeVenus => 'gentleness and harmony; try 4-7-8 breathing';

  @override
  String get wellnessThemeSaturn => 'patience and grounding; try a longer box breathing session';

  @override
  String untilDate(String date) {
    return 'until $date';
  }

  @override
  String get advKarakaAK => 'Atmakaraka';

  @override
  String get advKarakaAmK => 'Amatyakaraka';

  @override
  String get advKarakaBK => 'Bhratrikaraka';

  @override
  String get advKarakaMK => 'Matrikaraka';

  @override
  String get advKarakaPiK => 'Pitrikaraka';

  @override
  String get advKarakaPK => 'Putrakaraka';

  @override
  String get advKarakaGK => 'Gnatikaraka';

  @override
  String get advKarakaDK => 'Darakaraka';

  @override
  String fromTime(String time) {
    return 'From $time';
  }

  @override
  String toTime(String time) {
    return 'To $time';
  }

  @override
  String aiModelLanguages(String languages) {
    return 'AI answers in: $languages. In other languages Drishti uses its built-in explanations.';
  }

  @override
  String get aiWifiOnlyInfo => 'Large downloads start only on Wi‑Fi. On mobile data, Drishti asks you first.';

  @override
  String get aiNotOnWifiTitle => 'Not on Wi‑Fi';

  @override
  String aiNotOnWifiBody(String size) {
    return '“Download only on Wi‑Fi” is on and this phone is not on Wi‑Fi. About $size would use your mobile data. Download anyway?';
  }

  @override
  String get aiDownloadAnyway => 'Download anyway';

  @override
  String get rewardTitle => 'Watch a short ad?';

  @override
  String get rewardBody =>
      'Drishti is free for everyone because of ads. Watch a short ad to continue. After that, there are no more of these for 10 minutes.';

  @override
  String get rewardWatch => 'Watch ad';

  @override
  String get rewardNotNow => 'Not now';

  @override
  String get rewardShowResult => 'Show match result';

  @override
  String get aiMoreDetail => 'More detail';

  @override
  String get aiWhy => 'Why? (chart reasons)';

  @override
  String get dashaComingNext => 'Coming next';

  @override
  String get dashaMonthByMonth => 'Month by month';

  @override
  String dashaFromDate(String date) {
    return 'from $date';
  }

  @override
  String get dashaMonthNote =>
      'Each line is a period running in that month: Mahadasha / Antardasha / Pratyantardasha. Tap 💡 for what it traditionally means.';

  @override
  String get matchWhatItMeans => 'What it means for you';

  @override
  String get matchAreaVarna => 'Values and outlook';

  @override
  String get matchAreaVashya => 'Mutual attraction and influence';

  @override
  String get matchAreaTara => 'Wellbeing and fortune together';

  @override
  String get matchAreaYoni => 'Physical and intimate compatibility';

  @override
  String get matchAreaMaitri => 'Friendship and understanding';

  @override
  String get matchAreaGana => 'Temperament';

  @override
  String get matchAreaBhakoot => 'Family welfare and growth';

  @override
  String get matchAreaNadi => 'Health and children (traditional view)';

  @override
  String matchLevelGood(String area) {
    return '$area: matches well by tradition.';
  }

  @override
  String matchLevelPart(String area) {
    return '$area: partly matches.';
  }

  @override
  String matchLevelLow(String area) {
    return '$area: tradition sees a gap here, so it asks for more understanding and effort.';
  }

  @override
  String get numeroTapForDetails => 'Tap to see how it is calculated and what it means';

  @override
  String get numeroHowCalculated => 'How it is calculated';

  @override
  String get numeroWhatItMeans => 'What it means';

  @override
  String get numeroRepresents => 'What this number represents';

  @override
  String get numeroStrengths => 'Strengths';

  @override
  String get numeroChallenges => 'Challenges';

  @override
  String get numeroGuidance => 'Guidance';

  @override
  String numeroPlanetLine(String planet) {
    return 'Traditional planet: $planet';
  }

  @override
  String get numeroPartMonth => 'Month';

  @override
  String get numeroPartDay => 'Day';

  @override
  String get numeroPartYear => 'Year';

  @override
  String get numeroPartCurrentYear => 'Current year';

  @override
  String get numeroPartSum => 'Add them';

  @override
  String get numeroPartDateDigits => 'All digits of the date';

  @override
  String get numeroPartLetters => 'All letters';

  @override
  String get numeroPartVowels => 'Vowels (A, E, I, O, U)';

  @override
  String get numeroPartConsonants => 'Consonants (Y is counted as a consonant)';

  @override
  String get numeroLetterTablePy => 'Pythagorean letter values';

  @override
  String get numeroLetterTableCh => 'Chaldean letter values';

  @override
  String numeroMasterKept(int number) {
    return '$number is a master number, so it is kept as it is.';
  }

  @override
  String get numeroAlwaysReduced => 'This number is always reduced to a single digit; master numbers are not kept.';

  @override
  String numeroResult(int number) {
    return 'Result: $number';
  }

  @override
  String get numeroCombinations => 'Combinations';

  @override
  String get numeroPairTitle => 'Mulank and Bhagyank pair';

  @override
  String numeroPairNumbers(int mulank, String mulankPlanet, int bhagyank, String bhagyankPlanet) {
    return 'Mulank $mulank ($mulankPlanet) and Bhagyank $bhagyank ($bhagyankPlanet)';
  }

  @override
  String numeroViewLine(String from, String to, String relation) {
    return '$from → $to: $relation';
  }

  @override
  String get numeroRelFriend => 'friend';

  @override
  String get numeroRelNeutral => 'neutral';

  @override
  String get numeroRelEnemy => 'enemy';

  @override
  String get numeroPairSame => 'Same number';

  @override
  String get numeroPairFriendly => 'Friendly';

  @override
  String get numeroPairNeutral => 'Neutral';

  @override
  String get numeroPairChallenging => 'Challenging';

  @override
  String get numeroLoShuTitle => 'Lo Shu grid';

  @override
  String get numeroLoShuAddMB => 'Add Mulank and Bhagyank (usual Indian practice)';

  @override
  String numeroLoShuDigits(String digits) {
    return 'Digits placed: $digits';
  }

  @override
  String get numeroLoShuRepeated => 'Repeated numbers';

  @override
  String get numeroLoShuMissing => 'Missing numbers';

  @override
  String get numeroLoShuPlanes => 'Complete planes';

  @override
  String get numeroLoShuNoRepeated => 'No number repeats.';

  @override
  String get numeroLoShuNoMissing => 'Every number from 1 to 9 is present.';

  @override
  String get numeroLoShuNoPlanes => 'No row, column or diagonal is complete.';

  @override
  String get numeroCompoundTitle => 'Chaldean compound number';

  @override
  String numeroCompoundReduced(int total, int compound) {
    return 'Your total $total is above 52, so its digits are added: $compound.';
  }

  @override
  String get numeroPersonalTitle => 'Personal year, month and day';

  @override
  String numeroPersonalFor(String date) {
    return 'For $date';
  }

  @override
  String get numeroPersonalYear => 'Personal year';

  @override
  String get numeroPersonalMonth => 'Personal month';

  @override
  String get numeroPersonalDay => 'Personal day';

  @override
  String get numeroAboutTitle => 'About these methods';

  @override
  String get numeroNeedDate =>
      'Enter a birth date to see the Lo Shu grid, the Mulank and Bhagyank pair and your personal cycles.';

  @override
  String get numeroNameLatinOnly =>
      'Name numbers use the letters A to Z. Type the name in English letters to see them.';

  @override
  String get numeroCompoundNone =>
      'This total does not give a compound number between 10 and 52, so only the single digit is read.';

  @override
  String get toolInfoTooltip => 'About this tool';

  @override
  String get toolInfoWhat => 'What it is';

  @override
  String get toolInfoWhy => 'Why it is used';

  @override
  String get toolInfoHow => 'How it works';

  @override
  String get toolInfoScience => 'Math and science';

  @override
  String get toolInfoReferences => 'References';

  @override
  String get kootaWhatItIs => 'What it is';

  @override
  String get kootaYourResult => 'Your result';

  @override
  String get kootaExceptionsChecked => 'Classical exceptions checked';

  @override
  String get kootaApplies => 'applies';

  @override
  String get kootaNotApplies => 'does not apply';

  @override
  String get kootaTapHint => 'Tap any line to see what it is, your result and why.';

  @override
  String get compConclusion => 'What it means for you';

  @override
  String get compAspectsTitle => 'Aspects in the composite chart';

  @override
  String get compSupportive => 'supportive';

  @override
  String get compChallenging => 'challenging';

  @override
  String get compNotCounted => 'not counted';

  @override
  String get yogaWhatFor => 'What it is for';

  @override
  String get palmTraceButton => 'Trace the lines on my photo';

  @override
  String get palmTraceTitle => 'Trace your palm lines';

  @override
  String get palmTapIndex => 'Step 1 of 3: tap the base of your index finger (where it joins the palm).';

  @override
  String get palmTapLittle => 'Step 2 of 3: tap the base of your little finger.';

  @override
  String get palmTapWrist => 'Step 3 of 3: tap the middle of your wrist.';

  @override
  String palmTraceLine(String line) {
    return 'Trace your $line with one finger over the photo. The dotted line shows where it usually runs; follow your own line. Lift your finger where the line breaks.';
  }

  @override
  String get palmUndo => 'Undo';

  @override
  String get palmCantSee => 'I can\'t see this line';

  @override
  String get palmUseTracing => 'Use my tracing';

  @override
  String get palmTraceNote =>
      'Drishti suggests the hand points and lines it finds in your photo. They can be wrong, so check each one and redraw any that does not match. The photo stays on your phone. Palmistry is a symbolic tradition, not a prediction.';

  @override
  String get palmSuggested =>
      'Suggested from your tracing. Compare it with your hand and change it if it does not match.';

  @override
  String get palmDetecting => 'Looking for your hand and palm lines in the photo…';

  @override
  String get palmHandNotFound =>
      'Could not find a hand in this photo. Tap the three points yourself, or use a clear photo of an open palm in good light.';

  @override
  String palmAutoLine(String line) {
    return 'Drishti found your $line (shown in colour). Check that it follows the crease in your photo. If it does not, tap Undo or simply draw over it.';
  }

  @override
  String palmAutoMissing(String line) {
    return 'Drishti could not find your $line clearly. Trace it with one finger, or tap “I can\'t see this line”.';
  }

  @override
  String get childrenTitle => 'Children (Santana)';

  @override
  String get childrenSubtitle => 'Signs and timing for children, for one person or a couple';

  @override
  String get childrenIntro =>
      'A traditional Vedic reading of children: the 5th house, Jupiter, the Saptamsha (D7) and the dasha periods. For a couple it adds the classical Beeja and Kshetra Sphuta.';

  @override
  String get childrenOne => 'One person';

  @override
  String get childrenCouple => 'Couple';

  @override
  String get childrenPerson => 'Person';

  @override
  String get childrenFather => 'Father-to-be';

  @override
  String get childrenMother => 'Mother-to-be';

  @override
  String get childrenNeedProfiles => 'Add a profile with a birth date first.';

  @override
  String get childrenNeedTwo => 'Add a second profile to read a couple.';

  @override
  String get childrenAdultsOnly => 'This reading is available for adults only.';

  @override
  String get childrenWindows => 'Periods the method marks for children';

  @override
  String get childrenSharedWindows => 'Periods marked for both of you';

  @override
  String get childrenApproxNote =>
      'Without a birth time, houses are counted from the Moon sign and the Moon\'s position is approximate.';

  @override
  String get childrenTradTitle => 'Boy or girl? What the old texts say';

  @override
  String get childrenTradSubtitle => 'History and science, with no prediction';

  @override
  String get matchAdviceTitle => 'Overall advice';

  @override
  String get matchAdviceStrengths => 'What is strong';

  @override
  String get matchAdviceCautions => 'What needs care';

  @override
  String get matchAdviceSteps => 'What you can do';

  @override
  String get matchAdviceRemedies => 'Traditional remedies (optional)';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navKundli.
  ///
  /// In en, this message translates to:
  /// **'Kundli'**
  String get navKundli;

  /// No description provided for @navPanchang.
  ///
  /// In en, this message translates to:
  /// **'Panchang'**
  String get navPanchang;

  /// No description provided for @navMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get navMatch;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @whatsThis.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatsThis;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get until;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @notPresent.
  ///
  /// In en, this message translates to:
  /// **'Not present'**
  String get notPresent;

  /// No description provided for @notRunning.
  ///
  /// In en, this message translates to:
  /// **'Not running'**
  String get notRunning;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Drishti'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Accurate, honest astrology. Free for everyone, and your data stays on your phone.'**
  String get onboardingWelcomeBody;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @ageTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get ageTitle;

  /// No description provided for @ageBody.
  ///
  /// In en, this message translates to:
  /// **'This keeps the app suitable for you.'**
  String get ageBody;

  /// No description provided for @age18plus.
  ///
  /// In en, this message translates to:
  /// **'18 or older'**
  String get age18plus;

  /// No description provided for @age13to17.
  ///
  /// In en, this message translates to:
  /// **'13 to 17'**
  String get age13to17;

  /// No description provided for @ageUnder13.
  ///
  /// In en, this message translates to:
  /// **'Under 13'**
  String get ageUnder13;

  /// No description provided for @teenModeInfo.
  ///
  /// In en, this message translates to:
  /// **'Teen mode hides marriage matching and adult topics, and shows only non-personalised ads.'**
  String get teenModeInfo;

  /// No description provided for @under13Message.
  ///
  /// In en, this message translates to:
  /// **'Drishti is made for people aged 13 and above. Please ask a parent or guardian to use it with you.'**
  String get under13Message;

  /// No description provided for @systemTitle.
  ///
  /// In en, this message translates to:
  /// **'Which astrology do you follow?'**
  String get systemTitle;

  /// No description provided for @systemBody.
  ///
  /// In en, this message translates to:
  /// **'You can switch at any time.'**
  String get systemBody;

  /// No description provided for @systemVedic.
  ///
  /// In en, this message translates to:
  /// **'Vedic (Jyotish)'**
  String get systemVedic;

  /// No description provided for @systemVedicInfo.
  ///
  /// In en, this message translates to:
  /// **'Indian sidereal astrology: Kundli, Rashi, Nakshatra, Dasha, Panchang and Guna Milan.'**
  String get systemVedicInfo;

  /// No description provided for @systemWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get systemWestern;

  /// No description provided for @systemWesternInfo.
  ///
  /// In en, this message translates to:
  /// **'Tropical zodiac astrology: Sun sign, birth chart wheel, aspects and transits.'**
  String get systemWesternInfo;

  /// No description provided for @changeLaterHint.
  ///
  /// In en, this message translates to:
  /// **'Every setting can be changed later in Settings.'**
  String get changeLaterHint;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a look'**
  String get themeTitle;

  /// No description provided for @themeBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the theme you like. You can change it any time.'**
  String get themeBody;

  /// No description provided for @profileIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get profileIntroTitle;

  /// No description provided for @profileIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Add only what you know. Each detail unlocks more.'**
  String get profileIntroBody;

  /// No description provided for @profileIntroName.
  ///
  /// In en, this message translates to:
  /// **'Name: numerology'**
  String get profileIntroName;

  /// No description provided for @profileIntroDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth: Moon sign, daily horoscope, dashas'**
  String get profileIntroDate;

  /// No description provided for @profileIntroTime.
  ///
  /// In en, this message translates to:
  /// **'Time of birth: Ascendant, houses and the full Kundli'**
  String get profileIntroTime;

  /// No description provided for @profileIntroPlace.
  ///
  /// In en, this message translates to:
  /// **'Place of birth: exact timezone and accurate houses'**
  String get profileIntroPlace;

  /// No description provided for @privacyPromiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays with you'**
  String get privacyPromiseTitle;

  /// No description provided for @privacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored only on this phone. Nothing is uploaded unless you choose to share it.'**
  String get privacyPromise;

  /// No description provided for @createMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Create my profile'**
  String get createMyProfile;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @profilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profilesTitle;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get addProfile;

  /// No description provided for @scanProfile.
  ///
  /// In en, this message translates to:
  /// **'Scan a profile'**
  String get scanProfile;

  /// No description provided for @scanProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a friend\'s profile from their QR code'**
  String get scanProfileSubtitle;

  /// No description provided for @noProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get noProfilesTitle;

  /// No description provided for @noProfilesBody.
  ///
  /// In en, this message translates to:
  /// **'Create profiles for yourself, family and friends. Add only the details you have.'**
  String get noProfilesBody;

  /// No description provided for @onlyName.
  ///
  /// In en, this message translates to:
  /// **'Name only'**
  String get onlyName;

  /// No description provided for @showOnToday.
  ///
  /// In en, this message translates to:
  /// **'Show on Today'**
  String get showOnToday;

  /// No description provided for @newProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get newProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this phone.'**
  String deleteProfileBody(String name);

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get nameRequired;

  /// No description provided for @thisIsMe.
  ///
  /// In en, this message translates to:
  /// **'This is me'**
  String get thisIsMe;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @otherGender.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherGender;

  /// No description provided for @optionalDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'All details below are optional. Add what you have.'**
  String get optionalDetailsHint;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @birthTime.
  ///
  /// In en, this message translates to:
  /// **'Time of birth'**
  String get birthTime;

  /// No description provided for @birthPlace.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get birthPlace;

  /// No description provided for @timeExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get timeExact;

  /// No description provided for @timeApprox.
  ///
  /// In en, this message translates to:
  /// **'Approximate'**
  String get timeApprox;

  /// No description provided for @timezoneAtBirth.
  ///
  /// In en, this message translates to:
  /// **'Timezone at birth'**
  String get timezoneAtBirth;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @utcOffsetOverride.
  ///
  /// In en, this message translates to:
  /// **'Time zone correction'**
  String get utcOffsetOverride;

  /// No description provided for @utcOffsetOverrideInfo.
  ///
  /// In en, this message translates to:
  /// **'Only needed for old records that used a local time (for example Bombay or Calcutta time before 1955). Leave it on Automatic otherwise.'**
  String get utcOffsetOverrideInfo;

  /// No description provided for @whatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll get'**
  String get whatYouGet;

  /// No description provided for @unlockNameNumerology.
  ///
  /// In en, this message translates to:
  /// **'Name numerology'**
  String get unlockNameNumerology;

  /// No description provided for @unlockDate.
  ///
  /// In en, this message translates to:
  /// **'Moon sign, nakshatra, dashas and daily horoscope'**
  String get unlockDate;

  /// No description provided for @unlockPlace.
  ///
  /// In en, this message translates to:
  /// **'Correct timezone for your birth date'**
  String get unlockPlace;

  /// No description provided for @unlockFullChart.
  ///
  /// In en, this message translates to:
  /// **'Full Kundli: Lagna, houses, divisional charts and KP'**
  String get unlockFullChart;

  /// No description provided for @unknownTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Without a birth time we use a Moon-based chart at noon. The Ascendant and houses are not shown, and the Moon\'s position may be off by a few degrees.'**
  String get unknownTimeNote;

  /// No description provided for @noPlaceNote.
  ///
  /// In en, this message translates to:
  /// **'Without a birthplace we cannot calculate the Ascendant and houses.'**
  String get noPlaceNote;

  /// No description provided for @searchPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Search city, town or village'**
  String get searchPlaceHint;

  /// No description provided for @searchPlaceHelp.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 letters. Add a comma to narrow it down, e.g. \"Aurangabad, Maharashtra\". Works offline.'**
  String get searchPlaceHelp;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found. Try another spelling, or enter coordinates.'**
  String get noPlacesFound;

  /// No description provided for @enterCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get enterCoordinates;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @tabChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get tabChart;

  /// No description provided for @tabPlanets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get tabPlanets;

  /// No description provided for @tabDasha.
  ///
  /// In en, this message translates to:
  /// **'Dasha'**
  String get tabDasha;

  /// No description provided for @tabYogas.
  ///
  /// In en, this message translates to:
  /// **'Yogas'**
  String get tabYogas;

  /// No description provided for @tabDoshas.
  ///
  /// In en, this message translates to:
  /// **'Doshas'**
  String get tabDoshas;

  /// No description provided for @tabKp.
  ///
  /// In en, this message translates to:
  /// **'KP'**
  String get tabKp;

  /// No description provided for @needBirthDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a birth date'**
  String get needBirthDateTitle;

  /// No description provided for @needBirthDateBody.
  ///
  /// In en, this message translates to:
  /// **'A birth date is needed to calculate a chart. Add a time and place for the full Kundli.'**
  String get needBirthDateBody;

  /// No description provided for @addBirthDetails.
  ///
  /// In en, this message translates to:
  /// **'Add birth details'**
  String get addBirthDetails;

  /// No description provided for @partialChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Partial chart'**
  String get partialChartTitle;

  /// No description provided for @chartStyle.
  ///
  /// In en, this message translates to:
  /// **'Chart style'**
  String get chartStyle;

  /// No description provided for @keyFacts.
  ///
  /// In en, this message translates to:
  /// **'Key facts'**
  String get keyFacts;

  /// No description provided for @lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna (Ascendant)'**
  String get lagna;

  /// No description provided for @ascendant.
  ///
  /// In en, this message translates to:
  /// **'Ascendant'**
  String get ascendant;

  /// No description provided for @rashi.
  ///
  /// In en, this message translates to:
  /// **'Rashi (Moon sign)'**
  String get rashi;

  /// No description provided for @sunSign.
  ///
  /// In en, this message translates to:
  /// **'Sun sign'**
  String get sunSign;

  /// No description provided for @moonSign.
  ///
  /// In en, this message translates to:
  /// **'Moon sign'**
  String get moonSign;

  /// No description provided for @sunSignSidereal.
  ///
  /// In en, this message translates to:
  /// **'Sun sign (sidereal)'**
  String get sunSignSidereal;

  /// No description provided for @nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get nakshatra;

  /// No description provided for @nakshatraLord.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra lord'**
  String get nakshatraLord;

  /// No description provided for @pada.
  ///
  /// In en, this message translates to:
  /// **'Pada'**
  String get pada;

  /// No description provided for @ayanamsaLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayanamsa'**
  String get ayanamsaLabel;

  /// No description provided for @ayanamsaInfo.
  ///
  /// In en, this message translates to:
  /// **'The ayanamsa is the offset between the tropical and sidereal zodiac. Different traditions use slightly different values.'**
  String get ayanamsaInfo;

  /// No description provided for @houseSystem.
  ///
  /// In en, this message translates to:
  /// **'House system'**
  String get houseSystem;

  /// No description provided for @nodeType.
  ///
  /// In en, this message translates to:
  /// **'Rahu/Ketu calculation'**
  String get nodeType;

  /// No description provided for @birthDetails.
  ///
  /// In en, this message translates to:
  /// **'Birth details'**
  String get birthDetails;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @planet.
  ///
  /// In en, this message translates to:
  /// **'Planet'**
  String get planet;

  /// No description provided for @exalted.
  ///
  /// In en, this message translates to:
  /// **'Exalted'**
  String get exalted;

  /// No description provided for @debilitated.
  ///
  /// In en, this message translates to:
  /// **'Debilitated'**
  String get debilitated;

  /// No description provided for @ownSign.
  ///
  /// In en, this message translates to:
  /// **'Own sign'**
  String get ownSign;

  /// No description provided for @retrograde.
  ///
  /// In en, this message translates to:
  /// **'retrograde'**
  String get retrograde;

  /// No description provided for @planetsFootnote.
  ///
  /// In en, this message translates to:
  /// **'Positions from Swiss Ephemeris (NASA JPL data). Speed is in degrees per day; negative speed means retrograde.'**
  String get planetsFootnote;

  /// No description provided for @runningNow.
  ///
  /// In en, this message translates to:
  /// **'Running now'**
  String get runningNow;

  /// No description provided for @mahadasha.
  ///
  /// In en, this message translates to:
  /// **'Mahadasha'**
  String get mahadasha;

  /// No description provided for @antardasha.
  ///
  /// In en, this message translates to:
  /// **'Antardasha'**
  String get antardasha;

  /// No description provided for @pratyantardasha.
  ///
  /// In en, this message translates to:
  /// **'Pratyantardasha'**
  String get pratyantardasha;

  /// No description provided for @dashaApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Birth time unknown: dasha dates may be off by several months, because the Moon moves about 13° a day.'**
  String get dashaApproxNote;

  /// No description provided for @doshaIntro.
  ///
  /// In en, this message translates to:
  /// **'Doshas are traditional indicators, not verdicts. Different schools judge them differently, and most texts also list many cancelling factors.'**
  String get doshaIntro;

  /// No description provided for @mitigatingFactors.
  ///
  /// In en, this message translates to:
  /// **'Softening factors found'**
  String get mitigatingFactors;

  /// No description provided for @sadeSati.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati'**
  String get sadeSati;

  /// No description provided for @sadeSatiRunning.
  ///
  /// In en, this message translates to:
  /// **'Running now: phase {phase} of 3, with Saturn in {sign}.'**
  String sadeSatiRunning(int phase, String sign);

  /// No description provided for @sadeSatiNotRunning.
  ///
  /// In en, this message translates to:
  /// **'Not running. Saturn is in {sign}, the {house}th sign from your Moon.'**
  String sadeSatiNotRunning(String sign, int house);

  /// No description provided for @sadeSatiPhase.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase} of 3'**
  String sadeSatiPhase(int phase);

  /// No description provided for @dhaiyaNote.
  ///
  /// In en, this message translates to:
  /// **'Saturn is transiting the {house}th from your Moon (Dhaiya, or small panoti), which tradition associates with extra responsibility.'**
  String dhaiyaNote(int house);

  /// No description provided for @sadeSatiPeriods.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati periods'**
  String get sadeSatiPeriods;

  /// No description provided for @sadeSatiSource.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati is Saturn\'s transit through the 12th, 1st and 2nd signs from the natal Moon (about 7½ years). Tradition associates it with effort and maturity, not only difficulty.'**
  String get sadeSatiSource;

  /// No description provided for @yogasIntro.
  ///
  /// In en, this message translates to:
  /// **'Yogas are planetary combinations described in classical texts. Their effects depend on the strength of the planets involved and on the whole chart.'**
  String get yogasIntro;

  /// No description provided for @noYogasFound.
  ///
  /// In en, this message translates to:
  /// **'None of the yogas we check were found in this chart.'**
  String get noYogasFound;

  /// No description provided for @kpIntro.
  ///
  /// In en, this message translates to:
  /// **'Krishnamurti Paddhati (KP) uses the KP ayanamsa and Placidus cusps, and focuses on sub lords.'**
  String get kpIntro;

  /// No description provided for @kpNeedsTime.
  ///
  /// In en, this message translates to:
  /// **'KP needs an exact birth time and place.'**
  String get kpNeedsTime;

  /// No description provided for @kpCusps.
  ///
  /// In en, this message translates to:
  /// **'Cusps'**
  String get kpCusps;

  /// No description provided for @kpPlanets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get kpPlanets;

  /// No description provided for @kpSignStarSubSub.
  ///
  /// In en, this message translates to:
  /// **'Sign · Star · Sub · Sub-sub'**
  String get kpSignStarSubSub;

  /// No description provided for @kpSignificators.
  ///
  /// In en, this message translates to:
  /// **'House significators'**
  String get kpSignificators;

  /// No description provided for @kpRulingPlanets.
  ///
  /// In en, this message translates to:
  /// **'Ruling planets now'**
  String get kpRulingPlanets;

  /// No description provided for @kpRulingNote.
  ///
  /// In en, this message translates to:
  /// **'For this moment at {place}. Used in KP horary and to confirm birth time.'**
  String kpRulingNote(String place);

  /// No description provided for @tithi.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get tithi;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @karana.
  ///
  /// In en, this message translates to:
  /// **'Karana'**
  String get karana;

  /// No description provided for @lunarMonth.
  ///
  /// In en, this message translates to:
  /// **'Lunar month'**
  String get lunarMonth;

  /// No description provided for @amanta.
  ///
  /// In en, this message translates to:
  /// **'Amanta'**
  String get amanta;

  /// No description provided for @purnimanta.
  ///
  /// In en, this message translates to:
  /// **'Purnimanta'**
  String get purnimanta;

  /// No description provided for @samvat.
  ///
  /// In en, this message translates to:
  /// **'Samvat'**
  String get samvat;

  /// No description provided for @sunMoon.
  ///
  /// In en, this message translates to:
  /// **'Sun and Moon'**
  String get sunMoon;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @moonrise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get moonrise;

  /// No description provided for @moonset.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get moonset;

  /// No description provided for @sunriseSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunrise / Sunset'**
  String get sunriseSunset;

  /// No description provided for @timings.
  ///
  /// In en, this message translates to:
  /// **'Auspicious and inauspicious times'**
  String get timings;

  /// No description provided for @abhijit.
  ///
  /// In en, this message translates to:
  /// **'Abhijit Muhurta'**
  String get abhijit;

  /// No description provided for @rahuKaal.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal'**
  String get rahuKaal;

  /// No description provided for @yamaganda.
  ///
  /// In en, this message translates to:
  /// **'Yamaganda'**
  String get yamaganda;

  /// No description provided for @gulika.
  ///
  /// In en, this message translates to:
  /// **'Gulika Kaal'**
  String get gulika;

  /// No description provided for @dayChoghadiya.
  ///
  /// In en, this message translates to:
  /// **'Day Choghadiya'**
  String get dayChoghadiya;

  /// No description provided for @nightChoghadiya.
  ///
  /// In en, this message translates to:
  /// **'Night Choghadiya'**
  String get nightChoghadiya;

  /// No description provided for @hora.
  ///
  /// In en, this message translates to:
  /// **'Hora'**
  String get hora;

  /// No description provided for @changePlace.
  ///
  /// In en, this message translates to:
  /// **'Change place'**
  String get changePlace;

  /// No description provided for @todaysPanchang.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Panchang'**
  String get todaysPanchang;

  /// No description provided for @panchangNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated on your phone for the chosen place using Swiss Ephemeris and the Lahiri ayanamsa (or your chosen one). Sunrise is taken when the Sun\'s upper edge appears, with standard refraction.'**
  String get panchangNote;

  /// No description provided for @matchTitle.
  ///
  /// In en, this message translates to:
  /// **'Kundli Matching'**
  String get matchTitle;

  /// No description provided for @matchIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose two profiles. Matching uses the Moon positions of both people.'**
  String get matchIntro;

  /// No description provided for @groom.
  ///
  /// In en, this message translates to:
  /// **'Groom'**
  String get groom;

  /// No description provided for @bride.
  ///
  /// In en, this message translates to:
  /// **'Bride'**
  String get bride;

  /// No description provided for @matchNeedProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add two profiles'**
  String get matchNeedProfilesTitle;

  /// No description provided for @matchNeedProfilesBody.
  ///
  /// In en, this message translates to:
  /// **'Matching needs at least two profiles with birth dates.'**
  String get matchNeedProfilesBody;

  /// No description provided for @matchTeenTitle.
  ///
  /// In en, this message translates to:
  /// **'Available at 18+'**
  String get matchTeenTitle;

  /// No description provided for @matchTeenBody.
  ///
  /// In en, this message translates to:
  /// **'Marriage matching is shown only to adults. You can still explore your own chart.'**
  String get matchTeenBody;

  /// No description provided for @kootaDetails.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoot (8 kootas)'**
  String get kootaDetails;

  /// No description provided for @traditionalExceptions.
  ///
  /// In en, this message translates to:
  /// **'Traditional exceptions'**
  String get traditionalExceptions;

  /// No description provided for @manglikComparison.
  ///
  /// In en, this message translates to:
  /// **'Mangal dosha'**
  String get manglikComparison;

  /// No description provided for @manglikBalanced.
  ///
  /// In en, this message translates to:
  /// **'Both charts have the same Mangal dosha status, which is traditionally considered balanced.'**
  String get manglikBalanced;

  /// No description provided for @manglikUnbalanced.
  ///
  /// In en, this message translates to:
  /// **'Only one chart has Mangal dosha. Many astrologers check further cancelling factors before drawing conclusions.'**
  String get manglikUnbalanced;

  /// No description provided for @matchDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Guna Milan is one traditional tool, and point tables vary slightly between almanacs. It cannot predict the success of a relationship. Mutual respect, values and communication matter most.'**
  String get matchDisclaimer;

  /// No description provided for @matchApproxNote.
  ///
  /// In en, this message translates to:
  /// **'One or both birth times are unknown, so the result is approximate.'**
  String get matchApproxNote;

  /// No description provided for @synastry.
  ///
  /// In en, this message translates to:
  /// **'Synastry'**
  String get synastry;

  /// No description provided for @harmoniousAspects.
  ///
  /// In en, this message translates to:
  /// **'Harmonious aspects'**
  String get harmoniousAspects;

  /// No description provided for @challengingAspects.
  ///
  /// In en, this message translates to:
  /// **'Challenging aspects'**
  String get challengingAspects;

  /// No description provided for @conjunctions.
  ///
  /// In en, this message translates to:
  /// **'Conjunctions'**
  String get conjunctions;

  /// No description provided for @aspectList.
  ///
  /// In en, this message translates to:
  /// **'Aspects between the charts'**
  String get aspectList;

  /// No description provided for @numerology.
  ///
  /// In en, this message translates to:
  /// **'Numerology'**
  String get numerology;

  /// No description provided for @numerologySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Life path, destiny, Mulank and Bhagyank'**
  String get numerologySubtitle;

  /// No description provided for @numerologyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or birth date.'**
  String get numerologyEmpty;

  /// No description provided for @numerologyNote.
  ///
  /// In en, this message translates to:
  /// **'Numerology is a traditional system of symbolic meanings for numbers. Read it as reflection, not prediction.'**
  String get numerologyNote;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, calculation options and privacy'**
  String get settingsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @astrology.
  ///
  /// In en, this message translates to:
  /// **'Astrology'**
  String get astrology;

  /// No description provided for @astrologySystem.
  ///
  /// In en, this message translates to:
  /// **'Astrology system'**
  String get astrologySystem;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsInfo.
  ///
  /// In en, this message translates to:
  /// **'All notifications are off by default. Turn on only what you want.'**
  String get notificationsInfo;

  /// No description provided for @privacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get privacyData;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @exportDataInfo.
  ///
  /// In en, this message translates to:
  /// **'Share a backup of all profiles and settings as text'**
  String get exportDataInfo;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get importData;

  /// No description provided for @importedProfiles.
  ///
  /// In en, this message translates to:
  /// **'{count} profiles imported'**
  String importedProfiles(int count);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read a backup from the clipboard.'**
  String get importFailed;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all profiles and settings from this phone.'**
  String get deleteAllDataConfirm;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Drishti'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences and credits'**
  String get aboutSubtitle;

  /// No description provided for @aboutLegal.
  ///
  /// In en, this message translates to:
  /// **'Free and open source (AGPL-3.0). Astronomical calculations by Swiss Ephemeris {version} © Astrodienst AG. Places from GeoNames (CC BY 4.0).'**
  String aboutLegal(String version);

  /// No description provided for @shareProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfileTitle;

  /// No description provided for @shareProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Let a friend scan this code to add {name}\'s birth details. The code goes directly from phone to phone; no server is involved.'**
  String shareProfileBody(String name);

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as a text code'**
  String get shareAsText;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Birth details of {name} for the Drishti app:\n{code}'**
  String shareText(String name, String code);

  /// No description provided for @sharePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Only the name and birth details are shared. Notes and life events are never included.'**
  String get sharePrivacyNote;

  /// No description provided for @pasteCode.
  ///
  /// In en, this message translates to:
  /// **'Paste code'**
  String get pasteCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'That is not a valid Drishti profile code.'**
  String get invalidCode;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @homeNoProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your profile to see your personal horoscope, chart and dashas.'**
  String get homeNoProfile;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String hello(String name);

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get switchProfile;

  /// No description provided for @yourChart.
  ///
  /// In en, this message translates to:
  /// **'Your chart'**
  String get yourChart;

  /// No description provided for @currentDasha.
  ///
  /// In en, this message translates to:
  /// **'Current dasha'**
  String get currentDasha;

  /// No description provided for @horoscopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your horoscope'**
  String get horoscopeTitle;

  /// No description provided for @pickSignForHoroscope.
  ///
  /// In en, this message translates to:
  /// **'Add a birth date for a personal reading, or pick a sign for a general one:'**
  String get pickSignForHoroscope;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @horoscopeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'A horoscope cannot be made with the available details.'**
  String get horoscopeUnavailable;

  /// No description provided for @keyEvents.
  ///
  /// In en, this message translates to:
  /// **'Key sky events'**
  String get keyEvents;

  /// No description provided for @whyThisReading.
  ///
  /// In en, this message translates to:
  /// **'Why this reading?'**
  String get whyThisReading;

  /// No description provided for @horoscopeApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Some birth details are approximate, so parts of this reading are approximate too.'**
  String get horoscopeApproxNote;

  /// No description provided for @changeSign.
  ///
  /// In en, this message translates to:
  /// **'Change sign'**
  String get changeSign;

  /// No description provided for @notifPanchangTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Panchang · {vara}'**
  String notifPanchangTitle(String vara);

  /// No description provided for @notifRahuKaalTitle.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal begins soon'**
  String get notifRahuKaalTitle;

  /// No description provided for @notifRahuKaalBody.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal today: {start} – {end}. Traditionally avoided for starting new work.'**
  String notifRahuKaalBody(String start, String end);

  /// No description provided for @notifHoroscopeTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}, your day'**
  String notifHoroscopeTitle(String name);

  /// No description provided for @notifTransitTitle.
  ///
  /// In en, this message translates to:
  /// **'Sky update'**
  String get notifTransitTitle;

  /// No description provided for @notifIngress.
  ///
  /// In en, this message translates to:
  /// **'{planet} enters {sign} today.'**
  String notifIngress(String planet, String sign);

  /// No description provided for @notifRetro.
  ///
  /// In en, this message translates to:
  /// **'{planet} turns retrograde in {sign}.'**
  String notifRetro(String planet, String sign);

  /// No description provided for @notifDirect.
  ///
  /// In en, this message translates to:
  /// **'{planet} turns direct in {sign}.'**
  String notifDirect(String planet, String sign);

  /// No description provided for @notifFestivalTitle.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get notifFestivalTitle;

  /// No description provided for @notifFestivalBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is tomorrow.'**
  String notifFestivalBody(String name);

  /// No description provided for @widgetOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Drishti to refresh'**
  String get widgetOpenApp;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Drishti. You can allow them in your phone\'s settings.'**
  String get notificationsDenied;

  /// No description provided for @skyNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'From the Drishti team'**
  String get skyNewsTitle;

  /// No description provided for @feedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String feedUpdated(String date);

  /// No description provided for @remedyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remedies'**
  String get remedyTitle;

  /// No description provided for @remedySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mantras, charity, fasting and other traditional practices'**
  String get remedySubtitle;

  /// No description provided for @remedyTabForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get remedyTabForYou;

  /// No description provided for @remedyTabPlanets.
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get remedyTabPlanets;

  /// No description provided for @remedyTabDoshas.
  ///
  /// In en, this message translates to:
  /// **'Doshas'**
  String get remedyTabDoshas;

  /// No description provided for @remedyTabBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get remedyTabBooks;

  /// No description provided for @remedyDeity.
  ///
  /// In en, this message translates to:
  /// **'Deity'**
  String get remedyDeity;

  /// No description provided for @remedyDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get remedyDay;

  /// No description provided for @remedyColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get remedyColour;

  /// No description provided for @remedyDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get remedyDirection;

  /// No description provided for @remedyBeejMantra.
  ///
  /// In en, this message translates to:
  /// **'Beej mantra'**
  String get remedyBeejMantra;

  /// No description provided for @remedyStotra.
  ///
  /// In en, this message translates to:
  /// **'Navagraha Stotra verse'**
  String get remedyStotra;

  /// No description provided for @remedyJapa.
  ///
  /// In en, this message translates to:
  /// **'Japa count'**
  String get remedyJapa;

  /// No description provided for @remedyCharity.
  ///
  /// In en, this message translates to:
  /// **'Charity (daan)'**
  String get remedyCharity;

  /// No description provided for @remedyFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get remedyFasting;

  /// No description provided for @remedyGemstone.
  ///
  /// In en, this message translates to:
  /// **'Gemstone (traditional association)'**
  String get remedyGemstone;

  /// No description provided for @remedyUpratna.
  ///
  /// In en, this message translates to:
  /// **'Substitute stones (upratna)'**
  String get remedyUpratna;

  /// No description provided for @remedyRudraksha.
  ///
  /// In en, this message translates to:
  /// **'Rudraksha'**
  String get remedyRudraksha;

  /// No description provided for @remedyYantra.
  ///
  /// In en, this message translates to:
  /// **'Yantra'**
  String get remedyYantra;

  /// No description provided for @remedyLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Conduct and lifestyle'**
  String get remedyLifestyle;

  /// No description provided for @remedySignifies.
  ///
  /// In en, this message translates to:
  /// **'Signifies'**
  String get remedySignifies;

  /// No description provided for @remedyMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get remedyMeaning;

  /// No description provided for @remedyNeedProfile.
  ///
  /// In en, this message translates to:
  /// **'Add a profile with a birth date to see remedies traditionally linked with your chart.'**
  String get remedyNeedProfile;

  /// No description provided for @remedyReasonDasha.
  ///
  /// In en, this message translates to:
  /// **'You are running the {planet} mahadasha.'**
  String remedyReasonDasha(String planet);

  /// No description provided for @remedyReasonAntardasha.
  ///
  /// In en, this message translates to:
  /// **'You are running the {planet} antardasha.'**
  String remedyReasonAntardasha(String planet);

  /// No description provided for @remedyReasonDebilitated.
  ///
  /// In en, this message translates to:
  /// **'{planet} is debilitated in your chart.'**
  String remedyReasonDebilitated(String planet);

  /// No description provided for @remedyReasonSadeSati.
  ///
  /// In en, this message translates to:
  /// **'Sade Sati is running (phase {phase} of 3).'**
  String remedyReasonSadeSati(int phase);

  /// No description provided for @remedyReasonManglik.
  ///
  /// In en, this message translates to:
  /// **'Mangal dosha is present by the traditional rule.'**
  String get remedyReasonManglik;

  /// No description provided for @remedyNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No specific traditional remedies stand out for your chart right now. General practices such as kindness, discipline and prayer are always considered beneficial.'**
  String get remedyNoSuggestions;

  /// No description provided for @remedyOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get remedyOpenDetails;

  /// No description provided for @remedySource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get remedySource;

  /// No description provided for @tarotTitle.
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get tarotTitle;

  /// No description provided for @tarotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Card of the day and reflective spreads'**
  String get tarotSubtitle;

  /// No description provided for @tarotDailyCard.
  ///
  /// In en, this message translates to:
  /// **'Card of the day'**
  String get tarotDailyCard;

  /// No description provided for @tarotTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tarotTapToReveal;

  /// No description provided for @tarotUpright.
  ///
  /// In en, this message translates to:
  /// **'Upright'**
  String get tarotUpright;

  /// No description provided for @tarotReversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get tarotReversed;

  /// No description provided for @tarotSpreads.
  ///
  /// In en, this message translates to:
  /// **'Spreads'**
  String get tarotSpreads;

  /// No description provided for @tarotSpreadThree.
  ///
  /// In en, this message translates to:
  /// **'Past, present, future'**
  String get tarotSpreadThree;

  /// No description provided for @tarotSpreadThreeInfo.
  ///
  /// In en, this message translates to:
  /// **'Three cards for reflecting on how a situation has developed.'**
  String get tarotSpreadThreeInfo;

  /// No description provided for @tarotSpreadCeltic.
  ///
  /// In en, this message translates to:
  /// **'Celtic Cross'**
  String get tarotSpreadCeltic;

  /// No description provided for @tarotSpreadCelticInfo.
  ///
  /// In en, this message translates to:
  /// **'A ten-card spread for looking at a question in depth.'**
  String get tarotSpreadCelticInfo;

  /// No description provided for @tarotSpreadRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get tarotSpreadRelationship;

  /// No description provided for @tarotSpreadRelationshipInfo.
  ///
  /// In en, this message translates to:
  /// **'Five cards about you, the other person and the connection between you.'**
  String get tarotSpreadRelationshipInfo;

  /// No description provided for @tarotQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Your question (optional)'**
  String get tarotQuestionHint;

  /// No description provided for @tarotDraw.
  ///
  /// In en, this message translates to:
  /// **'Shuffle and draw'**
  String get tarotDraw;

  /// No description provided for @tarotHistory.
  ///
  /// In en, this message translates to:
  /// **'Past readings'**
  String get tarotHistory;

  /// No description provided for @tarotNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Your readings will be saved here, only on this phone.'**
  String get tarotNoHistory;

  /// No description provided for @tarotClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get tarotClearHistory;

  /// No description provided for @tarotAstrology.
  ///
  /// In en, this message translates to:
  /// **'Astrological attribution'**
  String get tarotAstrology;

  /// No description provided for @tarotPositionPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tarotPositionPast;

  /// No description provided for @tarotPositionPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get tarotPositionPresent;

  /// No description provided for @tarotPositionFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get tarotPositionFuture;

  /// No description provided for @tarotPositionSituation.
  ///
  /// In en, this message translates to:
  /// **'The situation'**
  String get tarotPositionSituation;

  /// No description provided for @tarotPositionChallenge.
  ///
  /// In en, this message translates to:
  /// **'The challenge'**
  String get tarotPositionChallenge;

  /// No description provided for @tarotPositionFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get tarotPositionFoundation;

  /// No description provided for @tarotPositionRecentPast.
  ///
  /// In en, this message translates to:
  /// **'Recent past'**
  String get tarotPositionRecentPast;

  /// No description provided for @tarotPositionPossibility.
  ///
  /// In en, this message translates to:
  /// **'What could be'**
  String get tarotPositionPossibility;

  /// No description provided for @tarotPositionNearFuture.
  ///
  /// In en, this message translates to:
  /// **'Near future'**
  String get tarotPositionNearFuture;

  /// No description provided for @tarotPositionSelf.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tarotPositionSelf;

  /// No description provided for @tarotPositionEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Surroundings'**
  String get tarotPositionEnvironment;

  /// No description provided for @tarotPositionHopesFears.
  ///
  /// In en, this message translates to:
  /// **'Hopes and fears'**
  String get tarotPositionHopesFears;

  /// No description provided for @tarotPositionOutcome.
  ///
  /// In en, this message translates to:
  /// **'Likely direction'**
  String get tarotPositionOutcome;

  /// No description provided for @tarotPositionYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tarotPositionYou;

  /// No description provided for @tarotPositionThem.
  ///
  /// In en, this message translates to:
  /// **'The other person'**
  String get tarotPositionThem;

  /// No description provided for @tarotPositionConnection.
  ///
  /// In en, this message translates to:
  /// **'The connection'**
  String get tarotPositionConnection;

  /// No description provided for @tarotPositionStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength to build on'**
  String get tarotPositionStrength;

  /// No description provided for @tarotPositionAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get tarotPositionAdvice;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal and mood'**
  String get journalTitle;

  /// No description provided for @journalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your mood alongside the Moon\'s cycle'**
  String get journalSubtitle;

  /// No description provided for @journalToday.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get journalToday;

  /// No description provided for @journalMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get journalMood;

  /// No description provided for @journalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get journalEnergy;

  /// No description provided for @journalTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get journalTags;

  /// No description provided for @journalNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get journalNote;

  /// No description provided for @journalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything on your mind?'**
  String get journalNoteHint;

  /// No description provided for @journalSave.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get journalSave;

  /// No description provided for @journalSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get journalSaved;

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Add one a day to see patterns over time.'**
  String get journalEmpty;

  /// No description provided for @journalHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get journalHistory;

  /// No description provided for @journalChart.
  ///
  /// In en, this message translates to:
  /// **'Mood over time'**
  String get journalChart;

  /// No description provided for @journalInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get journalInsights;

  /// No description provided for @journalInsightsNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Insights appear after {count} entries. You have {have}.'**
  String journalInsightsNeedMore(int count, int have);

  /// No description provided for @journalInsightsNote.
  ///
  /// In en, this message translates to:
  /// **'These are simple averages from your own entries. A pattern here is a correlation, not proof that the Moon or anything else caused it.'**
  String get journalInsightsNote;

  /// No description provided for @journalAvgShukla.
  ///
  /// In en, this message translates to:
  /// **'Average mood in Shukla paksha (waxing Moon)'**
  String get journalAvgShukla;

  /// No description provided for @journalAvgKrishna.
  ///
  /// In en, this message translates to:
  /// **'Average mood in Krishna paksha (waning Moon)'**
  String get journalAvgKrishna;

  /// No description provided for @journalAvgByElement.
  ///
  /// In en, this message translates to:
  /// **'Average mood by the Moon\'s element'**
  String get journalAvgByElement;

  /// No description provided for @journalAvgByWeekday.
  ///
  /// In en, this message translates to:
  /// **'Average mood by weekday'**
  String get journalAvgByWeekday;

  /// No description provided for @journalExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get journalExport;

  /// No description provided for @journalDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all entries'**
  String get journalDeleteAll;

  /// No description provided for @journalDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all journal entries from this phone.'**
  String get journalDeleteAllConfirm;

  /// No description provided for @journalDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get journalDeleteEntry;

  /// No description provided for @journalSky.
  ///
  /// In en, this message translates to:
  /// **'Sky that day'**
  String get journalSky;

  /// No description provided for @journalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your journal never leaves this phone unless you export it.'**
  String get journalPrivacy;

  /// No description provided for @wellnessMeditationTitle.
  ///
  /// In en, this message translates to:
  /// **'Meditation and breathing'**
  String get wellnessMeditationTitle;

  /// No description provided for @wellnessMeditationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guided breathing, nadi shodhana and Om chanting'**
  String get wellnessMeditationSubtitle;

  /// No description provided for @wellnessBreathIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get wellnessBreathIn;

  /// No description provided for @wellnessBreathOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get wellnessBreathOut;

  /// No description provided for @wellnessHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get wellnessHold;

  /// No description provided for @wellnessInLeft.
  ///
  /// In en, this message translates to:
  /// **'In through the left nostril'**
  String get wellnessInLeft;

  /// No description provided for @wellnessInRight.
  ///
  /// In en, this message translates to:
  /// **'In through the right nostril'**
  String get wellnessInRight;

  /// No description provided for @wellnessOutLeft.
  ///
  /// In en, this message translates to:
  /// **'Out through the left nostril'**
  String get wellnessOutLeft;

  /// No description provided for @wellnessOutRight.
  ///
  /// In en, this message translates to:
  /// **'Out through the right nostril'**
  String get wellnessOutRight;

  /// No description provided for @wellnessChant.
  ///
  /// In en, this message translates to:
  /// **'Chant Om'**
  String get wellnessChant;

  /// No description provided for @wellnessStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get wellnessStart;

  /// No description provided for @wellnessStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get wellnessStop;

  /// No description provided for @wellnessMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String wellnessMinutes(int minutes);

  /// No description provided for @wellnessSessionDone.
  ///
  /// In en, this message translates to:
  /// **'Session complete. Notice how you feel.'**
  String get wellnessSessionDone;

  /// No description provided for @wellnessPatternBox.
  ///
  /// In en, this message translates to:
  /// **'Box breathing (4-4-4-4)'**
  String get wellnessPatternBox;

  /// No description provided for @wellnessPatternBoxInfo.
  ///
  /// In en, this message translates to:
  /// **'Equal counts of inhaling, holding, exhaling and holding. Steadies the mind.'**
  String get wellnessPatternBoxInfo;

  /// No description provided for @wellnessPattern478.
  ///
  /// In en, this message translates to:
  /// **'4-7-8 breathing'**
  String get wellnessPattern478;

  /// No description provided for @wellnessPattern478Info.
  ///
  /// In en, this message translates to:
  /// **'Inhale for 4, hold for 7, exhale for 8. Often used to relax before sleep.'**
  String get wellnessPattern478Info;

  /// No description provided for @wellnessPatternNadi.
  ///
  /// In en, this message translates to:
  /// **'Nadi shodhana'**
  String get wellnessPatternNadi;

  /// No description provided for @wellnessPatternNadiInfo.
  ///
  /// In en, this message translates to:
  /// **'Alternate-nostril breathing from yoga. Close the right nostril with the right thumb to inhale on the left; close the left with the ring finger to exhale on the right; then reverse.'**
  String get wellnessPatternNadiInfo;

  /// No description provided for @wellnessPatternOm.
  ///
  /// In en, this message translates to:
  /// **'Om chanting'**
  String get wellnessPatternOm;

  /// No description provided for @wellnessPatternOmInfo.
  ///
  /// In en, this message translates to:
  /// **'Inhale deeply, then chant a long \"Ommm\" on the exhale, feeling the vibration.'**
  String get wellnessPatternOmInfo;

  /// No description provided for @wellnessDayTheme.
  ///
  /// In en, this message translates to:
  /// **'Today is ruled by {planet}: {theme}'**
  String wellnessDayTheme(String planet, String theme);

  /// No description provided for @wellnessHealthNote.
  ///
  /// In en, this message translates to:
  /// **'Stop if you feel dizzy or uncomfortable. If you have a medical condition, check with a doctor before breath-holding practices.'**
  String get wellnessHealthNote;

  /// No description provided for @palmTitle.
  ///
  /// In en, this message translates to:
  /// **'Palm reading guide'**
  String get palmTitle;

  /// No description provided for @palmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A guided, honest self-reading of your hand'**
  String get palmSubtitle;

  /// No description provided for @palmAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of your palm (optional)'**
  String get palmAddPhoto;

  /// No description provided for @palmTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get palmTakePhoto;

  /// No description provided for @palmChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get palmChoosePhoto;

  /// No description provided for @palmNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get palmNext;

  /// No description provided for @palmBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get palmBack;

  /// No description provided for @palmSeeReading.
  ///
  /// In en, this message translates to:
  /// **'See my reading'**
  String get palmSeeReading;

  /// No description provided for @palmReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your palm reading'**
  String get palmReadingTitle;

  /// No description provided for @palmStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get palmStartOver;

  /// No description provided for @palmStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String palmStepOf(int step, int total);

  /// No description provided for @advTabStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get advTabStrength;

  /// No description provided for @advTabJaimini.
  ///
  /// In en, this message translates to:
  /// **'Jaimini'**
  String get advTabJaimini;

  /// No description provided for @advTabLalKitab.
  ///
  /// In en, this message translates to:
  /// **'Lal Kitab'**
  String get advTabLalKitab;

  /// No description provided for @advTabForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get advTabForecast;

  /// No description provided for @advNeedsTime.
  ///
  /// In en, this message translates to:
  /// **'This needs an exact birth time and place.'**
  String get advNeedsTime;

  /// No description provided for @advNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get advNone;

  /// No description provided for @advTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get advTotal;

  /// No description provided for @advShadbala.
  ///
  /// In en, this message translates to:
  /// **'Shadbala (six-fold strength)'**
  String get advShadbala;

  /// No description provided for @advShadbalaIntro.
  ///
  /// In en, this message translates to:
  /// **'Shadbala measures how able each planet is to deliver its results (BPHS ch. 27). The marker shows the classical minimum; a bar beyond it means the planet is considered strong.'**
  String get advShadbalaIntro;

  /// No description provided for @advRupas.
  ///
  /// In en, this message translates to:
  /// **'{value} rupas'**
  String advRupas(String value);

  /// No description provided for @advRequired.
  ///
  /// In en, this message translates to:
  /// **'minimum {value}'**
  String advRequired(String value);

  /// No description provided for @advShadbalaParts.
  ///
  /// In en, this message translates to:
  /// **'Sthana {sthana} · Dig {dig} · Kala {kala} · Chesta {chesta} · Naisargika {nai} · Drik {drik}'**
  String advShadbalaParts(
    String sthana,
    String dig,
    String kala,
    String chesta,
    String nai,
    String drik,
  );

  /// No description provided for @advShadbalaNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated in virupas (60 = 1 rupa). Software differs in a few sub-parts (Chesta, Abda/Masa lords, Yuddha); our method choices are listed in the open-source code, so numbers may differ slightly from other programs.'**
  String get advShadbalaNote;

  /// No description provided for @advAshtakavarga.
  ///
  /// In en, this message translates to:
  /// **'Ashtakavarga'**
  String get advAshtakavarga;

  /// No description provided for @advAshtakavargaIntro.
  ///
  /// In en, this message translates to:
  /// **'Benefic points (bindus) each sign receives from the seven planets and the Lagna. Signs with 28 or more points in the Sarvashtakavarga are traditionally considered supportive for transits.'**
  String get advAshtakavargaIntro;

  /// No description provided for @advSav.
  ///
  /// In en, this message translates to:
  /// **'Sarvashtakavarga'**
  String get advSav;

  /// No description provided for @advBav.
  ///
  /// In en, this message translates to:
  /// **'Bhinnashtakavarga'**
  String get advBav;

  /// No description provided for @advJaiminiIntro.
  ///
  /// In en, this message translates to:
  /// **'Jaimini astrology uses movable significators (chara karakas), arudha padas and sign-based dashas.'**
  String get advJaiminiIntro;

  /// No description provided for @advKarakas.
  ///
  /// In en, this message translates to:
  /// **'Chara karakas'**
  String get advKarakas;

  /// No description provided for @advKarakaScheme8.
  ///
  /// In en, this message translates to:
  /// **'8-karaka scheme (include Rahu)'**
  String get advKarakaScheme8;

  /// No description provided for @advKarakamsa.
  ///
  /// In en, this message translates to:
  /// **'Karakamsa (navamsa of the Atmakaraka)'**
  String get advKarakamsa;

  /// No description provided for @advArudhas.
  ///
  /// In en, this message translates to:
  /// **'Arudha padas'**
  String get advArudhas;

  /// No description provided for @advArudhaLagna.
  ///
  /// In en, this message translates to:
  /// **'Arudha Lagna (AL)'**
  String get advArudhaLagna;

  /// No description provided for @advUpapada.
  ///
  /// In en, this message translates to:
  /// **'Upapada (UL)'**
  String get advUpapada;

  /// No description provided for @advCharaDasha.
  ///
  /// In en, this message translates to:
  /// **'Chara dasha'**
  String get advCharaDasha;

  /// No description provided for @advCharaDashaNote.
  ///
  /// In en, this message translates to:
  /// **'Method of K.N. Rao: the direction follows the 9th sign from the Lagna; years are counted from each sign to its lord. Other Chara dasha variants exist.'**
  String get advCharaDashaNote;

  /// No description provided for @advYears.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String advYears(int count);

  /// No description provided for @advLalKitabIntro.
  ///
  /// In en, this message translates to:
  /// **'In Lal Kitab the signs are fixed to the houses (Aries = 1st house) and each planet sits in the house of its sign. Meanings below are short summaries of the Lal Kitab tradition.'**
  String get advLalKitabIntro;

  /// No description provided for @advPakkaGhar.
  ///
  /// In en, this message translates to:
  /// **'In pakka ghar (permanent house)'**
  String get advPakkaGhar;

  /// No description provided for @advSleepingHouses.
  ///
  /// In en, this message translates to:
  /// **'Sleeping houses'**
  String get advSleepingHouses;

  /// No description provided for @advSleepingNote.
  ///
  /// In en, this message translates to:
  /// **'Simplified rule: an empty house that is not aspected from the opposite house. Lal Kitab commentators use further aspect rules.'**
  String get advSleepingNote;

  /// No description provided for @advVarshphalNote.
  ///
  /// In en, this message translates to:
  /// **'Lal Kitab Varshphal (annual chart) is not included yet: we only publish tables we have verified against a primary source.'**
  String get advVarshphalNote;

  /// No description provided for @advHouseN.
  ///
  /// In en, this message translates to:
  /// **'House {house}'**
  String advHouseN(int house);

  /// No description provided for @advProgressions.
  ///
  /// In en, this message translates to:
  /// **'Secondary progressions'**
  String get advProgressions;

  /// No description provided for @advProgressionsNote.
  ///
  /// In en, this message translates to:
  /// **'A day after birth stands for a year of life. The MC is moved by the solar arc and the Ascendant derived from it.'**
  String get advProgressionsNote;

  /// No description provided for @advForDate.
  ///
  /// In en, this message translates to:
  /// **'For date'**
  String get advForDate;

  /// No description provided for @advSolarReturn.
  ///
  /// In en, this message translates to:
  /// **'Solar return'**
  String get advSolarReturn;

  /// No description provided for @advSolarReturnNote.
  ///
  /// In en, this message translates to:
  /// **'The chart for the moment the Sun returns to its birth position each year, cast for the birthplace.'**
  String get advSolarReturnNote;

  /// No description provided for @advYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get advYear;

  /// No description provided for @advReturnMoment.
  ///
  /// In en, this message translates to:
  /// **'Exact return: {time}'**
  String advReturnMoment(String time);

  /// No description provided for @advLunarReturn.
  ///
  /// In en, this message translates to:
  /// **'Next lunar return'**
  String get advLunarReturn;

  /// No description provided for @advComposite.
  ///
  /// In en, this message translates to:
  /// **'Composite chart'**
  String get advComposite;

  /// No description provided for @advCompositeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Midpoint chart of a relationship'**
  String get advCompositeSubtitle;

  /// No description provided for @advCompositeIntro.
  ///
  /// In en, this message translates to:
  /// **'A composite chart places every planet at the midpoint between two people\'s positions. Western astrologers read it as the chart of the relationship itself.'**
  String get advCompositeIntro;

  /// No description provided for @advPersonA.
  ///
  /// In en, this message translates to:
  /// **'First person'**
  String get advPersonA;

  /// No description provided for @advPersonB.
  ///
  /// In en, this message translates to:
  /// **'Second person'**
  String get advPersonB;

  /// No description provided for @advCompositeNeedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Add at least two profiles with birth dates to make a composite chart.'**
  String get advCompositeNeedProfiles;

  /// No description provided for @advPositions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get advPositions;

  /// No description provided for @aiAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Drishti'**
  String get aiAskTitle;

  /// No description provided for @aiAskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions about your chart, answered from its calculations'**
  String get aiAskSubtitle;

  /// No description provided for @aiAskHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about career, studies, relationships…'**
  String get aiAskHint;

  /// No description provided for @aiSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// No description provided for @aiStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get aiStop;

  /// No description provided for @aiBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get aiBasedOn;

  /// No description provided for @aiNotes.
  ///
  /// In en, this message translates to:
  /// **'Please note'**
  String get aiNotes;

  /// No description provided for @aiImproveWith.
  ///
  /// In en, this message translates to:
  /// **'Make this more accurate'**
  String get aiImproveWith;

  /// No description provided for @aiNoProfile.
  ///
  /// In en, this message translates to:
  /// **'Create a profile with a birth date to ask questions about a chart.'**
  String get aiNoProfile;

  /// No description provided for @aiProfileFor.
  ///
  /// In en, this message translates to:
  /// **'Answers for {name}'**
  String aiProfileFor(String name);

  /// No description provided for @aiRuleMode.
  ///
  /// In en, this message translates to:
  /// **'Answers come from Drishti\'s built-in rules, which work offline on every phone. Download the on-phone AI model for conversational answers.'**
  String get aiRuleMode;

  /// No description provided for @aiModelMode.
  ///
  /// In en, this message translates to:
  /// **'Using the on-phone AI model. Every answer is checked against your calculated chart.'**
  String get aiModelMode;

  /// No description provided for @aiReplaced.
  ///
  /// In en, this message translates to:
  /// **'The AI\'s draft did not pass Drishti\'s safety and accuracy check, so the rule-based answer is shown instead.'**
  String get aiReplaced;

  /// No description provided for @aiLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The AI model could not be loaded on this phone, so rule-based answers are used.'**
  String get aiLoadFailed;

  /// No description provided for @aiExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get aiExplain;

  /// No description provided for @aiAskMore.
  ///
  /// In en, this message translates to:
  /// **'Ask more'**
  String get aiAskMore;

  /// No description provided for @aiSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get aiSource;

  /// No description provided for @aiTryAsking.
  ///
  /// In en, this message translates to:
  /// **'Try asking'**
  String get aiTryAsking;

  /// No description provided for @aiSuggestCareer.
  ///
  /// In en, this message translates to:
  /// **'How does my chart look for career?'**
  String get aiSuggestCareer;

  /// No description provided for @aiSuggestPersonality.
  ///
  /// In en, this message translates to:
  /// **'What does my chart say about my nature?'**
  String get aiSuggestPersonality;

  /// No description provided for @aiSuggestPeriod.
  ///
  /// In en, this message translates to:
  /// **'What does my current dasha mean?'**
  String get aiSuggestPeriod;

  /// No description provided for @aiSuggestStudies.
  ///
  /// In en, this message translates to:
  /// **'When is a good period for studies?'**
  String get aiSuggestStudies;

  /// No description provided for @aiHistory.
  ///
  /// In en, this message translates to:
  /// **'Previous questions'**
  String get aiHistory;

  /// No description provided for @aiModelTitle.
  ///
  /// In en, this message translates to:
  /// **'On-phone AI model'**
  String get aiModelTitle;

  /// No description provided for @aiModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download, use or remove the AI model'**
  String get aiModelSubtitle;

  /// No description provided for @aiModelIntro.
  ///
  /// In en, this message translates to:
  /// **'The AI model runs entirely on your phone. Nothing you ask is sent anywhere. Without it, Drishti still answers using its built-in rules.'**
  String get aiModelIntro;

  /// No description provided for @aiNotReleased.
  ///
  /// In en, this message translates to:
  /// **'Not released yet'**
  String get aiNotReleased;

  /// No description provided for @aiDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get aiDownload;

  /// No description provided for @aiDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String aiDownloading(String percent);

  /// No description provided for @aiPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get aiPause;

  /// No description provided for @aiResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get aiResume;

  /// No description provided for @aiDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get aiDelete;

  /// No description provided for @aiInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get aiInstalled;

  /// No description provided for @aiUse.
  ///
  /// In en, this message translates to:
  /// **'Use this model'**
  String get aiUse;

  /// No description provided for @aiInUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get aiInUse;

  /// No description provided for @aiStopUsing.
  ///
  /// In en, this message translates to:
  /// **'Stop using'**
  String get aiStopUsing;

  /// No description provided for @aiWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download only on Wi‑Fi'**
  String get aiWifiOnly;

  /// No description provided for @aiMinRam.
  ///
  /// In en, this message translates to:
  /// **'Needs about {gb} GB of RAM'**
  String aiMinRam(int gb);

  /// No description provided for @aiLicense.
  ///
  /// In en, this message translates to:
  /// **'Licence: {license}'**
  String aiLicense(String license);

  /// No description provided for @aiMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'AI memory'**
  String get aiMemoryTitle;

  /// No description provided for @aiMemorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'See or delete what Drishti remembers'**
  String get aiMemorySubtitle;

  /// No description provided for @aiMemoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing remembered yet.'**
  String get aiMemoryEmpty;

  /// No description provided for @aiLifeFacts.
  ///
  /// In en, this message translates to:
  /// **'Things you told Drishti'**
  String get aiLifeFacts;

  /// No description provided for @aiLifeFactsInfo.
  ///
  /// In en, this message translates to:
  /// **'Optional notes (e.g. \"I work in teaching\") that help answers. Stored only on this phone.'**
  String get aiLifeFactsInfo;

  /// No description provided for @aiAddLifeFact.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get aiAddLifeFact;

  /// No description provided for @aiLifeFactHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I am studying engineering'**
  String get aiLifeFactHint;

  /// No description provided for @aiClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear this profile\'s memory'**
  String get aiClearHistory;

  /// No description provided for @aiClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all AI memory'**
  String get aiClearAll;

  /// No description provided for @aiClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'This deletes the remembered questions and notes from this phone.'**
  String get aiClearConfirm;

  /// No description provided for @aiCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aiCancel;

  /// No description provided for @aiConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get aiConfirm;

  /// No description provided for @aiAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get aiAdd;

  /// No description provided for @rectTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth time rectification'**
  String get rectTitle;

  /// No description provided for @rectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate an uncertain birth time from life events'**
  String get rectSubtitle;

  /// No description provided for @rectIntro.
  ///
  /// In en, this message translates to:
  /// **'If you know your birth time only roughly, Drishti can check which times in a range fit your major life events best, using traditional dasha and transit rules.'**
  String get rectIntro;

  /// No description provided for @rectNeedsDatePlace.
  ///
  /// In en, this message translates to:
  /// **'Rectification needs a birth date and birthplace in this profile.'**
  String get rectNeedsDatePlace;

  /// No description provided for @rectChooseProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get rectChooseProfile;

  /// No description provided for @rectWindow.
  ///
  /// In en, this message translates to:
  /// **'Possible birth time range'**
  String get rectWindow;

  /// No description provided for @rectFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get rectFrom;

  /// No description provided for @rectTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get rectTo;

  /// No description provided for @rectEvents.
  ///
  /// In en, this message translates to:
  /// **'Life events'**
  String get rectEvents;

  /// No description provided for @rectEventsInfo.
  ///
  /// In en, this message translates to:
  /// **'Add dated events you are sure about. Three or more give more meaningful results.'**
  String get rectEventsInfo;

  /// No description provided for @rectAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get rectAddEvent;

  /// No description provided for @rectNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events added yet.'**
  String get rectNoEvents;

  /// No description provided for @rectEventType.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get rectEventType;

  /// No description provided for @rectEventDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get rectEventDate;

  /// No description provided for @rectEventNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get rectEventNote;

  /// No description provided for @rectSaveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get rectSaveEvent;

  /// No description provided for @rectRun.
  ///
  /// In en, this message translates to:
  /// **'Find consistent times'**
  String get rectRun;

  /// No description provided for @rectRunning.
  ///
  /// In en, this message translates to:
  /// **'Checking possible birth times…'**
  String get rectRunning;

  /// No description provided for @rectResults.
  ///
  /// In en, this message translates to:
  /// **'Time ranges that fit best'**
  String get rectResults;

  /// No description provided for @rectScore.
  ///
  /// In en, this message translates to:
  /// **'Fit score {score}'**
  String rectScore(String score);

  /// No description provided for @rectLagnas.
  ///
  /// In en, this message translates to:
  /// **'Lagna {d1} · Navamsa {d9} · Dasamsa {d10}'**
  String rectLagnas(String d1, String d9, String d10);

  /// No description provided for @rectApply.
  ///
  /// In en, this message translates to:
  /// **'Use {time}'**
  String rectApply(String time);

  /// No description provided for @rectApplied.
  ///
  /// In en, this message translates to:
  /// **'Birth time set to {time} and marked approximate.'**
  String rectApplied(String time);

  /// No description provided for @rectCaveat.
  ///
  /// In en, this message translates to:
  /// **'Rectification is an estimate based on traditional rules, not a measurement. Different astrologers use different methods and may reach different times. Prefer a recorded birth time (hospital or family records) whenever you have one.'**
  String get rectCaveat;

  /// No description provided for @rectNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No reasons found for this event at this time.'**
  String get rectNoMatch;

  /// No description provided for @rectEventMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get rectEventMarriage;

  /// No description provided for @rectEventChildBirth.
  ///
  /// In en, this message translates to:
  /// **'Birth of a child'**
  String get rectEventChildBirth;

  /// No description provided for @rectEventJobStart.
  ///
  /// In en, this message translates to:
  /// **'Started a job'**
  String get rectEventJobStart;

  /// No description provided for @rectEventJobLoss.
  ///
  /// In en, this message translates to:
  /// **'Left or lost a job'**
  String get rectEventJobLoss;

  /// No description provided for @rectEventRelocation.
  ///
  /// In en, this message translates to:
  /// **'Moved home or city'**
  String get rectEventRelocation;

  /// No description provided for @rectEventAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get rectEventAccident;

  /// No description provided for @rectEventIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get rectEventIllness;

  /// No description provided for @rectEventParentDeath.
  ///
  /// In en, this message translates to:
  /// **'Loss of a parent'**
  String get rectEventParentDeath;

  /// No description provided for @rectEventEducation.
  ///
  /// In en, this message translates to:
  /// **'Education milestone'**
  String get rectEventEducation;

  /// No description provided for @rectEventOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rectEventOther;

  /// No description provided for @festTitle.
  ///
  /// In en, this message translates to:
  /// **'Festivals & Vrats'**
  String get festTitle;

  /// No description provided for @festSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Festivals, Ekadashis, sankrantis and eclipses for your place'**
  String get festSubtitle;

  /// No description provided for @festAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get festAll;

  /// No description provided for @festFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get festFestivals;

  /// No description provided for @festVrats.
  ///
  /// In en, this message translates to:
  /// **'Vrats'**
  String get festVrats;

  /// No description provided for @festSankrantis.
  ///
  /// In en, this message translates to:
  /// **'Sankrantis'**
  String get festSankrantis;

  /// No description provided for @festEclipses.
  ///
  /// In en, this message translates to:
  /// **'Eclipses'**
  String get festEclipses;

  /// No description provided for @festNoEventsDay.
  ///
  /// In en, this message translates to:
  /// **'No festivals or vrats on this day.'**
  String get festNoEventsDay;

  /// No description provided for @festNoEventsMonth.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this filter in this month.'**
  String get festNoEventsMonth;

  /// No description provided for @festHowDecided.
  ///
  /// In en, this message translates to:
  /// **'How this date was decided'**
  String get festHowDecided;

  /// No description provided for @festRegionalNote.
  ///
  /// In en, this message translates to:
  /// **'Regional and family traditions'**
  String get festRegionalNote;

  /// No description provided for @festTimings.
  ///
  /// In en, this message translates to:
  /// **'Timings'**
  String get festTimings;

  /// No description provided for @festTithiSpan.
  ///
  /// In en, this message translates to:
  /// **'Tithi: {start} to {end}'**
  String festTithiSpan(String start, String end);

  /// No description provided for @festWindow.
  ///
  /// In en, this message translates to:
  /// **'Observance window: {start} to {end}'**
  String festWindow(String start, String end);

  /// No description provided for @festMoment.
  ///
  /// In en, this message translates to:
  /// **'Exact moment: {time}'**
  String festMoment(String time);

  /// No description provided for @festCalculatedFor.
  ///
  /// In en, this message translates to:
  /// **'Calculated for {place}'**
  String festCalculatedFor(String place);

  /// No description provided for @festDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Dates follow the common North Indian (Smarta) panchang rules for the chosen place. Your family, temple or regional tradition may observe some days differently; both are valid.'**
  String get festDisclaimer;

  /// No description provided for @festToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get festToday;

  /// No description provided for @festLoading.
  ///
  /// In en, this message translates to:
  /// **'Calculating the calendar on your phone…'**
  String get festLoading;

  /// No description provided for @festOpenMuhurat.
  ///
  /// In en, this message translates to:
  /// **'Muhurat finder'**
  String get festOpenMuhurat;

  /// No description provided for @muhuratTitle.
  ///
  /// In en, this message translates to:
  /// **'Muhurat Finder'**
  String get muhuratTitle;

  /// No description provided for @muhuratSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auspicious times for important beginnings'**
  String get muhuratSubtitle;

  /// No description provided for @muhuratActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get muhuratActivity;

  /// No description provided for @muhuratFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get muhuratFrom;

  /// No description provided for @muhuratTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get muhuratTo;

  /// No description provided for @muhuratPersonalise.
  ///
  /// In en, this message translates to:
  /// **'Personalise for'**
  String get muhuratPersonalise;

  /// No description provided for @muhuratGeneral.
  ///
  /// In en, this message translates to:
  /// **'General (no profile)'**
  String get muhuratGeneral;

  /// No description provided for @muhuratPersonaliseInfo.
  ///
  /// In en, this message translates to:
  /// **'With a profile, Tara Bala and Chandra Bala (how the day\'s Moon relates to the birth Moon) are added to the checks.'**
  String get muhuratPersonaliseInfo;

  /// No description provided for @muhuratFind.
  ///
  /// In en, this message translates to:
  /// **'Find muhurats'**
  String get muhuratFind;

  /// No description provided for @muhuratSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching day by day…'**
  String get muhuratSearching;

  /// No description provided for @muhuratNoResults.
  ///
  /// In en, this message translates to:
  /// **'No window met all the rules in this range. Try a longer range or relax the seasonal rules.'**
  String get muhuratNoResults;

  /// No description provided for @muhuratResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 window found} other{{count} windows found}}'**
  String muhuratResults(int count);

  /// No description provided for @muhuratScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}/100'**
  String muhuratScore(int score);

  /// No description provided for @muhuratRangeTooLong.
  ///
  /// In en, this message translates to:
  /// **'Please choose a range of up to 180 days.'**
  String get muhuratRangeTooLong;

  /// No description provided for @muhuratRulesMet.
  ///
  /// In en, this message translates to:
  /// **'Rules met'**
  String get muhuratRulesMet;

  /// No description provided for @muhuratRulesMissed.
  ///
  /// In en, this message translates to:
  /// **'Rules not met'**
  String get muhuratRulesMissed;

  /// No description provided for @muhuratDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This follows general Panchang-shuddhi rules found in muhurta texts and popular panchangs. Lists of favourable days differ between traditions, and important ceremonies are often fixed together with a family priest or astrologer.'**
  String get muhuratDisclaimer;

  /// No description provided for @muhuratAvoidKharmas.
  ///
  /// In en, this message translates to:
  /// **'Avoid Kharmas'**
  String get muhuratAvoidKharmas;

  /// No description provided for @muhuratAvoidKharmasInfo.
  ///
  /// In en, this message translates to:
  /// **'When the Sun is in sidereal Sagittarius or Pisces (about mid-December to mid-January and mid-March to mid-April), many traditions pause weddings and similar ceremonies.'**
  String get muhuratAvoidKharmasInfo;

  /// No description provided for @muhuratAvoidCombust.
  ///
  /// In en, this message translates to:
  /// **'Avoid Guru/Shukra asta'**
  String get muhuratAvoidCombust;

  /// No description provided for @muhuratAvoidCombustInfo.
  ///
  /// In en, this message translates to:
  /// **'When Jupiter or Venus is too close to the Sun (combust), they are traditionally considered too weak for weddings and house-warming.'**
  String get muhuratAvoidCombustInfo;

  /// No description provided for @muhuratAvoidChaturmas.
  ///
  /// In en, this message translates to:
  /// **'Avoid Chaturmas'**
  String get muhuratAvoidChaturmas;

  /// No description provided for @muhuratAvoidChaturmasInfo.
  ///
  /// In en, this message translates to:
  /// **'From Devshayani to Prabodhini Ekadashi, North Indian practice usually avoids weddings and house-warming. Many South Indian traditions do not follow this.'**
  String get muhuratAvoidChaturmasInfo;

  /// No description provided for @muhuratActMarriage.
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get muhuratActMarriage;

  /// No description provided for @muhuratActGrihaPravesh.
  ///
  /// In en, this message translates to:
  /// **'Griha Pravesh (house-warming)'**
  String get muhuratActGrihaPravesh;

  /// No description provided for @muhuratActVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle purchase'**
  String get muhuratActVehicle;

  /// No description provided for @muhuratActProperty.
  ///
  /// In en, this message translates to:
  /// **'Property purchase'**
  String get muhuratActProperty;

  /// No description provided for @muhuratActBusiness.
  ///
  /// In en, this message translates to:
  /// **'Starting a business'**
  String get muhuratActBusiness;

  /// No description provided for @muhuratActTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get muhuratActTravel;

  /// No description provided for @muhuratActNaming.
  ///
  /// In en, this message translates to:
  /// **'Naming ceremony (Namakarana)'**
  String get muhuratActNaming;

  /// No description provided for @muhuratActMundan.
  ///
  /// In en, this message translates to:
  /// **'Mundan (first haircut)'**
  String get muhuratActMundan;

  /// No description provided for @muhuratActEducation.
  ///
  /// In en, this message translates to:
  /// **'Starting education (Vidyarambha)'**
  String get muhuratActEducation;

  /// No description provided for @muhuratChkNakshatra.
  ///
  /// In en, this message translates to:
  /// **'Favourable nakshatra: {value}'**
  String muhuratChkNakshatra(String value);

  /// No description provided for @muhuratChkTithi.
  ///
  /// In en, this message translates to:
  /// **'Favourable tithi: {value}'**
  String muhuratChkTithi(String value);

  /// No description provided for @muhuratChkVara.
  ///
  /// In en, this message translates to:
  /// **'Favourable weekday: {value}'**
  String muhuratChkVara(String value);

  /// No description provided for @muhuratChkYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga not on the avoid list: {value}'**
  String muhuratChkYoga(String value);

  /// No description provided for @muhuratChkVyatipata.
  ///
  /// In en, this message translates to:
  /// **'Not Vyatipata or Vaidhriti yoga'**
  String get muhuratChkVyatipata;

  /// No description provided for @muhuratChkVishti.
  ///
  /// In en, this message translates to:
  /// **'Not Vishti (Bhadra) karana'**
  String get muhuratChkVishti;

  /// No description provided for @muhuratChkRahuKaal.
  ///
  /// In en, this message translates to:
  /// **'Outside Rahu Kaal'**
  String get muhuratChkRahuKaal;

  /// No description provided for @muhuratChkYamaganda.
  ///
  /// In en, this message translates to:
  /// **'Outside Yamaganda'**
  String get muhuratChkYamaganda;

  /// No description provided for @muhuratChkGulika.
  ///
  /// In en, this message translates to:
  /// **'Outside Gulika Kaal'**
  String get muhuratChkGulika;

  /// No description provided for @muhuratChkEclipse.
  ///
  /// In en, this message translates to:
  /// **'Not an eclipse day'**
  String get muhuratChkEclipse;

  /// No description provided for @muhuratChkKharmas.
  ///
  /// In en, this message translates to:
  /// **'Not in Kharmas'**
  String get muhuratChkKharmas;

  /// No description provided for @muhuratChkCombustJupiter.
  ///
  /// In en, this message translates to:
  /// **'Jupiter not combust'**
  String get muhuratChkCombustJupiter;

  /// No description provided for @muhuratChkCombustVenus.
  ///
  /// In en, this message translates to:
  /// **'Venus not combust'**
  String get muhuratChkCombustVenus;

  /// No description provided for @muhuratChkChaturmas.
  ///
  /// In en, this message translates to:
  /// **'Not in Chaturmas'**
  String get muhuratChkChaturmas;

  /// No description provided for @muhuratChkTara.
  ///
  /// In en, this message translates to:
  /// **'Tara Bala: {value}'**
  String muhuratChkTara(String value);

  /// No description provided for @muhuratChkChandra.
  ///
  /// In en, this message translates to:
  /// **'Chandra Bala: Moon in house {value} from the birth Moon'**
  String muhuratChkChandra(String value);

  /// No description provided for @wellnessThemeSun.
  ///
  /// In en, this message translates to:
  /// **'steady confidence; try a sunrise practice'**
  String get wellnessThemeSun;

  /// No description provided for @wellnessThemeMoon.
  ///
  /// In en, this message translates to:
  /// **'calm and soothing; try 4-7-8 breathing'**
  String get wellnessThemeMoon;

  /// No description provided for @wellnessThemeMars.
  ///
  /// In en, this message translates to:
  /// **'energy and courage; try box breathing'**
  String get wellnessThemeMars;

  /// No description provided for @wellnessThemeMercury.
  ///
  /// In en, this message translates to:
  /// **'clarity and focus; try nadi shodhana'**
  String get wellnessThemeMercury;

  /// No description provided for @wellnessThemeJupiter.
  ///
  /// In en, this message translates to:
  /// **'gratitude and wisdom; try Om chanting'**
  String get wellnessThemeJupiter;

  /// No description provided for @wellnessThemeVenus.
  ///
  /// In en, this message translates to:
  /// **'gentleness and harmony; try 4-7-8 breathing'**
  String get wellnessThemeVenus;

  /// No description provided for @wellnessThemeSaturn.
  ///
  /// In en, this message translates to:
  /// **'patience and grounding; try a longer box breathing session'**
  String get wellnessThemeSaturn;

  /// A time or date something lasts until; word order differs by language.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String untilDate(String date);

  /// No description provided for @advKarakaAK.
  ///
  /// In en, this message translates to:
  /// **'Atmakaraka'**
  String get advKarakaAK;

  /// No description provided for @advKarakaAmK.
  ///
  /// In en, this message translates to:
  /// **'Amatyakaraka'**
  String get advKarakaAmK;

  /// No description provided for @advKarakaBK.
  ///
  /// In en, this message translates to:
  /// **'Bhratrikaraka'**
  String get advKarakaBK;

  /// No description provided for @advKarakaMK.
  ///
  /// In en, this message translates to:
  /// **'Matrikaraka'**
  String get advKarakaMK;

  /// No description provided for @advKarakaPiK.
  ///
  /// In en, this message translates to:
  /// **'Pitrikaraka'**
  String get advKarakaPiK;

  /// No description provided for @advKarakaPK.
  ///
  /// In en, this message translates to:
  /// **'Putrakaraka'**
  String get advKarakaPK;

  /// No description provided for @advKarakaGK.
  ///
  /// In en, this message translates to:
  /// **'Gnatikaraka'**
  String get advKarakaGK;

  /// No description provided for @advKarakaDK.
  ///
  /// In en, this message translates to:
  /// **'Darakaraka'**
  String get advKarakaDK;

  /// Start of a time range.
  ///
  /// In en, this message translates to:
  /// **'From {time}'**
  String fromTime(String time);

  /// End of a time range.
  ///
  /// In en, this message translates to:
  /// **'To {time}'**
  String toTime(String time);

  /// No description provided for @aiModelLanguages.
  ///
  /// In en, this message translates to:
  /// **'AI answers in: {languages}. In other languages Drishti uses its built-in explanations.'**
  String aiModelLanguages(String languages);

  /// No description provided for @aiWifiOnlyInfo.
  ///
  /// In en, this message translates to:
  /// **'Large downloads start only on Wi‑Fi. On mobile data, Drishti asks you first.'**
  String get aiWifiOnlyInfo;

  /// No description provided for @aiNotOnWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Not on Wi‑Fi'**
  String get aiNotOnWifiTitle;

  /// No description provided for @aiNotOnWifiBody.
  ///
  /// In en, this message translates to:
  /// **'“Download only on Wi‑Fi” is on and this phone is not on Wi‑Fi. About {size} would use your mobile data. Download anyway?'**
  String aiNotOnWifiBody(String size);

  /// No description provided for @aiDownloadAnyway.
  ///
  /// In en, this message translates to:
  /// **'Download anyway'**
  String get aiDownloadAnyway;

  /// No description provided for @rewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad?'**
  String get rewardTitle;

  /// No description provided for @rewardBody.
  ///
  /// In en, this message translates to:
  /// **'Drishti is free for everyone because of ads. Watch a short ad to continue. After that, there are no more of these for 10 minutes.'**
  String get rewardBody;

  /// No description provided for @rewardWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get rewardWatch;

  /// No description provided for @rewardNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get rewardNotNow;

  /// No description provided for @rewardShowResult.
  ///
  /// In en, this message translates to:
  /// **'Show match result'**
  String get rewardShowResult;

  /// No description provided for @aiMoreDetail.
  ///
  /// In en, this message translates to:
  /// **'More detail'**
  String get aiMoreDetail;

  /// No description provided for @aiWhy.
  ///
  /// In en, this message translates to:
  /// **'Why? (chart reasons)'**
  String get aiWhy;

  /// No description provided for @dashaComingNext.
  ///
  /// In en, this message translates to:
  /// **'Coming next'**
  String get dashaComingNext;

  /// No description provided for @dashaMonthByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month by month'**
  String get dashaMonthByMonth;

  /// Start date of a coming period; word order differs by language.
  ///
  /// In en, this message translates to:
  /// **'from {date}'**
  String dashaFromDate(String date);

  /// No description provided for @dashaMonthNote.
  ///
  /// In en, this message translates to:
  /// **'Each line is a period running in that month: Mahadasha / Antardasha / Pratyantardasha. Tap 💡 for what it traditionally means.'**
  String get dashaMonthNote;

  /// No description provided for @matchWhatItMeans.
  ///
  /// In en, this message translates to:
  /// **'What it means for you'**
  String get matchWhatItMeans;

  /// No description provided for @matchAreaVarna.
  ///
  /// In en, this message translates to:
  /// **'Values and outlook'**
  String get matchAreaVarna;

  /// No description provided for @matchAreaVashya.
  ///
  /// In en, this message translates to:
  /// **'Mutual attraction and influence'**
  String get matchAreaVashya;

  /// No description provided for @matchAreaTara.
  ///
  /// In en, this message translates to:
  /// **'Wellbeing and fortune together'**
  String get matchAreaTara;

  /// No description provided for @matchAreaYoni.
  ///
  /// In en, this message translates to:
  /// **'Physical and intimate compatibility'**
  String get matchAreaYoni;

  /// No description provided for @matchAreaMaitri.
  ///
  /// In en, this message translates to:
  /// **'Friendship and understanding'**
  String get matchAreaMaitri;

  /// No description provided for @matchAreaGana.
  ///
  /// In en, this message translates to:
  /// **'Temperament'**
  String get matchAreaGana;

  /// No description provided for @matchAreaBhakoot.
  ///
  /// In en, this message translates to:
  /// **'Family welfare and growth'**
  String get matchAreaBhakoot;

  /// No description provided for @matchAreaNadi.
  ///
  /// In en, this message translates to:
  /// **'Health and children (traditional view)'**
  String get matchAreaNadi;

  /// One life area of a kundli match and how well it matches.
  ///
  /// In en, this message translates to:
  /// **'{area}: matches well by tradition.'**
  String matchLevelGood(String area);

  /// One life area of a kundli match and how well it matches.
  ///
  /// In en, this message translates to:
  /// **'{area}: partly matches.'**
  String matchLevelPart(String area);

  /// One life area of a kundli match and how well it matches.
  ///
  /// In en, this message translates to:
  /// **'{area}: tradition sees a gap here, so it asks for more understanding and effort.'**
  String matchLevelLow(String area);

  /// No description provided for @numeroTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to see how it is calculated and what it means'**
  String get numeroTapForDetails;

  /// No description provided for @numeroHowCalculated.
  ///
  /// In en, this message translates to:
  /// **'How it is calculated'**
  String get numeroHowCalculated;

  /// No description provided for @numeroWhatItMeans.
  ///
  /// In en, this message translates to:
  /// **'What it means'**
  String get numeroWhatItMeans;

  /// No description provided for @numeroRepresents.
  ///
  /// In en, this message translates to:
  /// **'What this number represents'**
  String get numeroRepresents;

  /// No description provided for @numeroStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get numeroStrengths;

  /// No description provided for @numeroChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get numeroChallenges;

  /// No description provided for @numeroGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get numeroGuidance;

  /// No description provided for @numeroPlanetLine.
  ///
  /// In en, this message translates to:
  /// **'Traditional planet: {planet}'**
  String numeroPlanetLine(String planet);

  /// No description provided for @numeroPartMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get numeroPartMonth;

  /// No description provided for @numeroPartDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get numeroPartDay;

  /// No description provided for @numeroPartYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get numeroPartYear;

  /// No description provided for @numeroPartCurrentYear.
  ///
  /// In en, this message translates to:
  /// **'Current year'**
  String get numeroPartCurrentYear;

  /// No description provided for @numeroPartSum.
  ///
  /// In en, this message translates to:
  /// **'Add them'**
  String get numeroPartSum;

  /// No description provided for @numeroPartDateDigits.
  ///
  /// In en, this message translates to:
  /// **'All digits of the date'**
  String get numeroPartDateDigits;

  /// No description provided for @numeroPartLetters.
  ///
  /// In en, this message translates to:
  /// **'All letters'**
  String get numeroPartLetters;

  /// No description provided for @numeroPartVowels.
  ///
  /// In en, this message translates to:
  /// **'Vowels (A, E, I, O, U)'**
  String get numeroPartVowels;

  /// No description provided for @numeroPartConsonants.
  ///
  /// In en, this message translates to:
  /// **'Consonants (Y is counted as a consonant)'**
  String get numeroPartConsonants;

  /// No description provided for @numeroLetterTablePy.
  ///
  /// In en, this message translates to:
  /// **'Pythagorean letter values'**
  String get numeroLetterTablePy;

  /// No description provided for @numeroLetterTableCh.
  ///
  /// In en, this message translates to:
  /// **'Chaldean letter values'**
  String get numeroLetterTableCh;

  /// No description provided for @numeroMasterKept.
  ///
  /// In en, this message translates to:
  /// **'{number} is a master number, so it is kept as it is.'**
  String numeroMasterKept(int number);

  /// No description provided for @numeroAlwaysReduced.
  ///
  /// In en, this message translates to:
  /// **'This number is always reduced to a single digit; master numbers are not kept.'**
  String get numeroAlwaysReduced;

  /// No description provided for @numeroResult.
  ///
  /// In en, this message translates to:
  /// **'Result: {number}'**
  String numeroResult(int number);

  /// No description provided for @numeroCombinations.
  ///
  /// In en, this message translates to:
  /// **'Combinations'**
  String get numeroCombinations;

  /// No description provided for @numeroPairTitle.
  ///
  /// In en, this message translates to:
  /// **'Mulank and Bhagyank pair'**
  String get numeroPairTitle;

  /// No description provided for @numeroPairNumbers.
  ///
  /// In en, this message translates to:
  /// **'Mulank {mulank} ({mulankPlanet}) and Bhagyank {bhagyank} ({bhagyankPlanet})'**
  String numeroPairNumbers(
    int mulank,
    String mulankPlanet,
    int bhagyank,
    String bhagyankPlanet,
  );

  /// No description provided for @numeroViewLine.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}: {relation}'**
  String numeroViewLine(String from, String to, String relation);

  /// No description provided for @numeroRelFriend.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get numeroRelFriend;

  /// No description provided for @numeroRelNeutral.
  ///
  /// In en, this message translates to:
  /// **'neutral'**
  String get numeroRelNeutral;

  /// No description provided for @numeroRelEnemy.
  ///
  /// In en, this message translates to:
  /// **'enemy'**
  String get numeroRelEnemy;

  /// No description provided for @numeroPairSame.
  ///
  /// In en, this message translates to:
  /// **'Same number'**
  String get numeroPairSame;

  /// No description provided for @numeroPairFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get numeroPairFriendly;

  /// No description provided for @numeroPairNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get numeroPairNeutral;

  /// No description provided for @numeroPairChallenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get numeroPairChallenging;

  /// No description provided for @numeroLoShuTitle.
  ///
  /// In en, this message translates to:
  /// **'Lo Shu grid'**
  String get numeroLoShuTitle;

  /// No description provided for @numeroLoShuAddMB.
  ///
  /// In en, this message translates to:
  /// **'Add Mulank and Bhagyank (usual Indian practice)'**
  String get numeroLoShuAddMB;

  /// No description provided for @numeroLoShuDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits placed: {digits}'**
  String numeroLoShuDigits(String digits);

  /// No description provided for @numeroLoShuRepeated.
  ///
  /// In en, this message translates to:
  /// **'Repeated numbers'**
  String get numeroLoShuRepeated;

  /// No description provided for @numeroLoShuMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing numbers'**
  String get numeroLoShuMissing;

  /// No description provided for @numeroLoShuPlanes.
  ///
  /// In en, this message translates to:
  /// **'Complete planes'**
  String get numeroLoShuPlanes;

  /// No description provided for @numeroLoShuNoRepeated.
  ///
  /// In en, this message translates to:
  /// **'No number repeats.'**
  String get numeroLoShuNoRepeated;

  /// No description provided for @numeroLoShuNoMissing.
  ///
  /// In en, this message translates to:
  /// **'Every number from 1 to 9 is present.'**
  String get numeroLoShuNoMissing;

  /// No description provided for @numeroLoShuNoPlanes.
  ///
  /// In en, this message translates to:
  /// **'No row, column or diagonal is complete.'**
  String get numeroLoShuNoPlanes;

  /// No description provided for @numeroCompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Chaldean compound number'**
  String get numeroCompoundTitle;

  /// No description provided for @numeroCompoundReduced.
  ///
  /// In en, this message translates to:
  /// **'Your total {total} is above 52, so its digits are added: {compound}.'**
  String numeroCompoundReduced(int total, int compound);

  /// No description provided for @numeroPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal year, month and day'**
  String get numeroPersonalTitle;

  /// No description provided for @numeroPersonalFor.
  ///
  /// In en, this message translates to:
  /// **'For {date}'**
  String numeroPersonalFor(String date);

  /// No description provided for @numeroPersonalYear.
  ///
  /// In en, this message translates to:
  /// **'Personal year'**
  String get numeroPersonalYear;

  /// No description provided for @numeroPersonalMonth.
  ///
  /// In en, this message translates to:
  /// **'Personal month'**
  String get numeroPersonalMonth;

  /// No description provided for @numeroPersonalDay.
  ///
  /// In en, this message translates to:
  /// **'Personal day'**
  String get numeroPersonalDay;

  /// No description provided for @numeroAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About these methods'**
  String get numeroAboutTitle;

  /// No description provided for @numeroNeedDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a birth date to see the Lo Shu grid, the Mulank and Bhagyank pair and your personal cycles.'**
  String get numeroNeedDate;

  /// No description provided for @numeroNameLatinOnly.
  ///
  /// In en, this message translates to:
  /// **'Name numbers use the letters A to Z. Type the name in English letters to see them.'**
  String get numeroNameLatinOnly;

  /// No description provided for @numeroCompoundNone.
  ///
  /// In en, this message translates to:
  /// **'This total does not give a compound number between 10 and 52, so only the single digit is read.'**
  String get numeroCompoundNone;

  /// No description provided for @toolInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'About this tool'**
  String get toolInfoTooltip;

  /// No description provided for @toolInfoWhat.
  ///
  /// In en, this message translates to:
  /// **'What it is'**
  String get toolInfoWhat;

  /// No description provided for @toolInfoWhy.
  ///
  /// In en, this message translates to:
  /// **'Why it is used'**
  String get toolInfoWhy;

  /// No description provided for @toolInfoHow.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get toolInfoHow;

  /// No description provided for @toolInfoScience.
  ///
  /// In en, this message translates to:
  /// **'Math and science'**
  String get toolInfoScience;

  /// No description provided for @toolInfoReferences.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get toolInfoReferences;

  /// No description provided for @kootaWhatItIs.
  ///
  /// In en, this message translates to:
  /// **'What it is'**
  String get kootaWhatItIs;

  /// No description provided for @kootaYourResult.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get kootaYourResult;

  /// No description provided for @kootaExceptionsChecked.
  ///
  /// In en, this message translates to:
  /// **'Classical exceptions checked'**
  String get kootaExceptionsChecked;

  /// No description provided for @kootaApplies.
  ///
  /// In en, this message translates to:
  /// **'applies'**
  String get kootaApplies;

  /// No description provided for @kootaNotApplies.
  ///
  /// In en, this message translates to:
  /// **'does not apply'**
  String get kootaNotApplies;

  /// No description provided for @kootaTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any line to see what it is, your result and why.'**
  String get kootaTapHint;

  /// No description provided for @compConclusion.
  ///
  /// In en, this message translates to:
  /// **'What it means for you'**
  String get compConclusion;

  /// No description provided for @compAspectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Aspects in the composite chart'**
  String get compAspectsTitle;

  /// No description provided for @compSupportive.
  ///
  /// In en, this message translates to:
  /// **'supportive'**
  String get compSupportive;

  /// No description provided for @compChallenging.
  ///
  /// In en, this message translates to:
  /// **'challenging'**
  String get compChallenging;

  /// No description provided for @compNotCounted.
  ///
  /// In en, this message translates to:
  /// **'not counted'**
  String get compNotCounted;

  /// No description provided for @yogaWhatFor.
  ///
  /// In en, this message translates to:
  /// **'What it is for'**
  String get yogaWhatFor;

  /// No description provided for @palmTraceButton.
  ///
  /// In en, this message translates to:
  /// **'Trace the lines on my photo'**
  String get palmTraceButton;

  /// No description provided for @palmTraceTitle.
  ///
  /// In en, this message translates to:
  /// **'Trace your palm lines'**
  String get palmTraceTitle;

  /// No description provided for @palmTapIndex.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3: tap the base of your index finger (where it joins the palm).'**
  String get palmTapIndex;

  /// No description provided for @palmTapLittle.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3: tap the base of your little finger.'**
  String get palmTapLittle;

  /// No description provided for @palmTapWrist.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3: tap the middle of your wrist.'**
  String get palmTapWrist;

  /// Instruction to trace one palm line; {line} is the line's name.
  ///
  /// In en, this message translates to:
  /// **'Trace your {line} with one finger over the photo. The dotted line shows where it usually runs; follow your own line. Lift your finger where the line breaks.'**
  String palmTraceLine(String line);

  /// No description provided for @palmUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get palmUndo;

  /// No description provided for @palmCantSee.
  ///
  /// In en, this message translates to:
  /// **'I can\'t see this line'**
  String get palmCantSee;

  /// No description provided for @palmUseTracing.
  ///
  /// In en, this message translates to:
  /// **'Use my tracing'**
  String get palmUseTracing;

  /// No description provided for @palmTraceNote.
  ///
  /// In en, this message translates to:
  /// **'Drishti suggests the hand points and lines it finds in your photo. They can be wrong, so check each one and redraw any that does not match. The photo stays on your phone. Palmistry is a symbolic tradition, not a prediction.'**
  String get palmTraceNote;

  /// No description provided for @palmSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested from your tracing. Compare it with your hand and change it if it does not match.'**
  String get palmSuggested;

  /// No description provided for @palmDetecting.
  ///
  /// In en, this message translates to:
  /// **'Looking for your hand and palm lines in the photo…'**
  String get palmDetecting;

  /// No description provided for @palmHandNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find a hand in this photo. Tap the three points yourself, or use a clear photo of an open palm in good light.'**
  String get palmHandNotFound;

  /// A palm line found automatically; {line} is its name.
  ///
  /// In en, this message translates to:
  /// **'Drishti found your {line} (shown in colour). Check that it follows the crease in your photo. If it does not, tap Undo or simply draw over it.'**
  String palmAutoLine(String line);

  /// A palm line not found automatically; {line} is its name.
  ///
  /// In en, this message translates to:
  /// **'Drishti could not find your {line} clearly. Trace it with one finger, or tap “I can\'t see this line”.'**
  String palmAutoMissing(String line);

  /// No description provided for @childrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children (Santana)'**
  String get childrenTitle;

  /// No description provided for @childrenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Signs and timing for children, for one person or a couple'**
  String get childrenSubtitle;

  /// No description provided for @childrenIntro.
  ///
  /// In en, this message translates to:
  /// **'A traditional Vedic reading of children: the 5th house, Jupiter, the Saptamsha (D7) and the dasha periods. For a couple it adds the classical Beeja and Kshetra Sphuta.'**
  String get childrenIntro;

  /// No description provided for @childrenOne.
  ///
  /// In en, this message translates to:
  /// **'One person'**
  String get childrenOne;

  /// No description provided for @childrenCouple.
  ///
  /// In en, this message translates to:
  /// **'Couple'**
  String get childrenCouple;

  /// No description provided for @childrenPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get childrenPerson;

  /// No description provided for @childrenFather.
  ///
  /// In en, this message translates to:
  /// **'Father-to-be'**
  String get childrenFather;

  /// No description provided for @childrenMother.
  ///
  /// In en, this message translates to:
  /// **'Mother-to-be'**
  String get childrenMother;

  /// No description provided for @childrenNeedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Add a profile with a birth date first.'**
  String get childrenNeedProfiles;

  /// No description provided for @childrenNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Add a second profile to read a couple.'**
  String get childrenNeedTwo;

  /// No description provided for @childrenAdultsOnly.
  ///
  /// In en, this message translates to:
  /// **'This reading is available for adults only.'**
  String get childrenAdultsOnly;

  /// No description provided for @childrenWindows.
  ///
  /// In en, this message translates to:
  /// **'Periods the method marks for children'**
  String get childrenWindows;

  /// No description provided for @childrenSharedWindows.
  ///
  /// In en, this message translates to:
  /// **'Periods marked for both of you'**
  String get childrenSharedWindows;

  /// No description provided for @childrenApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Without a birth time, houses are counted from the Moon sign and the Moon\'s position is approximate.'**
  String get childrenApproxNote;

  /// No description provided for @childrenTradTitle.
  ///
  /// In en, this message translates to:
  /// **'Boy or girl? What the old texts say'**
  String get childrenTradTitle;

  /// No description provided for @childrenTradSubtitle.
  ///
  /// In en, this message translates to:
  /// **'History and science, with no prediction'**
  String get childrenTradSubtitle;

  /// No description provided for @matchAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Overall advice'**
  String get matchAdviceTitle;

  /// No description provided for @matchAdviceStrengths.
  ///
  /// In en, this message translates to:
  /// **'What is strong'**
  String get matchAdviceStrengths;

  /// No description provided for @matchAdviceCautions.
  ///
  /// In en, this message translates to:
  /// **'What needs care'**
  String get matchAdviceCautions;

  /// No description provided for @matchAdviceSteps.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get matchAdviceSteps;

  /// No description provided for @matchAdviceRemedies.
  ///
  /// In en, this message translates to:
  /// **'Traditional remedies (optional)'**
  String get matchAdviceRemedies;

  /// No description provided for @exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit the app?'**
  String get exitTitle;

  /// No description provided for @exitBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close the app?'**
  String get exitBody;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitConfirm;

  /// No description provided for @palmReviewFound.
  ///
  /// In en, this message translates to:
  /// **'Drishti found these lines in your photo, each in its own colour. Check that each one follows a crease on your palm. If one is wrong, tap Fix a line and draw it.'**
  String get palmReviewFound;

  /// No description provided for @palmReviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Not found: {lines}. You can draw them with Fix a line, or answer those questions yourself next.'**
  String palmReviewMissing(String lines);

  /// No description provided for @palmLooksRight.
  ///
  /// In en, this message translates to:
  /// **'Looks right'**
  String get palmLooksRight;

  /// No description provided for @palmFixLine.
  ///
  /// In en, this message translates to:
  /// **'Fix a line'**
  String get palmFixLine;

  /// No description provided for @palmDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get palmDone;

  /// No description provided for @palmFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'From your photo'**
  String get palmFromPhoto;

  /// No description provided for @palmChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get palmChange;

  /// No description provided for @palmEnhance.
  ///
  /// In en, this message translates to:
  /// **'Make lines clearer'**
  String get palmEnhance;

  /// No description provided for @palmZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch with two fingers to zoom. Tap the contrast button at the top to make fine lines easier to see.'**
  String get palmZoomHint;

  /// No description provided for @palmResetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get palmResetZoom;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'kn',
    'ml',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

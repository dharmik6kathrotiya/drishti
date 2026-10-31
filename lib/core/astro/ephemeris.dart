import 'package:sweph/sweph.dart';

import 'constants.dart';
import 'settings.dart';

/// Thin wrapper around Swiss Ephemeris (AGPL-3.0, Astrodienst AG).
///
/// All times are UT Julian days. Swiss Ephemeris keeps the sidereal mode as
/// global state, so every call that depends on it sets it first.
class Ephemeris {
  Ephemeris._();

  static bool _ready = false;
  static bool get isReady => _ready;

  /// Ephemeris data files bundled by the sweph package (years 1800-2400).
  static const bundledFiles = [
    'packages/sweph/assets/ephe/sepl_18.se1',
    'packages/sweph/assets/ephe/semo_18.se1',
    'packages/sweph/assets/ephe/seas_18.se1',
  ];

  static Future<void> init({
    AssetLoader? assetLoader,
    String? epheFilesPath,
    String? modulePath,
    List<String> epheAssets = bundledFiles,
  }) async {
    if (_ready) return;
    await Sweph.init(
      modulePath: modulePath,
      epheAssets: assetLoader == null ? const [] : epheAssets,
      assetLoader: assetLoader,
      epheFilesPath: epheFilesPath,
    );
    _ready = true;
  }

  static const _baseFlags = SwephFlag.SEFLG_SWIEPH;

  static double julianDay(DateTime utc) {
    final u = utc.toUtc();
    final hours = u.hour + u.minute / 60 + (u.second + u.millisecond / 1000) / 3600;
    return Sweph.swe_julday(u.year, u.month, u.day, hours, CalendarType.SE_GREG_CAL);
  }

  static DateTime dateTimeFromJd(double jd) => Sweph.swe_revjul(jd, CalendarType.SE_GREG_CAL).toUtc();

  static SiderealMode _mode(Ayanamsa a) => switch (a) {
    Ayanamsa.lahiri => SiderealMode.SE_SIDM_LAHIRI,
    Ayanamsa.kp => SiderealMode.SE_SIDM_KRISHNAMURTI,
    Ayanamsa.raman => SiderealMode.SE_SIDM_RAMAN,
    Ayanamsa.trueChitra => SiderealMode.SE_SIDM_TRUE_CITRA,
    Ayanamsa.yukteshwar => SiderealMode.SE_SIDM_YUKTESHWAR,
    Ayanamsa.jnBhasin => SiderealMode.SE_SIDM_JN_BHASIN,
    Ayanamsa.trueRevati => SiderealMode.SE_SIDM_TRUE_REVATI,
    Ayanamsa.truePushya => SiderealMode.SE_SIDM_TRUE_PUSHYA,
    Ayanamsa.faganBradley => SiderealMode.SE_SIDM_FAGAN_BRADLEY,
  };

  static double ayanamsa(double jd, Ayanamsa a) {
    Sweph.swe_set_sid_mode(_mode(a));
    return Sweph.swe_get_ayanamsa_ex_ut(jd, _baseFlags);
  }

  static HeavenlyBody _body(Planet p, NodeType node) => switch (p) {
    Planet.sun => HeavenlyBody.SE_SUN,
    Planet.moon => HeavenlyBody.SE_MOON,
    Planet.mars => HeavenlyBody.SE_MARS,
    Planet.mercury => HeavenlyBody.SE_MERCURY,
    Planet.jupiter => HeavenlyBody.SE_JUPITER,
    Planet.venus => HeavenlyBody.SE_VENUS,
    Planet.saturn => HeavenlyBody.SE_SATURN,
    Planet.uranus => HeavenlyBody.SE_URANUS,
    Planet.neptune => HeavenlyBody.SE_NEPTUNE,
    Planet.pluto => HeavenlyBody.SE_PLUTO,
    Planet.rahu || Planet.ketu => node == NodeType.trueNode ? HeavenlyBody.SE_TRUE_NODE : HeavenlyBody.SE_MEAN_NODE,
  };

  /// Geocentric ecliptic position. Sidereal when [ayanamsa] is given.
  static BodyPosition position(double jd, Planet planet, {Ayanamsa? ayanamsa, NodeType node = NodeType.mean}) {
    var flags = _baseFlags | SwephFlag.SEFLG_SPEED;
    if (ayanamsa != null) {
      Sweph.swe_set_sid_mode(_mode(ayanamsa));
      flags = flags | SwephFlag.SEFLG_SIDEREAL;
    }
    final r = Sweph.swe_calc_ut(jd, _body(planet, node), flags);
    var lon = r.longitude;
    var lat = r.latitude;
    if (planet == Planet.ketu) {
      lon = norm360(lon + 180);
      lat = -lat;
    }
    return BodyPosition(longitude: lon, latitude: lat, distance: r.distance, speed: r.speedInLongitude);
  }

  static Hsys _hsys(HouseSystem h) => switch (h) {
    HouseSystem.wholeSign => Hsys.W,
    HouseSystem.placidus || HouseSystem.placidusKp => Hsys.P,
    HouseSystem.koch => Hsys.K,
    HouseSystem.equal => Hsys.E,
    HouseSystem.porphyry => Hsys.O,
    HouseSystem.regiomontanus => Hsys.R,
    HouseSystem.campanus => Hsys.C,
    HouseSystem.sripati => Hsys.S,
  };

  /// House cusps (index 0 = 1st house) plus angles.
  static HouseData houses(double jd, double latitude, double longitude, HouseSystem system, {Ayanamsa? ayanamsa}) {
    var flags = _baseFlags;
    if (ayanamsa != null) {
      Sweph.swe_set_sid_mode(_mode(ayanamsa));
      flags = flags | SwephFlag.SEFLG_SIDEREAL;
    }
    final r = Sweph.swe_houses_ex(jd, flags, latitude, longitude, _hsys(system));
    // Sweph returns cusps with a dummy element at index 0.
    final cusps = List<double>.generate(12, (i) => r.cusps[i + 1]);
    return HouseData(cusps: cusps, ascendant: r.ascmc[0], midheaven: r.ascmc[1], armc: r.ascmc[2], vertex: r.ascmc[3]);
  }

  /// Next rise or set of [planet] after [jdStart] (UT). Null if circumpolar.
  static double? riseSet(
    double jdStart,
    Planet planet,
    double latitude,
    double longitude, {
    required bool rise,
    double altitude = 0,
  }) {
    final flag = rise ? RiseSetTransitFlag.SE_CALC_RISE : RiseSetTransitFlag.SE_CALC_SET;
    return Sweph.swe_rise_trans(
      jdStart,
      _body(planet, NodeType.mean),
      _baseFlags,
      flag,
      GeoPosition(longitude, latitude, altitude),
      1013.25,
      15,
    );
  }

  /// Next time (UT) the Sun reaches tropical/sidereal longitude [target].
  static double sunCrossing(double target, double jdStart, {Ayanamsa? ayanamsa}) {
    var flags = _baseFlags;
    if (ayanamsa != null) {
      Sweph.swe_set_sid_mode(_mode(ayanamsa));
      flags = flags | SwephFlag.SEFLG_SIDEREAL;
    }
    return Sweph.swe_solcross_ut(target, jdStart, flags);
  }

  /// Next time (UT) the Moon reaches longitude [target].
  static double moonCrossing(double target, double jdStart, {Ayanamsa? ayanamsa}) {
    var flags = _baseFlags;
    if (ayanamsa != null) {
      Sweph.swe_set_sid_mode(_mode(ayanamsa));
      flags = flags | SwephFlag.SEFLG_SIDEREAL;
    }
    return Sweph.swe_mooncross_ut(target, jdStart, flags);
  }

  static String get version => Sweph.swe_version();
}

class BodyPosition {
  const BodyPosition({required this.longitude, required this.latitude, required this.distance, required this.speed});

  final double longitude;
  final double latitude;
  final double distance;

  /// Degrees per day; negative = retrograde.
  final double speed;

  bool get isRetrograde => speed < 0;
}

class HouseData {
  const HouseData({
    required this.cusps,
    required this.ascendant,
    required this.midheaven,
    required this.armc,
    required this.vertex,
  });

  final List<double> cusps;
  final double ascendant;
  final double midheaven;
  final double armc;
  final double vertex;
}

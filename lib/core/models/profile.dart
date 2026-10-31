import 'package:timezone/timezone.dart' as tz;

/// How sure the user is about the birth time.
enum TimeAccuracy { exact, approximate, unknown }

enum Gender { male, female, other }

class Place {
  const Place({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    this.region = '',
    this.countryCode = '',
  });

  final String name;
  final String region;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezoneId;

  String get displayName => [name, region, countryCode].where((s) => s.isNotEmpty).join(', ');

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'cc': countryCode,
    'lat': latitude,
    'lon': longitude,
    'tz': timezoneId,
  };

  factory Place.fromJson(Map json) => Place(
    name: json['name'] as String,
    region: (json['region'] as String?) ?? '',
    countryCode: (json['cc'] as String?) ?? '',
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lon'] as num).toDouble(),
    timezoneId: json['tz'] as String,
  );
}

/// A person's profile ("ID"). Every field except [name] is optional: the app
/// shows whatever results the available data allows.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.gender,
    this.birthDate,
    this.birthHour,
    this.birthMinute,
    this.birthSecond = 0,
    this.timeAccuracy = TimeAccuracy.unknown,
    this.place,
    this.utcOffsetOverrideMinutes,
    this.relation = '',
    this.isSelf = false,
    this.notes = '',
    this.lifeEvents = const [],
  });

  final String id;
  final String name;
  final Gender? gender;

  /// Local calendar date of birth (time part ignored).
  final DateTime? birthDate;
  final int? birthHour;
  final int? birthMinute;
  final int birthSecond;
  final TimeAccuracy timeAccuracy;
  final Place? place;

  /// Manual UTC offset (e.g. for old Indian births recorded in a local mean
  /// time); overrides the timezone database when set.
  final int? utcOffsetOverrideMinutes;
  final String relation;
  final bool isSelf;
  final String notes;

  /// Life events used for birth-time rectification.
  final List<LifeEvent> lifeEvents;

  bool get hasDate => birthDate != null;
  bool get hasTime => birthHour != null && birthMinute != null && timeAccuracy != TimeAccuracy.unknown;
  bool get hasPlace => place != null;

  /// Full natal chart (ascendant, houses) needs date, time and place.
  bool get canCastFullChart => hasDate && hasTime && hasPlace;

  /// Moon-based chart without houses needs only the date (noon is assumed).
  bool get canCastMoonChart => hasDate;

  /// Birth moment in UTC. Without a time, local noon is used (standard
  /// practice for unknown-time charts; Moon may be off by up to ~6.5°).
  DateTime? birthUtc() {
    final d = birthDate;
    if (d == null) return null;
    final h = hasTime ? birthHour! : 12;
    final m = hasTime ? birthMinute! : 0;
    final s = hasTime ? birthSecond : 0;
    final override = utcOffsetOverrideMinutes;
    if (override != null) {
      return DateTime.utc(d.year, d.month, d.day, h, m, s).subtract(Duration(minutes: override));
    }
    final p = place;
    if (p == null) {
      // No place: assume UTC so at least sign positions are meaningful.
      return DateTime.utc(d.year, d.month, d.day, h, m, s);
    }
    final loc = tz.getLocation(p.timezoneId);
    final local = tz.TZDateTime(loc, d.year, d.month, d.day, h, m, s);
    return local.toUtc();
  }

  /// UTC offset (minutes) in effect at birth.
  int? birthUtcOffsetMinutes() {
    final d = birthDate;
    if (d == null) return null;
    if (utcOffsetOverrideMinutes != null) return utcOffsetOverrideMinutes;
    final p = place;
    if (p == null) return 0;
    final loc = tz.getLocation(p.timezoneId);
    final local = tz.TZDateTime(loc, d.year, d.month, d.day, hasTime ? birthHour! : 12, hasTime ? birthMinute! : 0);
    return local.timeZoneOffset.inMinutes;
  }

  Profile copyWith({
    String? name,
    Gender? Function()? gender,
    DateTime? Function()? birthDate,
    int? Function()? birthHour,
    int? Function()? birthMinute,
    int? birthSecond,
    TimeAccuracy? timeAccuracy,
    Place? Function()? place,
    int? Function()? utcOffsetOverrideMinutes,
    String? relation,
    bool? isSelf,
    String? notes,
    List<LifeEvent>? lifeEvents,
  }) => Profile(
    id: id,
    name: name ?? this.name,
    gender: gender != null ? gender() : this.gender,
    birthDate: birthDate != null ? birthDate() : this.birthDate,
    birthHour: birthHour != null ? birthHour() : this.birthHour,
    birthMinute: birthMinute != null ? birthMinute() : this.birthMinute,
    birthSecond: birthSecond ?? this.birthSecond,
    timeAccuracy: timeAccuracy ?? this.timeAccuracy,
    place: place != null ? place() : this.place,
    utcOffsetOverrideMinutes: utcOffsetOverrideMinutes != null
        ? utcOffsetOverrideMinutes()
        : this.utcOffsetOverrideMinutes,
    relation: relation ?? this.relation,
    isSelf: isSelf ?? this.isSelf,
    notes: notes ?? this.notes,
    lifeEvents: lifeEvents ?? this.lifeEvents,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (gender != null) 'gender': gender!.name,
    if (birthDate != null)
      'date':
          '${birthDate!.year.toString().padLeft(4, '0')}-'
          '${birthDate!.month.toString().padLeft(2, '0')}-'
          '${birthDate!.day.toString().padLeft(2, '0')}',
    if (birthHour != null) 'h': birthHour,
    if (birthMinute != null) 'm': birthMinute,
    if (birthSecond != 0) 's': birthSecond,
    'acc': timeAccuracy.name,
    if (place != null) 'place': place!.toJson(),
    if (utcOffsetOverrideMinutes != null) 'off': utcOffsetOverrideMinutes,
    if (relation.isNotEmpty) 'rel': relation,
    if (isSelf) 'self': true,
    if (notes.isNotEmpty) 'notes': notes,
    if (lifeEvents.isNotEmpty) 'events': lifeEvents.map((e) => e.toJson()).toList(),
  };

  factory Profile.fromJson(Map json) {
    final date = json['date'] as String?;
    DateTime? birthDate;
    if (date != null) {
      final p = date.split('-').map(int.parse).toList();
      birthDate = DateTime(p[0], p[1], p[2]);
    }
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: Gender.values.where((g) => g.name == json['gender']).firstOrNull,
      birthDate: birthDate,
      birthHour: json['h'] as int?,
      birthMinute: json['m'] as int?,
      birthSecond: (json['s'] as int?) ?? 0,
      timeAccuracy: TimeAccuracy.values.where((t) => t.name == json['acc']).firstOrNull ?? TimeAccuracy.unknown,
      place: json['place'] == null ? null : Place.fromJson(json['place'] as Map),
      utcOffsetOverrideMinutes: json['off'] as int?,
      relation: (json['rel'] as String?) ?? '',
      isSelf: (json['self'] as bool?) ?? false,
      notes: (json['notes'] as String?) ?? '',
      lifeEvents: ((json['events'] as List?) ?? const []).map((e) => LifeEvent.fromJson(e as Map)).toList(),
    );
  }
}

enum LifeEventType {
  marriage,
  childBirth,
  jobStart,
  jobLoss,
  relocation,
  accident,
  illness,
  parentDeath,
  education,
  other,
}

class LifeEvent {
  const LifeEvent({required this.type, required this.date, this.note = ''});

  final LifeEventType type;
  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'date': date.toIso8601String().substring(0, 10),
    if (note.isNotEmpty) 'note': note,
  };

  factory LifeEvent.fromJson(Map json) => LifeEvent(
    type: LifeEventType.values.where((t) => t.name == json['type']).firstOrNull ?? LifeEventType.other,
    date: DateTime.parse(json['date'] as String),
    note: (json['note'] as String?) ?? '',
  );
}

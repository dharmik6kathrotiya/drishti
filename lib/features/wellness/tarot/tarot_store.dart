import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/content/tarot/tarot_deck.dart';

enum TarotSpread {
  three(3),
  celtic(10),
  relationship(5, adultOnly: true);

  const TarotSpread(this.size, {this.adultOnly = false});
  final int size;
  final bool adultOnly;
}

class DrawnCard {
  const DrawnCard(this.card, this.reversed);
  final TarotCard card;
  final bool reversed;

  Map<String, dynamic> toJson() => {'id': card.id, 'r': reversed};
  factory DrawnCard.fromJson(Map json) => DrawnCard(TarotCard.deck[json['id'] as int], json['r'] as bool);
}

class TarotReading {
  const TarotReading({
    required this.id,
    required this.spread,
    required this.date,
    required this.cards,
    this.question = '',
  });

  final String id;
  final TarotSpread spread;
  final DateTime date;
  final List<DrawnCard> cards;
  final String question;

  Map<String, dynamic> toJson() => {
    'id': id,
    'spread': spread.name,
    'date': date.toIso8601String(),
    'question': question,
    'cards': cards.map((c) => c.toJson()).toList(),
  };

  factory TarotReading.fromJson(Map json) => TarotReading(
    id: json['id'] as String,
    spread: TarotSpread.values.firstWhere((s) => s.name == json['spread'], orElse: () => TarotSpread.three),
    date: DateTime.parse(json['date'] as String),
    question: (json['question'] as String?) ?? '',
    cards: (json['cards'] as List).map((c) => DrawnCard.fromJson(c as Map)).toList(),
  );

  /// Shuffles the full deck and draws [spread.size] cards. Roughly one card
  /// in four is reversed.
  static TarotReading draw(TarotSpread spread, {String question = '', Random? random}) {
    final rnd = random ?? Random.secure();
    final deck = [...TarotCard.deck]..shuffle(rnd);
    final now = DateTime.now();
    return TarotReading(
      id: now.microsecondsSinceEpoch.toString(),
      spread: spread,
      date: now,
      question: question,
      cards: [for (var i = 0; i < spread.size; i++) DrawnCard(deck[i], rnd.nextInt(4) == 0)],
    );
  }
}

/// Readings are kept only on this device, in their own Hive box.
class TarotStore {
  TarotStore(this._box);
  final Box<String> _box;

  static Future<TarotStore> open() async => TarotStore(await Hive.openBox<String>('tarot'));

  List<TarotReading> all() {
    final list = _box.values.map((s) => TarotReading.fromJson(jsonDecode(s) as Map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> save(TarotReading r) => _box.put(r.id, jsonEncode(r.toJson()));
  Future<void> delete(String id) => _box.delete(id);
  Future<void> clear() => _box.clear();
}

class TarotHistoryNotifier extends AsyncNotifier<List<TarotReading>> {
  TarotStore? _store;

  @override
  Future<List<TarotReading>> build() async {
    _store ??= await TarotStore.open();
    return _store!.all();
  }

  Future<void> save(TarotReading r) async {
    _store ??= await TarotStore.open();
    await _store!.save(r);
    state = AsyncData(_store!.all());
  }

  Future<void> delete(String id) async {
    await _store?.delete(id);
    state = AsyncData(_store?.all() ?? const []);
  }

  Future<void> clear() async {
    await _store?.clear();
    state = const AsyncData([]);
  }
}

final tarotHistoryProvider = AsyncNotifierProvider<TarotHistoryNotifier, List<TarotReading>>(TarotHistoryNotifier.new);

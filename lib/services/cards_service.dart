import 'package:card_generator/models/card.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/utils.dart';
import 'package:isar/isar.dart';

abstract class CardsService {
  static Future<Card?> getCard(Id id) async {
    return await db.writeTxn(() => db.Cards.get(id));
  }

  static Future<List<Card?>> getCards({List<Id>? ids}) async {
    if (ids != null) {
      return db.writeTxn(() => db.Cards.getAll(ids));
    }
    return db.writeTxn(() => db.Cards.where().findAll());
  }

  static Future<List<Card?>> getUnusedCards({
    double? value,
    int? limit,
  }) async {
    var queryBuilder = db.Cards.filter().usedAtIsNull();
    if (value != null) queryBuilder = queryBuilder.valueEqualTo(value);

    if (limit != null) return queryBuilder.limit(limit).findAll();
    return db.writeTxn(() => queryBuilder.findAll());
  }

  static Future<List<Card?>> getUsedCards({
    double? value,
    int? limit,
  }) async {
    var queryBuilder = db.Cards.filter().usedAtIsNotNull();
    if (value != null) queryBuilder = queryBuilder.valueEqualTo(value);

    if (limit != null) return queryBuilder.limit(limit).findAll();
    return db.writeTxn(() => queryBuilder.findAll());
  }

  static Stream<List<Card?>> cards({List<Id>? ids}) async* {
    if (ids != null) {
      yield await db.writeTxn(() => db.Cards.getAll(ids));
    }
    yield await db.writeTxn(() => db.Cards.where().findAll());
    yield* db.Cards.where().build().watch();
  }

  static Stream<List<Card?>> unusedCards({
    double? value,
    int? limit,
  }) async* {
    var queryBuilder = db.Cards.filter().usedAtIsNull();
    if (value != null) queryBuilder = queryBuilder.valueEqualTo(value);
    if (limit != null) {
      final queryBuilder2 = queryBuilder.limit(limit);

      yield await db.writeTxn(() => queryBuilder2.findAll());
      yield* queryBuilder2.build().watch();
    } else {
      yield await db.writeTxn(() => queryBuilder.findAll());
      yield* queryBuilder.build().watch();
    }
  }

  static Stream<List<Card?>> usedCards({
    double? value,
    int? limit,
  }) async* {
    var queryBuilder = db.Cards.filter().usedAtIsNotNull();
    if (value != null) queryBuilder = queryBuilder.valueEqualTo(value);
    if (limit != null) {
      final queryBuilder2 = queryBuilder.limit(limit);

      yield await db.writeTxn(() => queryBuilder2.findAll());
      yield* queryBuilder2.build().watch();
    } else {
      yield await db.writeTxn(() => queryBuilder.findAll());
      yield* queryBuilder.build().watch();
    }
  }

  static Future<Card> saveCard(Card card) async {
    checkLimits();

    card = card.copyWith(createdAt: DateTime.now());
    return db.writeTxn(() async => card.copyWith(id: await db.Cards.put(card)));
  }

  static void checkLimits() async {
    final license = await getLicence();
    if (license == null) throw Exception('No license found!!!');

    if (license.validUntil != null) {
      if (license.validUntil!.isBefore(DateTime.now())) {
        throw Exception(
          'License expired on (${license.validUntil!.toIso8601String()})',
        );
      }
    }
    if (license.maxCardNumber != null) {
      final maxCardNumber = license.maxCardNumber!;
      if (maxCardNumber <= await countCards()) {
        throw Exception(
          'License expired. reach max cards number ($maxCardNumber)',
        );
      }
    }

    // final x =
    //     await db.Cards.filter().idGreaterThan(100000).limit(1).findFirst();
    // if (x != null) throw Exception('Limits Exceeded');
  }

  static Future<List<Card>> saveCards(List<Card> cards) async {
    checkLimits();

    final now = DateTime.now();
    return db.writeTxn(
      () async => [
        for (var card in cards)
          card.copyWith(id: await db.Cards.put(card.copyWith(createdAt: now))),
      ],
    );
  }

  // static Future<Card> editCard(Card card) async {
  //   card = card.copyWith(createdAt: DateTime.now());
  //   return db.writeTxn(() async {
  //     db.Cards.put(card);
  //     return card;
  //   });
  // }

  static Future<Card?> useCard(Card card) async {
    card = card.copyWith(usedAt: DateTime.now());
    return db.writeTxn(() async {
      db.Cards.put(card);
      return card;
    });
  }

  static Future<int> countCards() async => db.Cards.count();

  static Future<int> maxId() async {
    return await db.Cards.where().idProperty().max() ?? 0;
  }

  static Future<bool> deleteCard(Id id) async {
    return db.writeTxn(() async => db.Cards.delete(id));
  }

  static Future<int> deleteCards(Iterable<Id> ids) async {
    return db.writeTxn(() async => db.Cards.deleteAll(ids.toList()));
  }
}

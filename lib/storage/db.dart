import 'package:card_generator/models/user.dart';
import 'package:card_generator/models/card.dart';
import 'package:isar/isar.dart';

final db = Isar.openSync([
  UserSchema,
  CardSchema,
]);

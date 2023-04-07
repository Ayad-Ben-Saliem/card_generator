import 'dart:async';
import 'dart:convert';

import 'package:card_generator/models/user.dart';
import 'package:card_generator/models/card.dart';
import 'package:card_generator/models/license.dart';
import 'package:isar/isar.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

final db = Isar.openSync([
  UserSchema,
  CardSchema,
]);

Future<License?> getLicence() async {
  final license = await storage.read(key: 'license');
  return (license != null) ? License.fromJson(json.decode(license)) : null;
}

Future<void> setLicence(License license) async {
  return storage.write(key: 'license', value: '${license.toJson}');
}

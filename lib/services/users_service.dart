import 'package:card_generator/models/user.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/utils.dart';
import 'package:isar/isar.dart';

abstract class UsersService {
  static Future<User?> getUser(Id id) async {
    return await db.writeTxn(() => db.Users.get(id));
  }

  static Future<User?> authenticate(String email, String password) async {
    return db.Users.filter()
        .emailEqualTo(email, caseSensitive: false)
        .and()
        .passwordEqualTo(await Utils.hashPassword(password))
        .findFirst();
  }

  static Future<List<User?>> getUsers({List<Id>? ids}) async {
    if (ids != null) {
      return await db.writeTxn(() => db.Users.getAll(ids));
    }
    return await db.writeTxn(() => db.Users.where().findAll());
  }

  static Stream<List<User?>> users({List<Id>? ids}) async* {
    if (ids != null) {
      yield await db.writeTxn(() => db.Users.getAll(ids));
    }
    yield await db.writeTxn(() => db.Users.where().findAll());
    yield* db.Users.where().build().watch();
  }

  static Future<User> saveUser(User user) async {
    if (await countUsers() == 0) user = user.copyWith(superUser: true);

    user = user.copyWith(
      password: await Utils.hashPassword(user.password),
      at: DateTime.now(),
    );
    return db.writeTxn(() async => user.copyWith(id: await db.Users.put(user)));
  }

  static Future<User> editUser(User user) async {
    var password = (await getUser(user.id!))?.password;
    user = user.copyWith(
      password: password,
      at: DateTime.now(),
    );
    return db.writeTxn(() async {
      db.Users.put(user);
      return user;
    });
  }

  static Future<User?> changePassword(Id id, String password) async {
    var user = await getUser(id);
    user = user?.copyWith(
      password: await Utils.hashPassword(user.password),
      at: DateTime.now(),
    );
    return db.writeTxn(() async {
      if (user != null) db.Users.put(user);
      return user;
    });
  }

  static Future<int> countUsers() async => db.Users.count();
}

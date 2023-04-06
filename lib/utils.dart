import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:card_generator/equatable_list.dart';
import 'package:card_generator/static.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

typedef JsonMap = Map<String, dynamic>;

class Utils {
  static String hash(String value) {
    // var salt = 'UVocjgjgXg8P7zIsC93kKlRU8sPbTBhsAMFLnLUPDRYFIWAk';
    // var salted = salt + value;
    return '${sha256.convert(utf8.encode(value))}';
  }

  static Future<String> hashPassword(String password) async {
    // var salt = 'UVocjgjgXg8P7zIsC93kKlRU8sPbTBhsAMFLnLUPDRYFIWAk';
    final salt = await getDeviceUID();
    return hash('$password$salt');
  }



  static Future<BaseDeviceInfo> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      return deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      return deviceInfo.iosInfo;
    } else if (Platform.isLinux) {
      return deviceInfo.linuxInfo;
    } else if (Platform.isWindows) {
      return deviceInfo.windowsInfo;
    } else if (Platform.isMacOS) {
      return deviceInfo.macOsInfo;
    } else if (kIsWeb) {
      return deviceInfo.webBrowserInfo;
    }
    throw Exception('Unsupported platform');
  }

  static Future<JsonMap> getDeviceData() async {
    return (await getDeviceInfo()).data;
  }

  static Future<String?> getDeviceUID() async {
    final deviceInfo = await getDeviceInfo();

    if (deviceInfo is AndroidDeviceInfo) {
      return deviceInfo.id;
    } else if(deviceInfo is IosDeviceInfo) {
      return deviceInfo.identifierForVendor;
    } else if (deviceInfo is LinuxDeviceInfo) {
      return deviceInfo.machineId;
    } else if (deviceInfo is WindowsDeviceInfo) {
      return deviceInfo.deviceId;
    } else if (deviceInfo is MacOsDeviceInfo) {
      return deviceInfo.systemGUID;
    } else if (deviceInfo is WebBrowserInfo) {
      // The web doesnt have a device UID, so use a combination fingerprint as an example
      return '${deviceInfo.vendor}${deviceInfo.userAgent}${deviceInfo.hardwareConcurrency}';
    }
    throw Exception('Unsupported platform');
  }

  Utils.pushPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Set<int> uniqueSet = {};

  static int getUniqueTag() {
    int randomNumber;
    do {
      randomNumber = Random().nextInt(0x7FFFFFFF);
    } while (uniqueSet.contains(randomNumber));
    uniqueSet.add(randomNumber);
    return randomNumber;
  }

  static bool removeTag(Object object) {
    return uniqueSet.remove(object);
  }

  static bool isStartWithArabicChar(String text) {
    for (var char in text.characters) {
      if (RegExp('^[\u0621-\u064A]').hasMatch(char)) return true;
      if (RegExp('^[a-zA-Z]').hasMatch(char)) return false;
    }
    return false;
  }

  static E getEnumByString<E>(String value, List<E> values) {
    for (var val in values) {
      if (value == val.toString()) {
        return val;
      }
    }
    throw 'Enum $value not found in $values';
  }

  static void prettyPrint(JsonMap json) {
    print(const JsonEncoder.withIndent('  ').convert(json));
  }

  static String getPrettyString(JsonMap json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  static String getReadableDate(DateTime dateTime) {
    var y = _fourDigits(dateTime.year);
    var m = _twoDigits(dateTime.month);
    var d = _twoDigits(dateTime.day);
    var h = _twoDigits(dateTime.hour);
    var min = _twoDigits(dateTime.minute);

    return '$y-$m-$d  $h:$min';
  }

  static String _fourDigits(int n) {
    var absN = n.abs();
    var sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  static bool boolean(Object? obj) {
    if (obj is bool) return obj;
    if (obj == null) return false;
    if (obj is num) return obj != 0;
    if (obj is Iterable) return obj.isNotEmpty;
    if (obj is String) return obj.isNotEmpty;

    return true;
  }

  static bool equalsNotNull(dynamic obj1, dynamic obj2) {
    return obj1 == null || obj2 == null || obj1 == obj2;
  }

  static void removeRepeatedObjects<T>(
    List<T> list1,
    List<T> list2,
  ) {
    for (var element in list1) {
      if (list2.remove(element)) list1.remove(element);
    }
  }

  static Iterable<T> replace<T>(
    Iterable<T> iterable,
    T object,
    bool Function(T object) replaceCallback,
  ) {
    final list = iterable.toList();
    for (int i = 0; i < list.length; i++) {
      if (replaceCallback(list.elementAt(i))) {
        list.removeAt(i);
        list.insert(i, object);
      }
    }
    return list;
  }

  static String readableMoney(double money, {int fractionDigits = 3}) {
    return double2String(money, fractionDigits: fractionDigits);
  }

  static String readableDouble(double number, {int fractionDigits = 3}) {
    return double2String(number, fractionDigits: fractionDigits);
  }

  static String double2String(double number, {int fractionDigits = 20}) {
    var result = number.toStringAsFixed(fractionDigits);
    var lastIndex = result.length - 1;
    while (result.contains('.')) {
      if (result[lastIndex] == '0' || result[lastIndex] == '.') {
        result = result.substring(0, lastIndex);
        lastIndex--;
      } else {
        break;
      }
    }
    return result;
  }

  static void showErrorMessage(
    BuildContext context,
    error, {
    StackTrace? stackTrace,
  }) {
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
            style: errorTextStyle(context),
          ),
        ),
      ),
    );
  }
}

abstract class Enum {
  final String str;

  const Enum(this.str);

  @override
  bool operator ==(Object other) {
    if (other is String && other == str) return true;
    return super == other;
  }

  // List<T> get values<T extends Enum>;

  @override
  String toString() => str;
}

// typedef VarArgsCallback = dynamic Function(
//   List args,
//   JsonMap kwargs,
// );
//
// JsonMap map(Map<Symbol, dynamic> namedArguments) {
//   final _offset = 'Symbol("'.length;
//   return namedArguments.map(
//     (key, value) {
//       var _key = '$key';
//       _key = _key.substring(_offset, _key.length - 2);
//       return MapEntry(_key, value);
//     },
//   );
// }
//
// class VarargsFunction {
//   final VarArgsCallback callback;
//
//   VarargsFunction(this.callback);
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) {
//     if (!invocation.isMethod || invocation.namedArguments.isNotEmpty)
//       super.noSuchMethod(invocation);
//     return callback(
//       invocation.positionalArguments,
//       map(invocation.namedArguments),
//     );
//   }
// }
//
// class ListenableFunction {
//   final callbacks = <VarArgsCallback>[];
//
//   final VarArgsCallback callback;
//
//   ListenableFunction(this.callback);
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) {
//     if (invocation.isMethod) {
//       callbacks.forEach(
//         (callback) => callback(
//           invocation.positionalArguments,
//           map(invocation.namedArguments),
//         ),
//       );
//       return callback(
//         invocation.positionalArguments,
//         map(invocation.namedArguments),
//       );
//       ;
//     }
//     super.noSuchMethod(invocation);
//   }
//
//   void listen(VarArgsCallback callback) => callbacks.add(callback);
// }
//
// class Validation {
//   final bool valid;
//   final List<String>? errors;
//
//   Validation.valid()
//       : valid = true,
//         errors = null;
//
//   Validation.invalid([this.errors]) : valid = false;
//
//   @override
//   String toString() {
//     return valid ? 'valid' : 'invalid ${errors ?? ''}';
//   }
// }
//
// typedef ListenCallback<R, T> = R Function(T);
//
// class ValueListener<R, T> {
//   ListenCallback<R, T>? _callback;
//
//   ListenCallback<R, T>? get callback => _callback;
//
//   void listen(ListenCallback<R, T> callback) => _callback = callback;
// }

extension ListExtension<E> on List<E> {
  void reset(Iterable<E> iterable) {
    clear();
    addAll(iterable);
  }

  void replace(E element1, E element2) {
    final index = indexWhere((element) => element == element1);
    if (index != -1) throw StateError('Element ($element1) not found');
    this[index] = element2;
  }

  void replaceWhere(E Function(E element) test) {
    for (int index = 0; index < length; index++) {
      this[index] = test(this[index]);
    }
  }

  bool equals<T>(Iterable<T> iterable) {
    return EquatableList(this) == EquatableList(iterable);
  }
}

extension SetReplaceExtension<E> on Set<E> {
  void replace(E element1, E element2) {
    final list = <E>[
      for (final element in this) element == element1 ? element2 : element,
    ];
    removeAll(this);
    addAll(list);
  }

  void replaceWhere(E Function(E element) test) {
    final list = <E>[for (final element in this) test(element)];
    removeAll(toList());
    addAll(list);
  }
}

// extension EquatableExtension<E> on Iterable<E> {
//   EquatableList<E> toEquatableList() => EquatableList<E>(this);
// }

bool isSubtype<S, T>() => <S>[] is List<T>;

extension StringExtension on String {
  bool containEachOther(String str) {
    return contains(str) || str.contains(this);
  }

  bool containEachOtherIgnoreCase(String str) {
    return toLowerCase().contains(str.toLowerCase()) ||
        str.toLowerCase().contains(toLowerCase());
  }

  bool equalsIgnoreCase(String str) => toLowerCase() == str.toLowerCase();
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))'
      r'@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }
}

extension NumExtension on num {
  bool isGreaterThan(num other) => this > other;

  bool isGreaterThanOrEqual(num other) => this >= other;

  bool isLessThan(num other) => this < other;

  bool isLessThanOrEqual(num other) => this <= other;
}

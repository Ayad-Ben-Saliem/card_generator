import 'package:card_generator/utils.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('Test', () async {
    print(await Utils.hash('Test'));
  });
}
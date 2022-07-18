// ignore_for_file: prefer_const_declarations

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

import '_test_data.dart';

void main() {
  for (final uuid in testData) {
    test('should decode/encode "$uuid"', () {
      expect(Uuid.parse(uuid).toString(), uuid);
    });
  }
}

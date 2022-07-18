import 'dart:math';

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

void main() {
  final generator = UuidV4Generator(Random(1234));

  test('should generate a random UUID', () {
    final uuid = generator.generate();
    expect(uuid, Uuid(0x53b59845, 0x2b4a, 0x31a6, 0x6423, 0xabb6a282c8b5));
  });
}

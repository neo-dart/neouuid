import 'dart:math';

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

void main() {
  test('should generate a random UUID (v4)', () {
    final generator = UuidV4Generator(Random(1234));
    final uuid = generator.generate();
    expect(uuid, Uuid(0x53b59845, 0x2b4a, 0x31a6, 0x6423, 0xabb6a282c8b5));
    expect(uuid.version, UuidVersion.v4);
    expect(uuid.variant, UuidVariant.isoRfc4122Standard);
    expect(uuid.time, isNull);
  });

  group('should generate a time-based UUID (v1)', () {
    const nodeId = 12345;

    late UuidGenerator generator;
    late DateTime now;

    setUp(() {
      generator = UuidV1Generator(
        clockSequence: 0,
        uniqueness: nodeId,
        now: () => now,
      );
    });

    test('', () {
      // 2022-07-23 17:32:50.363Z
      now = DateTime.fromMillisecondsSinceEpoch(1658597570363, isUtc: true);
      final uuid = generator.generate();
      expect(uuid, Uuid(0x7992b0b0, 0x0aad, 0x11ed, 0x8000, 0x000000003039));
      expect(uuid.version, UuidVersion.v1);
      expect(uuid.variant, UuidVariant.isoRfc4122Standard);
      expect(uuid.time, now);
    });
  });
}

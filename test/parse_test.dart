// ignore_for_file: prefer_const_declarations

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

void main() {
  group('Uuid', () {
    test('should create a minimum UUID', () {
      final text = '00000000-0000-0000-0000-000000000000';
      final uuid = Uuid(0x00000000, 0x0000, 0x0000, 0x0000, 0x000000000000);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });

    test('should create an example UUID', () {
      final text = '12345678-1234-5678-9abc-123456789012';
      final uuid = Uuid(0x12345678, 0x1234, 0x5678, 0x9abc, 0x123456789012);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });

    test('should create a maximum UUID', () {
      final text = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
      final uuid = Uuid(0xffffffff, 0xffff, 0xffff, 0xffff, 0xffffffffffff);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });
  });

  group('Uuid.parse', () {
    test('should parse the minimum UUID', () {
      final text = '00000000-0000-0000-0000-000000000000';
      final uuid = Uuid.parse(text);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });

    test('should parse an example UUID', () {
      final text = '12345678-1234-5678-9abc-123456789012';
      final uuid = Uuid.parse(text);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });

    test('should parse the maximum UUID', () {
      final text = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
      final uuid = Uuid.parse(text);
      expect('$uuid', text);
      expect(uuid, uuid);
      expect(uuid.hashCode, uuid.hashCode);
    });
  });
}

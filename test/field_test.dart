// ignore_for_file: prefer_const_declarations

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

void main() {
  group('version', () {
    test('should be 1', () {
      final uuid = Uuid.parse('081f7e38-a5d2-1483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, UuidVersion.v1);
    });

    test('should be 2', () {
      final uuid = Uuid.parse('081f7e38-a5d2-2483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, UuidVersion.v2);
    });

    test('should be 3', () {
      final uuid = Uuid.parse('081f7e38-a5d2-3483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, UuidVersion.v3);
    });

    test('should be 4', () {
      final uuid = Uuid.parse('081f7e38-a5d2-4483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, UuidVersion.v4);
    });

    test('should be 5', () {
      final uuid = Uuid.parse('081f7e38-a5d2-5483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, UuidVersion.v5);
    });

    test('should be 0 (unknown)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-0483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, isNull);
    });

    test('should be f (unknown)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-f483-9629-98403bd695f7');
      //                                     ^
      expect(uuid.version, isNull);
    });
  });

  group('variant', () {
    group('should be NCS backwards compatible', () {
      for (var i = 0; i < 8; i++) {
        test('(0x$i)', () {
          final uuid = Uuid.parse('081f7e38-a5d2-1483-${i}629-98403bd695f7');
          //                                            ^
          expect(uuid.variant, UuidVariant.reservedNcsBackwardsCompatible);
        });
      }
    });

    group('should be ISO standard', () {
      for (var i = 8; i < 12; i++) {
        final c = i.toRadixString(16);

        test('(0x$c)', () {
          final uuid = Uuid.parse('081f7e38-a5d2-1483-${c}629-98403bd695f7');
          //                                            ^
          expect(uuid.variant, UuidVariant.isoRfc4122Standard);
        });
      }
    });

    test('should be Microsoft GUID (0xc)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-1483-c629-98403bd695f7');
      //                                          ^
      expect(uuid.variant, UuidVariant.reservedMicrosoft);
    });

    test('should be Microsoft GUID (0xd)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-1483-c629-98403bd695f7');
      //                                          ^
      expect(uuid.variant, UuidVariant.reservedMicrosoft);
    });

    test('should be reserved for future use (0xe)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-1483-e629-98403bd695f7');
      //                                          ^
      expect(uuid.variant, UuidVariant.reservedFuture);
    });

    test('should be unknown (0xf)', () {
      final uuid = Uuid.parse('081f7e38-a5d2-1483-f629-98403bd695f7');
      //                                          ^
      expect(uuid.variant, isNull);
    });
  });

  test('should decode a timestamp (for v1)', () {
    final uuid = Uuid.parse('59c18cc6-0610-11dd-bbd6-df3e60ed8154');
    //                       ^^^^^^^^ ^^^^ 0^^^
    //                       59c18cc6 0610  1dd
    //
    //                       reversed endianness:
    //                       dd101606 cc81  c95
    //
    // combined as a timestamp:
    // dd101606cc81c95
    //
    // reverse endianness:
    // 0xde1a060879d79b2
    // ... and then interpret as a DateTime/timestamp.
    expect(uuid.time, DateTime.utc(2008, 04, 09, 08, 38, 38));
  });

  test('should decode a clock sequence (for v1)', () {
    final uuid = Uuid.parse('31ae75f0-cbe0-11e8-b568-0800200c9a66');
    expect(uuid.clock, 13672);
  });

  test('should decode a node ID (for v1)', () {
    final uuid = Uuid.parse('31ae75f0-cbe0-11e8-b568-0800200c9a66');
    expect(uuid.node, 0x0800200c9a66);
  });
}

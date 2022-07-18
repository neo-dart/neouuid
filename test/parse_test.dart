// ignore_for_file: prefer_const_declarations

import 'package:neouuid/neouuid.dart';
import 'package:test/test.dart';

void main() {
  group('Uuid syntax', () {
    test('should allow a UUID with lower-case letters', () {
      expect(Uuid.isUuid('12345678-90ab-cdef-1234-567890abcdef'), isTrue);
      expect(
        () => Uuid.parse('12345678-90ab-cdef-1234-567890abcdef'),
        returnsNormally,
      );
    });

    test('should allow a UUID with upper-case letters', () {
      expect(Uuid.isUuid('12345678-90AB-CDEF-1234-567890ABCDEF'), isTrue);
      expect(
        () => Uuid.parse('12345678-90AB-CDEF-1234-567890ABCDEF'),
        returnsNormally,
      );
    });

    test('should disallow a UUID with missing hyphen(s)', () {
      expect(Uuid.isUuid('1234567890AB-CDEF-1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('1234567890AB-CDEF-1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90ABCDEF-1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('12345678-90ABCDEF-1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90AB-CDEF1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('12345678-90AB-CDEF1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90AB-CDEF-1234567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('12345678-90AB-CDEF-1234567890ABCDEF'),
        throwsFormatException,
      );
    });

    test('should disallow a UUID with extraneous hyphen(s)', () {
      expect(Uuid.isUuid('1234567890AB-CDEF-1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('1234567890AB-CDEF-1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90ABCDEF-1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('12345678-90ABCDEF-1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90AB-CDEF1234-567890ABCDEF'), isFalse);
      expect(
        () => Uuid.parse('12345678-90AB-CDEF1234-567890ABCDEF'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('-12345678-90AB-CDEF-1234-567890ABCDE'), isFalse);
      expect(
        () => Uuid.parse('-12345678-90AB-CDEF-1234-567890ABCDE'),
        throwsFormatException,
      );

      expect(Uuid.isUuid('12345678-90AB-CDEF-1234-567890ABCDE-'), isFalse);
      expect(
        () => Uuid.parse('12345678-90AB-CDEF-1234-567890ABCDE-'),
        throwsFormatException,
      );
    });
  });

  group('Uuid range', () {
    test('should disallow out-of-range "l" (too low)', () {
      expect(
        () => Uuid(-1, 0x0000, 0x0000, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "l" (too high)', () {
      expect(
        () => Uuid(0xffffffff + 1, 0x0000, 0x0000, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "m" (too low)', () {
      expect(
        () => Uuid(0x00000000, -1, 0x0000, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "m" (too high)', () {
      expect(
        () => Uuid(0x00000000, 0xffff + 1, 0x0000, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "h" (too low)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, -1, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "h" (too high)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, 0xffff + 1, 0x0000, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "s" (too low)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, 0x0000, -1, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "s" (too high)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, 0x0000, 0xffff + 1, 0x000000000000),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "n" (too low)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, 0x0000, 0x0000, -1),
        throwsRangeError,
      );
    });

    test('should disallow out-of-range "n" (too high)', () {
      expect(
        () => Uuid(0x00000000, 0x0000, 0x0000, 0x0000, 0xffffffffffff + 1),
        throwsRangeError,
      );
    });
  });

  test('should parse a minimim UUID', () {
    final a = Uuid.parse('00000000-0000-0000-0000-000000000000');
    final b = Uuid(0x00000000, 0x0000, 0x0000, 0x0000, 0x000000000000);
    expect(a, b);
  });

  test('should parse a maximum UUID', () {
    final a = Uuid.parse('ffffffff-ffff-ffff-ffff-ffffffffffff');
    final b = Uuid(0xffffffff, 0xffff, 0xffff, 0xffff, 0xffffffffffff);
    expect(a, b);
  });
}

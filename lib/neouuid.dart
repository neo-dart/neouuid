/// Fast and idiomatic UUIDs (Universally Unique Identifiers) in Dart.
library neouuid;

import 'package:meta/meta.dart';

/// A **u**niversally **u**nique **id**entifier, or UUID; a 128-bit laabel.
///
/// UUIds, are, for practical purposes, unique, without a central registration
/// authority. While the probability that a UUID will be duplicated is not zero,
/// it is close enough to zero to be negligible.
///
/// > See: [IETF RFC 4122](https://datatracker.ietf.org/doc/html/rfc4122.html).
///
/// In its canonical textural representation, the 16 octets of a UUID are
/// represented as a 32 hexadecimel (base-16) digits, displayed in five groups
/// seperated by hyphens, in the form of `8-4-4-4-12`, for a total of 36
/// characters (32 hexacdecimel characters and 4 hyphens).
@immutable
@sealed
abstract class Uuid {
  /// Nil UUID.
  ///
  /// See [RFC 4122 4.1.7](https://tools.ietf.org/html/rfc4122#section-4.1.7).
  static const Uuid nil = _Uuid(0, 0, 0);

  /// Creates a UUID from five octets provided.
  ///
  /// This method is intended to be equivalent to:
  /// ```txt
  /// llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn
  /// ```
  factory Uuid(int l, int m, int h, int s, int n) {
    // Combine octets into three 48-bit integers.
    //
    // "llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn"
    //                  ->
    // <aaaaaaaa-aaaa-bbbb-bbbb-cccccccccccc>
    final a = m | (l << 16);
    final b = h | (s << 16);
    final c = n;
    return (a | b | c) == 0 ? nil : _Uuid(a, b, c);
  }

  /// Creates a UUID from hi/mid/lo bits that coorespond to 128 bits.
  ///
  /// - [a]: 48-bits; the time lo (32) and mid (16) bits.
  /// - [b]: 32-bits; the time hu (16) and clock sequence (16) bits.
  /// - [c]: 48-bits; the node id (48) bits.
  ///
  /// If any values are out of range, an error will be thrown.
  factory Uuid.fromInts(int a, int b, int c) {
    return _Uuid(
      RangeError.checkValueInInterval(
        a,
        0,
        0xffffffffffff,
        'a',
        '0 <> 48-bits',
      ),
      RangeError.checkValueInInterval(
        b,
        0,
        0x0000ffffffff,
        'b',
        '0 <> 32-bits',
      ),
      RangeError.checkValueInInterval(
        c,
        0,
        0xffffffffffff,
        'c',
        '0 <> 48-bits',
      ),
    );
  }

  static void _assertHyphen(String text, int position) {
    if (text.codeUnitAt(position) != 0x2d /* - */) {
      throw FormatException(
        "Expected '-' got '${text[position]}'",
        text,
        position,
      );
    }
  }

  static int _hexParseOrFail(String text, int position, int length) {
    final v = int.tryParse(
      text.substring(position, position + length),
      radix: 16,
    );
    if (v == null) {
      throw FormatException(
        'Expected $length-length hex octet',
        text,
        position,
      );
    }
    return v;
  }

  /// Creates a UUID by parsing the [text] format (36 octets including hyphens).
  ///
  /// ```txt
  /// 123e4567-e89b-12d3-a456-426614174000
  /// xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
  /// ```
  factory Uuid.parse(String text) {
    if (text.length != 36) {
      throw FormatException(
        'Expected a 36-length string, got ${text.length}-length',
        text,
      );
    }

    // Parse the 5 groups of hex octets.
    final l = _hexParseOrFail(text, 0, 8);
    _assertHyphen(text, 8);
    final m = _hexParseOrFail(text, 9, 4);
    _assertHyphen(text, 13);
    final h = _hexParseOrFail(text, 14, 4);
    _assertHyphen(text, 18);
    final s = _hexParseOrFail(text, 19, 4);
    _assertHyphen(text, 23);
    final n = _hexParseOrFail(text, 24, 12);
    return Uuid(l, m, h, s, n);
  }

  /// Creates a UUID with the provided fields.
  factory Uuid.fromFields({
    required int version,
    required int timestamp,
    required int clockSequence,
    required int node,
  }) {
    // <aaaaaaaa-aaaa-bbbb-bbbb-cccccccccccc">
    //                   ->
    // "llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn"
    //
    // field                     type      octet
    // ----------------------------------------
    // time_low                  uint32    0-3
    // time_mid                  uint16    4-5
    // time_hi_and_version       uint16    6-7
    // clock_seq_hi_and_reserved uint8     8
    // clock_seq_low             uint8     9
    // node                      uint48    10-15
    return Uuid(
      timestamp & (0x0000ffff >> 00),
      timestamp & (0x00ffff00 >> 08),
      timestamp & (0xffff0000 >> 16) | version,
      clockSequence,
      node,
    );
  }
}

/// Internal implementation of [Uuid] that is represented by 2 64-bit integers.
///
/// ```txt
/// a              b         c
/// -----------   --------- ------------
/// |         |    |     |    |
/// 32bs     16bs 16bs 16bs 48bs
/// 8        4    4    4    12
/// xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
/// ^        ^    ^    ^    ^
/// timeLow  ^    ^    clockSequence
///          timeMid       ^
///               ^         nodeId
///               timeHiAndVersion
/// ```
@immutable
class _Uuid implements Uuid {
  final int _a;
  final int _b;
  final int _c;

  const _Uuid(this._a, this._b, this._c);

  @override
  int get hashCode => Object.hash(_a, _b, _c);

  @override
  bool operator ==(Object other) {
    return other is _Uuid && _a == other._a && _b == other._b && _c == other._c;
  }

  @override
  String toString() {
    // <aaaaaaaa-aaaa-bbbb-bbbb-cccccccccccc">
    //                   ->
    // "llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn"
    final a = _a;
    final b = _b;
    final c = _c;

    final l = (a & 0xffffffff0000) >> 16;
    final m = (a & 0x00000000ffff) >> 00;
    final h = (b & 0x0000ffff0000) >> 16;
    final s = (b & 0x00000000ffff) >> 00;
    final n = c;

    // ignore: noop_primitive_operations
    return ''
        '${l.toRadixString(16).padLeft(8, '0')}-'
        '${m.toRadixString(16).padLeft(4, '0')}-'
        '${s.toRadixString(16).padLeft(4, '0')}-'
        '${h.toRadixString(16).padLeft(4, '0')}-'
        '${n.toRadixString(16).padLeft(12, '0')}';
  }
}

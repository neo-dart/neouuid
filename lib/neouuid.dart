/// Fast and idiomatic UUIDs (Universally Unique Identifiers) in Dart.
library neouuid;

import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Represents a class that, when [generate] is invoked, returns a new [Uuid].
///
/// By default, factory functions (such as [Uuid.v4]) can be used as a sort of
/// "default" [UuidGenerator].
abstract class UuidGenerator {
  /// Creates a new UUID.
  Uuid generate();
}

final _bufferUint8 = Uint8List(16);
final _bufferUint32 = Uint32List.view(_bufferUint8.buffer);

/// Generates unique timestamp-based UUIDs (i.e. [UuidVersion.v1]).
///
/// This is the default implementation for [Uuid.v1].
@sealed
class UuidV1Generator implements UuidGenerator {
  static int _generateUniqueId() {
    final rng = Random.secure();
    return rng.nextInt(0xffffffffffff);
  }

  static int _generateClockSequence() {
    final rng = Random.secure();
    return rng.nextInt(1 << 14);
  }

  // 48-bit integer; stays constant for each instance of the generator.
  final int _uniqueId;

  // Generates the current timestamp.
  final DateTime Function() _now;

  // JavaScript numbers are not precise enough for nanoseconds.
  //
  // Instead, we increment this value to simulate a higher resolution clock.
  var _lastNs = 0;
  var _lastMs = 0;

  // Consistently increases for each instance of the generator.
  int _clockSequence;

  /// Creates a new instance of a generator with the provided configuration.
  ///
  /// If omitted, [uniqueness] defaults to a random 6-byte (48-bit) ID.
  /// If omitted, [clockSequence] defaults to a random 14-bit value.
  factory UuidV1Generator({
    int? uniqueness,
    int? clockSequence,
    DateTime Function() now = DateTime.now,
  }) {
    return UuidV1Generator._(
      uniqueness ?? _generateUniqueId(),
      clockSequence ?? _generateClockSequence(),
      now,
    );
  }

  /// Creates a new instance of a generator from a previously generated [uuid].
  ///
  /// Both [Uuid.node] and [Uuid.clock] are used.
  ///
  /// If [Uuid.time] is ahead of [now], the clock sequence is increased.
  ///
  /// See: <https://tools.ietf.org/html/rfc4122#section-4.2.1>
  factory UuidV1Generator.fromLastUuid(
    Uuid uuid, {
    DateTime Function() now = DateTime.now,
  }) {
    if (uuid.version != UuidVersion.v1) {
      throw ArgumentError.value(uuid.version, 'version', 'UUID is not v1');
    }
    var clockSequence = uuid.clock;
    if (uuid.time!.compareTo(now()) > 0) {
      clockSequence++;
      clockSequence &= 0x3fff;
    }
    return UuidV1Generator._(uuid.node, clockSequence, now);
  }

  UuidV1Generator._(this._uniqueId, this._clockSequence, this._now);

  @override
  Uuid generate() {
    // https://datatracker.ietf.org/doc/html/rfc4122#section-4.2.2
    var clockSequence = _clockSequence;

    // Approximate higher-resoluton timestamps.
    var ms = _now().millisecondsSinceEpoch;
    var ns = ++_lastNs;

    // Time since last UUID creation (in ms).
    final dt = ms - _lastMs + (ns - _lastNs) / 10000;

    // Per 4.2.1.2, bump on clock regression.
    if (dt < 0) {
      clockSequence = (clockSequence + 1) & 0x3fff;
    }

    // Reset simulated nano-seconds if clock regresses or new time interval.
    if (dt < 0 || ms > _lastMs) {
      ns = 0;
    }

    // Per 4.2.1.2 throw an error if too many UUIDs are requested.
    if (ns >= 10000) {
      throw StateError('Cannot create more than 10M UUIDs/sec');
    }

    _lastMs = ms;
    _lastNs = ns;
    _clockSequence = clockSequence;

    // Per 4.1.4, convert from Unix epoch to Gregorian epoch.
    ms += 12219292800000;

    return _generate(ms, ns, clockSequence, _uniqueId);
  }

  /// This function is to isolate stateless generation from stateful.
  static Uuid _generate(int ms, int ns, int clockSequence, int nodeId) {
    const version = 0x1000;
    const variant = 0x8000;

    // Time (l/m/h)
    final mh = ((ms / 0x100000000).floor() * 10000) & 0xfffffff;
    final l = ((ms & 0xfffffff) * 10000 + ns) % 0x100000000;
    final m = mh & 0xffff;
    final h = (mh >> 16) & 0xfff | version;

    // Clock and Node
    final s = clockSequence | variant;
    final n = nodeId;

    return _Uuid(l, m, h, s, n);
  }
}

/// Generates random-based UUIDs (i.e. [UuidVersion.v4]).
///
/// This is the default implementation for [Uuid.v4].
@sealed
class UuidV4Generator implements UuidGenerator {
  final Random _random;

  /// Create a new instance of a generator with the provided [random].
  ///
  /// If omitted, [random] defaults to a new instance of [Random.secure].
  factory UuidV4Generator([Random? random]) = UuidV4Generator._;
  UuidV4Generator._([Random? random]) : _random = random ?? Random.secure();

  /// Creates a new UUID that is completely random.
  @override
  Uuid generate() {
    for (var i = 0; i < 4; i++) {
      final u32 = _random.nextInt(0xffffffff);
      _bufferUint8
        ..[i * 4] = u32 >> 24
        ..[i * 4 + 1] = u32 >> 16
        ..[i * 4 + 2] = u32 >> 8
        ..[i * 4 + 3] = u32;
    }

    // Variant 1.
    _bufferUint8[8] = (_bufferUint8[8] & 0x3f) | 0x80;

    // Version 4.
    _bufferUint8[6] = (_bufferUint8[6] & 0x0f) | 0x40;

    return Uuid.fromBytes(_bufferUint32);
  }
}

/// A **u**niversally **u**nique **id**entifier, or UUID; a 128-bit label.
///
/// UUIds, are, for practical purposes, unique and without a central registration
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
  /// A special case UUID that is guaranteed to _not_ be unique.
  ///
  /// The Nil UUID is all zeros, i.e.:
  /// ```txt
  /// 00000000-0000-0000-0000-000000000000
  /// ```
  static const Uuid nil = _Uuid.fromInts(0, 0, 0, 0);

  static final _isUuid = RegExp(
    '[0-9a-fA-F]{8}-'
    '[0-9a-fA-F]{4}-'
    '[0-9a-fA-F]{4}-'
    '[0-9a-fA-F]{4}-'
    '[0-9a-fA-F]{12}',
  );

  /// Returns whether the provided [input] can be parsed as a valid UUID.
  ///
  /// If this method returns `false`, [Uuid.parse] would throw an exception.
  static bool isUuid(String input) {
    return input.length == 36 && _isUuid.matchAsPrefix(input) != null;
  }

  /// Creates a UUID from the provided 5 sets of octets.
  ///
  /// ```txt
  /// llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn
  /// ```
  ///
  /// If any provided integer is out of range, an error will be thrown:
  ///
  /// - [l]: unsigned 32-bits
  /// - [m]: unsigned 16-bits
  /// - [h]: unsigned 16-bits
  /// - [s]: unsigned 16-bits
  /// - [n]: unsigned 48-bits
  ///
  /// This is intended to be a convenience constructor instead [Uuid.parse] :
  /// ```
  /// // These UUIDs represent the same value.
  /// Uuid.parse('123e4567-e89b-12d3-a456-426655440000')
  /// Uuid(0x123e4567, 0xe89b, 0x12d3, 0xa456, 0x426655440000)
  /// ```
  factory Uuid(int l, int m, int h, int s, int n) {
    return _Uuid(
      RangeError.checkValueInInterval(l, 0x000000000000, 0x0000ffffffff),
      RangeError.checkValueInInterval(m, 0x000000000000, 0x00000000ffff),
      RangeError.checkValueInInterval(h, 0x000000000000, 0x00000000ffff),
      RangeError.checkValueInInterval(s, 0x000000000000, 0x00000000ffff),
      RangeError.checkValueInInterval(n, 0x000000000000, 0xffffffffffff),
    );
  }

  /// Creates a UUID from 4 32-bit integers encoded as [bytes].
  factory Uuid.fromBytes(Uint32List bytes) {
    if (bytes.length != 4) {
      throw ArgumentError(
        'Expected a 4-length list, got ${bytes.length}-length',
      );
    }
    return _Uuid.fromInts(bytes[0], bytes[1], bytes[2], bytes[3]);
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

  static int _parseHex(String text, int position, int length) {
    return int.parse(text.substring(position, position + length), radix: 16);
  }

  /// Parses and returns the provided [input] as a UUID.
  ///
  /// If not a valid UUID, a [FormatException] is thrown.
  factory Uuid.parse(String input) {
    if (input.length != 36) {
      throw FormatException(
        'Expected a 36-length string, got ${input.length}-length',
        input,
      );
    }

    final l = _parseHex(input, 0, 8);
    _assertHyphen(input, 0 + 8);
    final m = _parseHex(input, 9, 4);
    _assertHyphen(input, 9 + 4);
    final h = _parseHex(input, 14, 4);
    _assertHyphen(input, 14 + 4);
    final s = _parseHex(input, 19, 4);
    _assertHyphen(input, 19 + 4);
    final n = _parseHex(input, 24, 12);

    // Intentionlaly not validated, as it's impossible *not* to be in range.
    return _Uuid(l, m, h, s, n);
  }

  static final _uuidV1 = UuidV1Generator();

  /// Generates and returns a unique timestamp-based UUID.
  ///
  /// For additional customization, create an instance of [UuidV1Generator].
  factory Uuid.v1({
    DateTime Function() now = DateTime.now,
    int? key,
  }) {
    final UuidGenerator generator;
    if (now == DateTime.now && key == null) {
      generator = _uuidV1;
    } else {
      generator = UuidV1Generator(
        uniqueness: key,
        now: now,
      );
    }
    return generator.generate();
  }

  static final _uuidV4 = UuidV4Generator();

  /// Creates and returns a random UUID.
  factory Uuid.v4({Random? random}) {
    return (random == null ? UuidV4Generator(random) : _uuidV4).generate();
  }

  /// Returns a timestamp if [UuidVersion.v1], otherwise returns `null`.
  DateTime? get time;

  /// Known version of the UUID.
  ///
  /// A result of `null` means the version is unknown.
  UuidVersion? get version;

  /// Returns the clock sequence, which varies based on [version].
  ///
  /// - For [UuidVersion.v1]; avoids duplicates when the clock/node ID changes.
  /// - For [UuidVersion.v3] or [UuidVersion.v5]; 14-bit value from a name.
  /// - For [UuidVersion.v4], a (pseudo)-randomly generated 14-bit value.
  ///
  /// The clock sequence **must** be originally (i.e., once in the lifetime of a
  /// system) initialized to a random number to minimize the correlation across
  /// systems.
  int get clock;

  /// Known variant of the UUID.
  ///
  /// A result of `null` means the variant is unknown or invalid.
  UuidVariant? get variant;

  /// Either the MAC address of the node or sometimes a random number.
  int get node;

  /// Returns this UUID representation as 4 32-bit integers.
  Uint32List toBytes();

  /// Returns this UUIDs representation as a string.
  ///
  /// Each field is treated as an integer, and has its value printed as a
  /// zero-filled hexadecimel digit string with the most significant digit
  /// first.
  @override
  String toString();
}

/// Implementation of [Uuid], represented as 4 32-bit unsigned integers.
///
/// # How to decode a UUID
///
/// ```txt
/// 123e4567-e89b-12d3-a456-426655440000
/// aaaaaaaa-bbbb-bbbb-cccc-ccccdddddddd
/// xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx
///               ^    ^
///         Version    Variant
/// ```
class _Uuid implements Uuid {
  /// 1: Uint32; represents "low" bits of [time].
  final int _a;

  /// 2: Uint32; represents "mid", "hi" bits of [time], [version].
  final int _b;

  /// 3: Uint32; represents [clock], [variant], "low" bits of [node].
  final int _c;

  /// 4: Uint32: represents the "hi" bits of [node].
  final int _d;

  /// Creates a UUID from 5 provided sets of octets.
  ///
  /// ```txt
  /// 123e4567-e89b-12d3-a456-426655440000
  /// aaaaaaaa-bbbb-bbbb-cccc-ccccdddddddd
  /// llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn
  /// ```
  ///
  /// **WARNING**: No validation is performed that these numbers are valid.
  factory _Uuid(int l, int m, int h, int s, int n) {
    final a = l;
    final b = (m << 16) | h;
    final c = (s << 16) | _getHi(n);
    final d = n & 0xffffffff;
    return _Uuid.fromInts(a, b, c, d);
  }

  /// Creates a UUID from 4 provided 32-bit unsigned integers.
  ///
  /// **WARNING**: No validation is performed that these numbers are valid.
  const _Uuid.fromInts(this._a, this._b, this._c, this._d);

  @override
  int get hashCode => Object.hash(_a, _b, _c, _d);

  @override
  bool operator ==(Object o) {
    return o is _Uuid && _a == o._a && _b == o._b && _c == o._c && _d == o._d;
  }

  @override
  @override
  DateTime? get time {
    if (version != UuidVersion.v1) {
      return null;
    }

    // 123e4567-e89b-12d3-a456-426655440000
    // aaaaaaaa-bbbb-bbbb-cccc-ccccdddddddd
    // llllllll-mmmm-xhhh-ssss-nnnnnnnnnnnn
    final h = _b & 0x0fff;
    final m = _b >> 16;
    final l = _a;

    // If we were to combine all three of these numbers, it would be ~60 bits,
    // which isn't compatible in the browser (thanks to JavaScript). Therefore,
    // we use "BigInt" to avoid having to encode a tons of logic for safe
    // division with multiple bits.
    final hi = ((h << 16) | m).toRadixString(16);
    final lo = l.toRadixString(16);
    final hiLo = BigInt.parse('$hi$lo', radix: 16);

    // Convert into milliseconds, to Unix epoch, etc.
    final tsSec = hiLo ~/ _$100nsIntervalsToSeconds;
    final tsUnx = tsSec.toInt() - _gregorianToUnix;
    return DateTime.fromMillisecondsSinceEpoch(tsUnx * 1000, isUtc: true);
  }

  @override
  UuidVersion? get version {
    final code = (_b & 0xf000) >> 12;
    return code > 0 && code <= 5 ? UuidVersion.values[code - 1] : null;
  }

  @override
  int get clock => (_c >> 16) - ((variant?._mask ?? 0x0) << 12);

  @override
  UuidVariant? get variant {
    final digit = _c >> 28;
    if (digit & 0xf /* 1111 */ == 0xf) {
      return null;
    }
    if (UuidVariant.reservedFuture._matches(digit)) {
      return UuidVariant.reservedFuture;
    }
    if (UuidVariant.reservedMicrosoft._matches(digit)) {
      return UuidVariant.reservedMicrosoft;
    }
    if (UuidVariant.isoRfc4122Standard._matches(digit)) {
      return UuidVariant.isoRfc4122Standard;
    }
    if (!UuidVariant.reservedNcsBackwardsCompatible._matches(digit)) {
      throw StateError('Expected NCS Backawards Compatible');
    }
    return UuidVariant.reservedNcsBackwardsCompatible;
  }

  @override
  int get node {
    // In JavaScript both `|` and `<< 32` would be truncated.
    return _d + ((_c & 0xffff) * _pow2to32);
  }

  static String _toOctals(int i, int l) => i.toRadixString(16).padLeft(l, '0');

  @override
  Uint32List toBytes() => Uint32List(4)
    ..[0] = _a
    ..[1] = _b
    ..[2] = _c
    ..[3] = _d;

  @override
  String toString() {
    // <aaaaaaaa-bbbb-bbbb-cccc-ccccdddddddd>
    //                   -->
    // <llllllll-mmmm-hhhh-ssss-nnnnnnnnnnnn>
    final a = _a;
    final b = _b;
    final c = _c;
    final d = _d;

    // Identical to 'a'.
    final l = a;
    // MS 16-bits of 'b'.
    final m = b >> 16;
    // LS 16-bits of 'b'.
    final h = b & 0xffff;
    // MS 16-bits of 'c'.
    final s = c >> 16;
    // LS 16-bits of 'c' and 32-bits of 'd'.
    final n = _hiLo(c & 0xffff, d);

    // ignore: noop_primitive_operations
    return ''
        '${_toOctals(l, 08)}-'
        '${_toOctals(m, 04)}-'
        '${_toOctals(h, 04)}-'
        '${_toOctals(s, 04)}-'
        '${_toOctals(n, 12)}';
  }
}

/// Known UUID versions, i.e. to be returned by [Uuid.version].
///
/// For most values (except [v2]), see <https://tools.ietf.org/html/rfc4122>.
enum UuidVersion {
  /// A UUID generated using a timestamp and MAC address.
  v1,

  /// A "DCE Security" UUID.
  ///
  /// See <https://pubs.opengroup.org/onlinepubs/9696989899/chap5.htm#tagcjh_08_02_01_01>.
  v2,

  /// Non-random output UUID, based on a MD5 hash.
  v3,

  /// Randomly generated.
  v4,

  /// Non-random output UUID, based on a truncated SHA-1 hash.
  v5,
}

/// Known UUID variant, i.e. to be returned by [Uuid.variant].
enum UuidVariant {
  // ignore: public_member_api_docs
  reservedNcsBackwardsCompatible(0x0),

  // ignore: public_member_api_docs
  isoRfc4122Standard(0x8),

  // ignore: public_member_api_docs
  reservedMicrosoft(0xc),

  // ignore: public_member_api_docs
  reservedFuture(0xe);

  /// Mask that determines this variant.
  final int _mask;

  // ignore: public_member_api_docs
  const UuidVariant(this._mask);

  /// Whether the mask matches the provided number.
  bool _matches(int input) => input & _mask == _mask;
}

/// Represents `math.pow(2, 32)`, precomputed.
const _pow2to32 = 0x100000000;

/// Represents the difference between the Unix and Gregorian epochs.
///
/// ```dart
/// // Unix -> Gregorian
/// ms += _unixGregorianEpochDelta;
///
/// // Gregorian --> Unix
/// ms -= _unixGregorianEpochDelta;
/// ```
const _gregorianToUnix = 12219292800;

/// Represents the dividend to convert from 100 nanosecond intervals to seconds.
///
/// ```dart
/// seconds = timeIn100NsIntervals / _100nsIntervalsToSeconds;
/// ```
final _$100nsIntervalsToSeconds = BigInt.from(10000000);

/// Using the `input >> 32` operator won't work as intended.
///
/// This function is _essentially_ the same, but works in all platforms.
int _getHi(int input) => (input / _pow2to32).floor() | 0;

/// Using the `input << 32` operator won't work as intended.
///
/// This fucntion is _essentially_ the same, but works in all platforms.
int _hiLo(int hi, int lo) => (hi * _pow2to32) + lo;

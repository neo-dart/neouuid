// ignore_for_file: avoid_print

import 'package:neouuid/neouuid.dart';

void main() {
  // Parse a UUID based on the text format.
  final a = Uuid.parse('31ae75f0-cbe0-11e8-b568-0800200c9a66');
  print(a);

  // Identical to above.
  final b = Uuid(0x31ae75f0, 0xcbe0, 0x11e8, 0xb568, 0x0800200c9a66);
  print(b);

  // Inspect various variables:
  print({
    // 13672
    'clock': b.clock,
    // 8796630719078
    'node': b.node,
    // 2018-10-09 16:27:20.000Z,
    'time': b.time,
    // UuidVariant.isoRfc4122Standard
    'variant': b.variant,
    // UuidVersion.v1
    'version': b.version,
  });
}

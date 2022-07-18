// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, constant_identifier_names

import 'package:neouuid/neouuid.dart';

/// A test program, running in the Dart VM, to help debug extracting time.
///
/// See:
/// - <https://www.rfc-editor.org/rfc/rfc4122#section-4.1.4>.
/// - <https://dabblingwithdata.wordpress.com/2018/10/13/extracting-the-date-and-time-a-uuid-was-created-with-bigquery-sql-with-a-brief-foray-into-the-history-of-the-gregorian-calendar/>
void main() {
  // Example UUID: 31ae75f0-cbe0-11e8-b568-0800200c9a66
  //               ^^^^^^^^ ^^^^  ^^^
  //               lo       mid   hi
  const input = '31ae75f0-cbe0-11e8-b568-0800200c9a66';
  print(
    'UUID: $input',
  );

  // Reversed chunks (endianness).
  //                     vvvvvvvv
  //                 vvvv
  //              vvv
  const stamp = 0x1e8cbe031ae75f0;
  print(
    'TIME: ${stamp.toRadixString(16)} (in 100-ns intervals since 1582-10-15)',
  );

  const _100nsIntervals = 10000000;
  const gregorianToUnix = 12219292800;
  final stampAsS = (stamp / _100nsIntervals).floor() - gregorianToUnix;
  print('T__S: $stampAsS');

  final stampAsMs = stampAsS * 1000;
  print(DateTime.fromMillisecondsSinceEpoch(stampAsMs, isUtc: true));

  // Now try to reproduce this with the UUID library.
  final uuid = Uuid.parse(input);
  print(uuid.time);
  print(uuid.variant!.name);

  const clock = 0xb568 - 0x8000;
  print('CLCK: $clock');
  print('CLCK: ${uuid.clock}');

  print('NODE: 0x0800200c9a66');
  print('NODE: 0x${uuid.node.toRadixString(16)}');
}

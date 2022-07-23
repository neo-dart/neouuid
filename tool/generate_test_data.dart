import 'dart:io';
import 'dart:math';

import 'package:neouuid/neouuid.dart';
import 'package:path/path.dart' as path;

void main() {
  final generator = UuidV4Generator(Random(12345));
  final uuids = <String>[];
  for (var i = 0; i < 10000; i++) {
    uuids.add(generator.generate().toString());
  }
  File(path.join(
    'benchmark',
    'test_data.txt',
  )).writeAsStringSync(uuids.join('\n'));
}

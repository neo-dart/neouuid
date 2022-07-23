import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

abstract class ParseBenchmark extends BenchmarkBase {
  late final List<String> _data;
  var _index = 0;

  ParseBenchmark(String name) : super(name);

  @override
  @mustCallSuper
  void setup() {
    _data = File(path.join('benchmark', 'test_data.txt')).readAsLinesSync();
  }

  @override
  void run() {
    parse(_data[_index]);
    if (_index == _data.length) {
      _index = 0;
    }
  }

  @protected
  void parse(String uuid);
}

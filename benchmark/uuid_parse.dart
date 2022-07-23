import 'package:uuid/uuid.dart' as pkg_uuid;

import '_base.dart';

void main() {
  _PackageUuidParser().report();
}

class _PackageUuidParser extends ParseBenchmark {
  _PackageUuidParser() : super('package:uuid');

  @override
  void parse(String uuid) {
    pkg_uuid.Uuid.parse(uuid);
  }
}

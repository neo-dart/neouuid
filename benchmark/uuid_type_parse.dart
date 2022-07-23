import 'package:uuid_type/uuid_type.dart' as pkg_uuid_type;

import '_base.dart';

void main() {
  _PackageUuidTypeParser().report();
}

class _PackageUuidTypeParser extends ParseBenchmark {
  _PackageUuidTypeParser() : super('package:uuid_type');

  @override
  void parse(String uuid) {
    pkg_uuid_type.Uuid.parse(uuid);
  }
}

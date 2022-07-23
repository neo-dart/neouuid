import 'package:neouuid/neouuid.dart' as pkg_neo_uuid;

import '_base.dart';

void main() {
  _PackageNeoUuidParser().report();
}

class _PackageNeoUuidParser extends ParseBenchmark {
  _PackageNeoUuidParser() : super('package:neouuid');

  @override
  void parse(String uuid) {
    pkg_neo_uuid.Uuid.parse(uuid);
  }
}

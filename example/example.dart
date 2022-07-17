import 'package:neouuid/neouuid.dart';

void main() {
  final uuid = Uuid.parse('12345678-1234-5678-9abc-123456789012');
  print(uuid);
}

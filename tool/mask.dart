import 'dart:io';

/// ```sh
/// # Generates a mask for a 32-bit integer:
/// dart tool/mask.dart 32
/// ```
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    _failWithUsage();
  }

  if (arguments.length == 1) {}
}

Never _failWithUsage() {
  stderr.writeln('Usage: dart tool/mask.dart <number_of_bits>');
  return exit(1);
}

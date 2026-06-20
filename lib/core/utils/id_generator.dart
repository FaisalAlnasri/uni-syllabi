import 'dart:math';

/// Generates a random 128-bit hex id, matching the scheme used by the course
/// data models so manually-created courses/deliverables get stable unique ids.
String generateId() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

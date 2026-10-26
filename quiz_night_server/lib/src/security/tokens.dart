import 'dart:convert';

/// Constant-time compare so timing can't leak how much of a token matched.
/// Tokens have a fixed length, so an early length-mismatch exit is safe.
bool tokensMatch(String? stored, String presented) {
  if (stored == null) return false;
  final a = utf8.encode(stored);
  final b = utf8.encode(presented);
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }
  return difference == 0;
}

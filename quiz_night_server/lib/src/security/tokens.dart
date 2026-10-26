import 'dart:convert';

/// Compares a stored secret with a presented one in time that doesn't depend
/// on where they first differ, so response timing can't reveal how much of
/// a guessed token was right. Tokens have a fixed length, so returning early
/// on a length mismatch reveals nothing.
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

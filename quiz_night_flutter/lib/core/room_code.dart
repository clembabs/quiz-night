import 'package:flutter/services.dart';

/// Room codes: four letters and digits (five if four ever run short),
/// without look-alikes, always shown in capitals.
abstract final class RoomCode {
  static const maxLength = 5;

  /// What a code looks like, for hints.
  static const example = 'K7QM';

  static final _pattern = RegExp(r'^[A-Z0-9]{4,5}$');

  /// Upper case, letters and digits only, at most [maxLength].
  static String clean(String text) {
    final kept = text.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    return kept.length > maxLength ? kept.substring(0, maxLength) : kept;
  }

  /// Whether [text] is long enough to try joining with.
  static bool isComplete(String text) => _pattern.hasMatch(clean(text));

  /// For code fields: capitals as you type, nothing but letters and digits.
  static final List<TextInputFormatter> formatters = [
    TextInputFormatter.withFunction(
      (old, now) => now.copyWith(
        text: clean(now.text),
        selection: TextSelection.collapsed(offset: clean(now.text).length),
      ),
    ),
  ];
}

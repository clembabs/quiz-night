/// Nicknames show on the shared big screen, so the server cleans and checks
/// them before anyone joins.
abstract final class Nickname {
  static const maxLength = 20;

  /// Invisible and control characters: control codes, format characters
  /// (zero-width spaces and joiners, right-to-left overrides), private-use
  /// and unassigned code points. They hide text, fake other names or flip
  /// what the big screen shows.
  static final _invisible = RegExp(
    r'[\p{Cc}\p{Cf}\p{Co}\p{Cn}]',
    unicode: true,
  );

  /// Any run of whitespace, including line and paragraph separators.
  static final _spaces = RegExp(r'[\s\p{Zl}\p{Zp}]+', unicode: true);

  /// The nickname as it will be shown: invisible characters removed, spaces
  /// folded to single ones and trimmed. May be empty.
  static String clean(String raw) =>
      raw.replaceAll(_invisible, '').replaceAll(_spaces, ' ').trim();

  /// Look-alike digits and symbols people use to dodge filters.
  static const _lookAlikes = {
    '0': 'o',
    '1': 'i',
    '!': 'i',
    '3': 'e',
    '4': 'a',
    '@': 'a',
    '5': 's',
    r'$': 's',
    '7': 't',
    '8': 'b',
  };

  /// Blocked even inside a longer word: strong words that don't turn up
  /// inside ordinary names.
  static const _blockedAnywhere = [
    'fuck',
    'shit',
    'cunt',
    'nigger',
    'nigga',
    'faggot',
    'bitch',
    'whore',
    'slut',
    'rapist',
    'porn',
    'wank',
    'bastard',
    'retard',
  ];

  /// Blocked only as a whole word, because they hide inside innocent names
  /// (Cassandra, Dickens, Glass, Titus).
  static const _blockedWords = {
    'ass',
    'arse',
    'cock',
    'dick',
    'piss',
    'tit',
    'tits',
    'sex',
    'rape',
    'nazi',
    'hitler',
    'kkk',
    'fag',
  };

  /// Lower case, look-alikes swapped back to letters.
  static String _fold(String name) {
    final lower = name.toLowerCase();
    final out = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      out.write(_lookAlikes[ch] ?? ch);
    }
    return out.toString();
  }

  static final _nonLetters = RegExp(r'[^a-z]+');

  /// Whether [name] contains a blocked word, however it is spaced or spelt.
  static bool isOffensive(String name) {
    final folded = _fold(name);
    final squashed = folded.replaceAll(_nonLetters, '');
    if (_blockedAnywhere.any(squashed.contains)) return true;
    final words = folded.split(_nonLetters).where((w) => w.isNotEmpty);
    return words.any(_blockedWords.contains);
  }
}

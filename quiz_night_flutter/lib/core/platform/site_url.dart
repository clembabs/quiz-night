/// The site's root address (scheme, host and port), e.g. for the lobby QR.
/// Falls back to [Uri.base] when it has no web origin (tests, file URLs).
Uri siteRoot([Uri? base]) {
  final b = base ?? Uri.base;
  if (!b.hasAuthority || !(b.scheme == 'http' || b.scheme == 'https')) {
    return b;
  }
  return Uri.parse('${b.origin}/');
}

/// The site's root (scheme, host, port), else [Uri.base] (tests, files).
Uri siteRoot([Uri? base]) {
  final b = base ?? Uri.base;
  if (!b.hasAuthority || !(b.scheme == 'http' || b.scheme == 'https')) {
    return b;
  }
  return Uri.parse('${b.origin}/');
}

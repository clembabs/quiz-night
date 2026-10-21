/// Every URL in the app, so screens never spell paths out themselves.
abstract final class AppPaths {
  static const home = '/';
  static const howItWorks = '/how-it-works';
  static const teachers = '/teachers';
  static const faq = '/faq';
  static const join = '/join';
  static const host = '/host';
  static const room = '/room/:code';

  /// The join form, pre-filled with [code] when there is one.
  static String joinWith(String? code) => code == null || code.isEmpty
      ? join
      : Uri(path: join, queryParameters: {'code': code}).toString();

  static String roomFor(String code) => '/room/${Uri.encodeComponent(code)}';
}

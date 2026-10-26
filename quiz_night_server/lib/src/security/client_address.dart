import 'package:serverpod/serverpod.dart';

/// Caller IP for rate limits; behind a proxy, the last `X-Forwarded-For`
/// entry (the one clients can't fake). `internal` if no request.
String clientAddress(Session session) {
  final request = session.request;
  if (request == null) return 'internal';
  final forwarded = request.headers.xForwardedFor?.addresses;
  if (forwarded != null && forwarded.isNotEmpty) return forwarded.last.trim();
  return request.connectionInfo.remote.address.toString();
}

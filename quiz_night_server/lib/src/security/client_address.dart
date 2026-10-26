import 'package:serverpod/serverpod.dart';

/// Who is calling, for rate limits: the client's IP address.
///
/// Behind a proxy (Serverpod Cloud's load balancer, or an ngrok tunnel in
/// testing) the socket address is the proxy's, so the client comes from
/// `X-Forwarded-For`. The proxy appends the address it saw, so the *last*
/// entry is the one a client can't fake; earlier entries are whatever the
/// client sent. Calls with no request (tests, internal sessions) share the
/// key `internal`.
String clientAddress(Session session) {
  final request = session.request;
  if (request == null) return 'internal';
  final forwarded = request.headers.xForwardedFor?.addresses;
  if (forwarded != null && forwarded.isNotEmpty) return forwarded.last.trim();
  return request.connectionInfo.remote.address.toString();
}

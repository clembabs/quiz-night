/// An error from a repository, already turned into something a user can read.
///
/// Cubits catch this instead of transport-specific exceptions, so they do not
/// depend on Serverpod.
class AppFailure implements Exception {
  final String message;

  /// True when the room no longer exists on the server.
  final bool roomGone;

  const AppFailure(this.message, {this.roomGone = false});

  static const connection = AppFailure('Could not reach the server');

  @override
  String toString() => 'AppFailure($message)';
}

/// What went wrong, for the cases the app reacts to differently.
enum FailureKind {
  /// The server could not be reached.
  connection,

  /// The room no longer exists.
  roomGone,

  /// This player already answered; their first answer stands.
  alreadyAnswered,

  /// The question closed before the answer arrived.
  tooLate,

  /// Joining a room whose game is already under way.
  gameStarted,

  /// Someone in the room already has this nickname.
  nicknameTaken,

  /// The room already has the most players it allows.
  roomFull,

  /// The host has closed the room to new players.
  roomLocked,

  /// Anything else; just show the message.
  other,
}

/// An error from a repository, already turned into something a user can read.
///
/// Cubits catch this instead of transport-specific exceptions, so they do not
/// depend on Serverpod.
class AppFailure implements Exception {
  final String message;
  final FailureKind kind;

  const AppFailure(this.message, {this.kind = FailureKind.other});

  bool get roomGone => kind == FailureKind.roomGone;

  static const connection = AppFailure(
    'Could not reach the server',
    kind: FailureKind.connection,
  );

  @override
  String toString() => 'AppFailure($kind: $message)';
}

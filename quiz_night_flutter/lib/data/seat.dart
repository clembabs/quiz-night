import 'package:equatable/equatable.dart';

enum SeatRole { host, player }

/// Who this browser is in a room (host or player); [token] proves it.
class Seat extends Equatable {
  final SeatRole role;
  final String code;
  final String token;

  /// Set for players only.
  final int? playerId;

  const Seat({
    required this.role,
    required this.code,
    required this.token,
    this.playerId,
  });

  bool get isHost => role == SeatRole.host;

  @override
  List<Object?> get props => [role, code, token, playerId];
}

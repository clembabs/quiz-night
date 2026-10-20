/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class JoinResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  JoinResult._({
    required this.roomCode,
    required this.playerId,
    required this.playerToken,
  });

  factory JoinResult({
    required String roomCode,
    required int playerId,
    required String playerToken,
  }) = _JoinResultImpl;

  factory JoinResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return JoinResult(
      roomCode: jsonSerialization['roomCode'] as String,
      playerId: jsonSerialization['playerId'] as int,
      playerToken: jsonSerialization['playerToken'] as String,
    );
  }

  String roomCode;

  int playerId;

  String playerToken;

  /// Returns a shallow copy of this [JoinResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  JoinResult copyWith({
    String? roomCode,
    int? playerId,
    String? playerToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JoinResult',
      'roomCode': roomCode,
      'playerId': playerId,
      'playerToken': playerToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JoinResult',
      'roomCode': roomCode,
      'playerId': playerId,
      'playerToken': playerToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _JoinResultImpl extends JoinResult {
  _JoinResultImpl({
    required String roomCode,
    required int playerId,
    required String playerToken,
  }) : super._(
         roomCode: roomCode,
         playerId: playerId,
         playerToken: playerToken,
       );

  /// Returns a shallow copy of this [JoinResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  JoinResult copyWith({
    String? roomCode,
    int? playerId,
    String? playerToken,
  }) {
    return JoinResult(
      roomCode: roomCode ?? this.roomCode,
      playerId: playerId ?? this.playerId,
      playerToken: playerToken ?? this.playerToken,
    );
  }
}

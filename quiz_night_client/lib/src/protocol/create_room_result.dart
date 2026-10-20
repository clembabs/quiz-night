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

abstract class CreateRoomResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreateRoomResult._({
    required this.roomCode,
    required this.hostToken,
  });

  factory CreateRoomResult({
    required String roomCode,
    required String hostToken,
  }) = _CreateRoomResultImpl;

  factory CreateRoomResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreateRoomResult(
      roomCode: jsonSerialization['roomCode'] as String,
      hostToken: jsonSerialization['hostToken'] as String,
    );
  }

  String roomCode;

  String hostToken;

  /// Returns a shallow copy of this [CreateRoomResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreateRoomResult copyWith({
    String? roomCode,
    String? hostToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreateRoomResult',
      'roomCode': roomCode,
      'hostToken': hostToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreateRoomResult',
      'roomCode': roomCode,
      'hostToken': hostToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CreateRoomResultImpl extends CreateRoomResult {
  _CreateRoomResultImpl({
    required String roomCode,
    required String hostToken,
  }) : super._(
         roomCode: roomCode,
         hostToken: hostToken,
       );

  /// Returns a shallow copy of this [CreateRoomResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreateRoomResult copyWith({
    String? roomCode,
    String? hostToken,
  }) {
    return CreateRoomResult(
      roomCode: roomCode ?? this.roomCode,
      hostToken: hostToken ?? this.hostToken,
    );
  }
}

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
import 'package:serverpod/serverpod.dart' as _is;
import 'player_status.dart' as _iarmrzsm;

/// Public view of a player (no token).
abstract class PlayerView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PlayerView._({
    required this.id,
    required this.nickname,
    required this.score,
    required this.shadowScore,
    required this.finalScore,
    required this.status,
    this.eliminatedInRound,
    this.backedPlayerId,
    required this.hasAnswered,
    this.lastPoints,
    required this.lockedOut,
  });

  factory PlayerView({
    required int id,
    required String nickname,
    required int score,
    required int shadowScore,
    required int finalScore,
    required _iarmrzsm.PlayerStatus status,
    int? eliminatedInRound,
    int? backedPlayerId,
    required bool hasAnswered,
    int? lastPoints,
    required bool lockedOut,
  }) = _PlayerViewImpl;

  factory PlayerView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlayerView(
      id: jsonSerialization['id'] as int,
      nickname: jsonSerialization['nickname'] as String,
      score: jsonSerialization['score'] as int,
      shadowScore: jsonSerialization['shadowScore'] as int,
      finalScore: jsonSerialization['finalScore'] as int,
      status: _iarmrzsm.PlayerStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      eliminatedInRound: jsonSerialization['eliminatedInRound'] as int?,
      backedPlayerId: jsonSerialization['backedPlayerId'] as int?,
      hasAnswered: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasAnswered'],
      ),
      lastPoints: jsonSerialization['lastPoints'] as int?,
      lockedOut: _is.BoolJsonExtension.fromJson(jsonSerialization['lockedOut']),
    );
  }

  int id;

  String nickname;

  int score;

  int shadowScore;

  int finalScore;

  _iarmrzsm.PlayerStatus status;

  int? eliminatedInRound;

  /// Only revealed once the game is finished.
  int? backedPlayerId;

  bool hasAnswered;

  /// Points from the current question; only set after reveal.
  int? lastPoints;

  bool lockedOut;

  /// Returns a shallow copy of this [PlayerView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlayerView copyWith({
    int? id,
    String? nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    _iarmrzsm.PlayerStatus? status,
    int? eliminatedInRound,
    int? backedPlayerId,
    bool? hasAnswered,
    int? lastPoints,
    bool? lockedOut,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlayerView',
      'id': id,
      'nickname': nickname,
      'score': score,
      'shadowScore': shadowScore,
      'finalScore': finalScore,
      'status': status.toJson(),
      if (eliminatedInRound != null) 'eliminatedInRound': eliminatedInRound,
      if (backedPlayerId != null) 'backedPlayerId': backedPlayerId,
      'hasAnswered': hasAnswered,
      if (lastPoints != null) 'lastPoints': lastPoints,
      'lockedOut': lockedOut,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlayerView',
      'id': id,
      'nickname': nickname,
      'score': score,
      'shadowScore': shadowScore,
      'finalScore': finalScore,
      'status': status.toJson(),
      if (eliminatedInRound != null) 'eliminatedInRound': eliminatedInRound,
      if (backedPlayerId != null) 'backedPlayerId': backedPlayerId,
      'hasAnswered': hasAnswered,
      if (lastPoints != null) 'lastPoints': lastPoints,
      'lockedOut': lockedOut,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerViewImpl extends PlayerView {
  _PlayerViewImpl({
    required int id,
    required String nickname,
    required int score,
    required int shadowScore,
    required int finalScore,
    required _iarmrzsm.PlayerStatus status,
    int? eliminatedInRound,
    int? backedPlayerId,
    required bool hasAnswered,
    int? lastPoints,
    required bool lockedOut,
  }) : super._(
         id: id,
         nickname: nickname,
         score: score,
         shadowScore: shadowScore,
         finalScore: finalScore,
         status: status,
         eliminatedInRound: eliminatedInRound,
         backedPlayerId: backedPlayerId,
         hasAnswered: hasAnswered,
         lastPoints: lastPoints,
         lockedOut: lockedOut,
       );

  /// Returns a shallow copy of this [PlayerView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlayerView copyWith({
    int? id,
    String? nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    _iarmrzsm.PlayerStatus? status,
    Object? eliminatedInRound = _Undefined,
    Object? backedPlayerId = _Undefined,
    bool? hasAnswered,
    Object? lastPoints = _Undefined,
    bool? lockedOut,
  }) {
    return PlayerView(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      shadowScore: shadowScore ?? this.shadowScore,
      finalScore: finalScore ?? this.finalScore,
      status: status ?? this.status,
      eliminatedInRound: eliminatedInRound is int?
          ? eliminatedInRound
          : this.eliminatedInRound,
      backedPlayerId: backedPlayerId is int?
          ? backedPlayerId
          : this.backedPlayerId,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      lastPoints: lastPoints is int? ? lastPoints : this.lastPoints,
      lockedOut: lockedOut ?? this.lockedOut,
    );
  }
}

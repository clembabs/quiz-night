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
import 'player_status.dart' as _iarmrzsm;

abstract class Player
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Player._({
    this.id,
    required this.roomId,
    required this.nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    int? totalCorrectAnswerMs,
    _iarmrzsm.PlayerStatus? status,
    this.eliminatedInRound,
    this.backedPlayerId,
    this.exitLine,
    this.leftAt,
    DateTime? joinedAt,
  }) : score = score ?? 0,
       shadowScore = shadowScore ?? 0,
       finalScore = finalScore ?? 0,
       totalCorrectAnswerMs = totalCorrectAnswerMs ?? 0,
       status = status ?? _iarmrzsm.PlayerStatus.active,
       joinedAt = joinedAt ?? DateTime.now();

  factory Player({
    int? id,
    required int roomId,
    required String nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    int? totalCorrectAnswerMs,
    _iarmrzsm.PlayerStatus? status,
    int? eliminatedInRound,
    int? backedPlayerId,
    String? exitLine,
    DateTime? leftAt,
    DateTime? joinedAt,
  }) = _PlayerImpl;

  factory Player.fromJson(Map<String, dynamic> jsonSerialization) {
    return Player(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      nickname: jsonSerialization['nickname'] as String,
      score: jsonSerialization['score'] as int?,
      shadowScore: jsonSerialization['shadowScore'] as int?,
      finalScore: jsonSerialization['finalScore'] as int?,
      totalCorrectAnswerMs: jsonSerialization['totalCorrectAnswerMs'] as int?,
      status: jsonSerialization['status'] == null
          ? null
          : _iarmrzsm.PlayerStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      eliminatedInRound: jsonSerialization['eliminatedInRound'] as int?,
      backedPlayerId: jsonSerialization['backedPlayerId'] as int?,
      exitLine: jsonSerialization['exitLine'] as String?,
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String nickname;

  int score;

  int shadowScore;

  int finalScore;

  int totalCorrectAnswerMs;

  _iarmrzsm.PlayerStatus status;

  int? eliminatedInRound;

  int? backedPlayerId;

  /// The host's line when this player was cut (AI-written or built-in).
  String? exitLine;

  /// When they tapped Leave; null while in the game. Rejoining clears it.
  DateTime? leftAt;

  DateTime joinedAt;

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Player copyWith({
    int? id,
    int? roomId,
    String? nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    int? totalCorrectAnswerMs,
    _iarmrzsm.PlayerStatus? status,
    int? eliminatedInRound,
    int? backedPlayerId,
    String? exitLine,
    DateTime? leftAt,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id,
      'roomId': roomId,
      'nickname': nickname,
      'score': score,
      'shadowScore': shadowScore,
      'finalScore': finalScore,
      'totalCorrectAnswerMs': totalCorrectAnswerMs,
      'status': status.toJson(),
      if (eliminatedInRound != null) 'eliminatedInRound': eliminatedInRound,
      if (backedPlayerId != null) 'backedPlayerId': backedPlayerId,
      if (exitLine != null) 'exitLine': exitLine,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id,
      'roomId': roomId,
      'nickname': nickname,
      'score': score,
      'shadowScore': shadowScore,
      'finalScore': finalScore,
      'totalCorrectAnswerMs': totalCorrectAnswerMs,
      'status': status.toJson(),
      if (eliminatedInRound != null) 'eliminatedInRound': eliminatedInRound,
      if (backedPlayerId != null) 'backedPlayerId': backedPlayerId,
      if (exitLine != null) 'exitLine': exitLine,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerImpl extends Player {
  _PlayerImpl({
    int? id,
    required int roomId,
    required String nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    int? totalCorrectAnswerMs,
    _iarmrzsm.PlayerStatus? status,
    int? eliminatedInRound,
    int? backedPlayerId,
    String? exitLine,
    DateTime? leftAt,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         nickname: nickname,
         score: score,
         shadowScore: shadowScore,
         finalScore: finalScore,
         totalCorrectAnswerMs: totalCorrectAnswerMs,
         status: status,
         eliminatedInRound: eliminatedInRound,
         backedPlayerId: backedPlayerId,
         exitLine: exitLine,
         leftAt: leftAt,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Player copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? nickname,
    int? score,
    int? shadowScore,
    int? finalScore,
    int? totalCorrectAnswerMs,
    _iarmrzsm.PlayerStatus? status,
    Object? eliminatedInRound = _Undefined,
    Object? backedPlayerId = _Undefined,
    Object? exitLine = _Undefined,
    Object? leftAt = _Undefined,
    DateTime? joinedAt,
  }) {
    return Player(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
      shadowScore: shadowScore ?? this.shadowScore,
      finalScore: finalScore ?? this.finalScore,
      totalCorrectAnswerMs: totalCorrectAnswerMs ?? this.totalCorrectAnswerMs,
      status: status ?? this.status,
      eliminatedInRound: eliminatedInRound is int?
          ? eliminatedInRound
          : this.eliminatedInRound,
      backedPlayerId: backedPlayerId is int?
          ? backedPlayerId
          : this.backedPlayerId,
      exitLine: exitLine is String? ? exitLine : this.exitLine,
      leftAt: leftAt is DateTime? ? leftAt : this.leftAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

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
import 'package:quiz_night_client/src/protocol/protocol.dart' as _ibnz9izf;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'elimination_event.dart' as _i044r49r;
import 'elimination_rule.dart' as _ix1rmfwn;
import 'room_end_reason.dart' as _i1z47hfo;
import 'room_status.dart' as _ilj1at52;
import 'tiebreak_mode.dart' as _ixk2jfuv;

abstract class Room
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Room._({
    this.id,
    required this.code,
    _ilj1at52.RoomStatus? status,
    int? currentRound,
    int? currentQuestionIndex,
    this.currentQuestionId,
    required this.questionsPerRound,
    required this.eliminationRule,
    required this.eliminationPercent,
    required this.finalistTarget,
    required this.roundsBeforeFinal,
    required this.tiebreakMode,
    required this.finalQuestionCount,
    required this.timeLimitSeconds,
    bool? showQuestionOnPhones,
    bool? wildcardUsed,
    bool? locked,
    this.startingPlayerCount,
    this.questionStartedAt,
    this.questionEndsAt,
    int? lastCutRound,
    int? finalQuestionsPlayed,
    this.buzzerHolderId,
    this.lastElimination,
    DateTime? createdAt,
    this.startedAt,
    DateTime? lastActivityAt,
    this.endReason,
    this.packId,
  }) : status = status ?? _ilj1at52.RoomStatus.lobby,
       currentRound = currentRound ?? 0,
       currentQuestionIndex = currentQuestionIndex ?? 0,
       showQuestionOnPhones = showQuestionOnPhones ?? true,
       wildcardUsed = wildcardUsed ?? false,
       locked = locked ?? false,
       lastCutRound = lastCutRound ?? 0,
       finalQuestionsPlayed = finalQuestionsPlayed ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       lastActivityAt = lastActivityAt ?? DateTime.now();

  factory Room({
    int? id,
    required String code,
    _ilj1at52.RoomStatus? status,
    int? currentRound,
    int? currentQuestionIndex,
    int? currentQuestionId,
    required int questionsPerRound,
    required _ix1rmfwn.EliminationRule eliminationRule,
    required double eliminationPercent,
    required int finalistTarget,
    required int roundsBeforeFinal,
    required _ixk2jfuv.TiebreakMode tiebreakMode,
    required int finalQuestionCount,
    required int timeLimitSeconds,
    bool? showQuestionOnPhones,
    bool? wildcardUsed,
    bool? locked,
    int? startingPlayerCount,
    DateTime? questionStartedAt,
    DateTime? questionEndsAt,
    int? lastCutRound,
    int? finalQuestionsPlayed,
    int? buzzerHolderId,
    _i044r49r.EliminationEvent? lastElimination,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  }) = _RoomImpl;

  factory Room.fromJson(Map<String, dynamic> jsonSerialization) {
    return Room(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _ilj1at52.RoomStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      currentRound: jsonSerialization['currentRound'] as int?,
      currentQuestionIndex: jsonSerialization['currentQuestionIndex'] as int?,
      currentQuestionId: jsonSerialization['currentQuestionId'] as int?,
      questionsPerRound: jsonSerialization['questionsPerRound'] as int,
      eliminationRule: _ix1rmfwn.EliminationRule.fromJson(
        (jsonSerialization['eliminationRule'] as String),
      ),
      eliminationPercent: (jsonSerialization['eliminationPercent'] as num)
          .toDouble(),
      finalistTarget: jsonSerialization['finalistTarget'] as int,
      roundsBeforeFinal: jsonSerialization['roundsBeforeFinal'] as int,
      tiebreakMode: _ixk2jfuv.TiebreakMode.fromJson(
        (jsonSerialization['tiebreakMode'] as String),
      ),
      finalQuestionCount: jsonSerialization['finalQuestionCount'] as int,
      timeLimitSeconds: jsonSerialization['timeLimitSeconds'] as int,
      showQuestionOnPhones: jsonSerialization['showQuestionOnPhones'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['showQuestionOnPhones'],
            ),
      wildcardUsed: jsonSerialization['wildcardUsed'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['wildcardUsed']),
      locked: jsonSerialization['locked'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['locked']),
      startingPlayerCount: jsonSerialization['startingPlayerCount'] as int?,
      questionStartedAt: jsonSerialization['questionStartedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['questionStartedAt'],
            ),
      questionEndsAt: jsonSerialization['questionEndsAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['questionEndsAt'],
            ),
      lastCutRound: jsonSerialization['lastCutRound'] as int?,
      finalQuestionsPlayed: jsonSerialization['finalQuestionsPlayed'] as int?,
      buzzerHolderId: jsonSerialization['buzzerHolderId'] as int?,
      lastElimination: jsonSerialization['lastElimination'] == null
          ? null
          : _ibnz9izf.Protocol().deserialize<_i044r49r.EliminationEvent>(
              jsonSerialization['lastElimination'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      lastActivityAt: jsonSerialization['lastActivityAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastActivityAt'],
            ),
      endReason: jsonSerialization['endReason'] == null
          ? null
          : _i1z47hfo.RoomEndReason.fromJson(
              (jsonSerialization['endReason'] as String),
            ),
      packId: jsonSerialization['packId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String code;

  _ilj1at52.RoomStatus status;

  int currentRound;

  /// Index of the current question within the current round (1-based, 0 = none yet).
  int currentQuestionIndex;

  int? currentQuestionId;

  int questionsPerRound;

  _ix1rmfwn.EliminationRule eliminationRule;

  double eliminationPercent;

  int finalistTarget;

  int roundsBeforeFinal;

  _ixk2jfuv.TiebreakMode tiebreakMode;

  int finalQuestionCount;

  int timeLimitSeconds;

  bool showQuestionOnPhones;

  bool wildcardUsed;

  /// Host has closed the room to new players.
  bool locked;

  int? startingPlayerCount;

  DateTime? questionStartedAt;

  DateTime? questionEndsAt;

  /// Last round whose cut has been applied; makes endRound idempotent.
  int lastCutRound;

  int finalQuestionsPlayed;

  int? buzzerHolderId;

  _i044r49r.EliminationEvent? lastElimination;

  DateTime createdAt;

  /// When the host started the game; the 30-minute game clock runs from here.
  DateTime? startedAt;

  /// Last change in the room (a join, an answer, a host action). Rooms idle
  /// for 30 minutes are closed.
  DateTime lastActivityAt;

  /// Set when the game ends.
  _i1z47hfo.RoomEndReason? endReason;

  /// AI-written questions played before the built-in bank.
  int? packId;

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Room copyWith({
    int? id,
    String? code,
    _ilj1at52.RoomStatus? status,
    int? currentRound,
    int? currentQuestionIndex,
    int? currentQuestionId,
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    bool? wildcardUsed,
    bool? locked,
    int? startingPlayerCount,
    DateTime? questionStartedAt,
    DateTime? questionEndsAt,
    int? lastCutRound,
    int? finalQuestionsPlayed,
    int? buzzerHolderId,
    _i044r49r.EliminationEvent? lastElimination,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'code': code,
      'status': status.toJson(),
      'currentRound': currentRound,
      'currentQuestionIndex': currentQuestionIndex,
      if (currentQuestionId != null) 'currentQuestionId': currentQuestionId,
      'questionsPerRound': questionsPerRound,
      'eliminationRule': eliminationRule.toJson(),
      'eliminationPercent': eliminationPercent,
      'finalistTarget': finalistTarget,
      'roundsBeforeFinal': roundsBeforeFinal,
      'tiebreakMode': tiebreakMode.toJson(),
      'finalQuestionCount': finalQuestionCount,
      'timeLimitSeconds': timeLimitSeconds,
      'showQuestionOnPhones': showQuestionOnPhones,
      'wildcardUsed': wildcardUsed,
      'locked': locked,
      if (startingPlayerCount != null)
        'startingPlayerCount': startingPlayerCount,
      if (questionStartedAt != null)
        'questionStartedAt': questionStartedAt?.toJson(),
      if (questionEndsAt != null) 'questionEndsAt': questionEndsAt?.toJson(),
      'lastCutRound': lastCutRound,
      'finalQuestionsPlayed': finalQuestionsPlayed,
      if (buzzerHolderId != null) 'buzzerHolderId': buzzerHolderId,
      if (lastElimination != null) 'lastElimination': lastElimination?.toJson(),
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      'lastActivityAt': lastActivityAt.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
      if (packId != null) 'packId': packId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'code': code,
      'status': status.toJson(),
      'currentRound': currentRound,
      'currentQuestionIndex': currentQuestionIndex,
      if (currentQuestionId != null) 'currentQuestionId': currentQuestionId,
      'questionsPerRound': questionsPerRound,
      'eliminationRule': eliminationRule.toJson(),
      'eliminationPercent': eliminationPercent,
      'finalistTarget': finalistTarget,
      'roundsBeforeFinal': roundsBeforeFinal,
      'tiebreakMode': tiebreakMode.toJson(),
      'finalQuestionCount': finalQuestionCount,
      'timeLimitSeconds': timeLimitSeconds,
      'showQuestionOnPhones': showQuestionOnPhones,
      'wildcardUsed': wildcardUsed,
      'locked': locked,
      if (startingPlayerCount != null)
        'startingPlayerCount': startingPlayerCount,
      if (questionStartedAt != null)
        'questionStartedAt': questionStartedAt?.toJson(),
      if (questionEndsAt != null) 'questionEndsAt': questionEndsAt?.toJson(),
      'lastCutRound': lastCutRound,
      'finalQuestionsPlayed': finalQuestionsPlayed,
      if (buzzerHolderId != null) 'buzzerHolderId': buzzerHolderId,
      if (lastElimination != null)
        'lastElimination': lastElimination?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      'lastActivityAt': lastActivityAt.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
      if (packId != null) 'packId': packId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomImpl extends Room {
  _RoomImpl({
    int? id,
    required String code,
    _ilj1at52.RoomStatus? status,
    int? currentRound,
    int? currentQuestionIndex,
    int? currentQuestionId,
    required int questionsPerRound,
    required _ix1rmfwn.EliminationRule eliminationRule,
    required double eliminationPercent,
    required int finalistTarget,
    required int roundsBeforeFinal,
    required _ixk2jfuv.TiebreakMode tiebreakMode,
    required int finalQuestionCount,
    required int timeLimitSeconds,
    bool? showQuestionOnPhones,
    bool? wildcardUsed,
    bool? locked,
    int? startingPlayerCount,
    DateTime? questionStartedAt,
    DateTime? questionEndsAt,
    int? lastCutRound,
    int? finalQuestionsPlayed,
    int? buzzerHolderId,
    _i044r49r.EliminationEvent? lastElimination,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  }) : super._(
         id: id,
         code: code,
         status: status,
         currentRound: currentRound,
         currentQuestionIndex: currentQuestionIndex,
         currentQuestionId: currentQuestionId,
         questionsPerRound: questionsPerRound,
         eliminationRule: eliminationRule,
         eliminationPercent: eliminationPercent,
         finalistTarget: finalistTarget,
         roundsBeforeFinal: roundsBeforeFinal,
         tiebreakMode: tiebreakMode,
         finalQuestionCount: finalQuestionCount,
         timeLimitSeconds: timeLimitSeconds,
         showQuestionOnPhones: showQuestionOnPhones,
         wildcardUsed: wildcardUsed,
         locked: locked,
         startingPlayerCount: startingPlayerCount,
         questionStartedAt: questionStartedAt,
         questionEndsAt: questionEndsAt,
         lastCutRound: lastCutRound,
         finalQuestionsPlayed: finalQuestionsPlayed,
         buzzerHolderId: buzzerHolderId,
         lastElimination: lastElimination,
         createdAt: createdAt,
         startedAt: startedAt,
         lastActivityAt: lastActivityAt,
         endReason: endReason,
         packId: packId,
       );

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Room copyWith({
    Object? id = _Undefined,
    String? code,
    _ilj1at52.RoomStatus? status,
    int? currentRound,
    int? currentQuestionIndex,
    Object? currentQuestionId = _Undefined,
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    bool? wildcardUsed,
    bool? locked,
    Object? startingPlayerCount = _Undefined,
    Object? questionStartedAt = _Undefined,
    Object? questionEndsAt = _Undefined,
    int? lastCutRound,
    int? finalQuestionsPlayed,
    Object? buzzerHolderId = _Undefined,
    Object? lastElimination = _Undefined,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    DateTime? lastActivityAt,
    Object? endReason = _Undefined,
    Object? packId = _Undefined,
  }) {
    return Room(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentQuestionId: currentQuestionId is int?
          ? currentQuestionId
          : this.currentQuestionId,
      questionsPerRound: questionsPerRound ?? this.questionsPerRound,
      eliminationRule: eliminationRule ?? this.eliminationRule,
      eliminationPercent: eliminationPercent ?? this.eliminationPercent,
      finalistTarget: finalistTarget ?? this.finalistTarget,
      roundsBeforeFinal: roundsBeforeFinal ?? this.roundsBeforeFinal,
      tiebreakMode: tiebreakMode ?? this.tiebreakMode,
      finalQuestionCount: finalQuestionCount ?? this.finalQuestionCount,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      showQuestionOnPhones: showQuestionOnPhones ?? this.showQuestionOnPhones,
      wildcardUsed: wildcardUsed ?? this.wildcardUsed,
      locked: locked ?? this.locked,
      startingPlayerCount: startingPlayerCount is int?
          ? startingPlayerCount
          : this.startingPlayerCount,
      questionStartedAt: questionStartedAt is DateTime?
          ? questionStartedAt
          : this.questionStartedAt,
      questionEndsAt: questionEndsAt is DateTime?
          ? questionEndsAt
          : this.questionEndsAt,
      lastCutRound: lastCutRound ?? this.lastCutRound,
      finalQuestionsPlayed: finalQuestionsPlayed ?? this.finalQuestionsPlayed,
      buzzerHolderId: buzzerHolderId is int?
          ? buzzerHolderId
          : this.buzzerHolderId,
      lastElimination: lastElimination is _i044r49r.EliminationEvent?
          ? lastElimination
          : this.lastElimination?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      endReason: endReason is _i1z47hfo.RoomEndReason?
          ? endReason
          : this.endReason,
      packId: packId is int? ? packId : this.packId,
    );
  }
}

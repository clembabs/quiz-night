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
import 'package:quiz_night_server/src/generated/protocol.dart' as _izn0xfae;
import 'package:serverpod/serverpod.dart' as _is;
import 'elimination_event.dart' as _i044r49r;
import 'elimination_rule.dart' as _ix1rmfwn;
import 'player_view.dart' as _ijz1mobl;
import 'question_view.dart' as _irhyxwad;
import 'room_status.dart' as _ilj1at52;

/// Snapshot pushed to every client in a room.
abstract class RoomState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RoomState._({
    required this.code,
    required this.status,
    required this.round,
    required this.questionsPerRound,
    required this.finalistTarget,
    required this.finalQuestionCount,
    required this.finalQuestionsPlayed,
    required this.eliminationRule,
    required this.wildcardUsed,
    this.question,
    this.questionEndsAt,
    required this.serverTime,
    required this.players,
    this.lastElimination,
    this.buzzerHolderId,
    this.buzzWinnerId,
  });

  factory RoomState({
    required String code,
    required _ilj1at52.RoomStatus status,
    required int round,
    required int questionsPerRound,
    required int finalistTarget,
    required int finalQuestionCount,
    required int finalQuestionsPlayed,
    required _ix1rmfwn.EliminationRule eliminationRule,
    required bool wildcardUsed,
    _irhyxwad.QuestionView? question,
    DateTime? questionEndsAt,
    required DateTime serverTime,
    required List<_ijz1mobl.PlayerView> players,
    _i044r49r.EliminationEvent? lastElimination,
    int? buzzerHolderId,
    int? buzzWinnerId,
  }) = _RoomStateImpl;

  factory RoomState.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomState(
      code: jsonSerialization['code'] as String,
      status: _ilj1at52.RoomStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      round: jsonSerialization['round'] as int,
      questionsPerRound: jsonSerialization['questionsPerRound'] as int,
      finalistTarget: jsonSerialization['finalistTarget'] as int,
      finalQuestionCount: jsonSerialization['finalQuestionCount'] as int,
      finalQuestionsPlayed: jsonSerialization['finalQuestionsPlayed'] as int,
      eliminationRule: _ix1rmfwn.EliminationRule.fromJson(
        (jsonSerialization['eliminationRule'] as String),
      ),
      wildcardUsed: _is.BoolJsonExtension.fromJson(
        jsonSerialization['wildcardUsed'],
      ),
      question: jsonSerialization['question'] == null
          ? null
          : _izn0xfae.Protocol().deserialize<_irhyxwad.QuestionView>(
              jsonSerialization['question'],
            ),
      questionEndsAt: jsonSerialization['questionEndsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['questionEndsAt'],
            ),
      serverTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
      players: _izn0xfae.Protocol().deserialize<List<_ijz1mobl.PlayerView>>(
        jsonSerialization['players'],
      ),
      lastElimination: jsonSerialization['lastElimination'] == null
          ? null
          : _izn0xfae.Protocol().deserialize<_i044r49r.EliminationEvent>(
              jsonSerialization['lastElimination'],
            ),
      buzzerHolderId: jsonSerialization['buzzerHolderId'] as int?,
      buzzWinnerId: jsonSerialization['buzzWinnerId'] as int?,
    );
  }

  String code;

  _ilj1at52.RoomStatus status;

  int round;

  int questionsPerRound;

  int finalistTarget;

  int finalQuestionCount;

  int finalQuestionsPlayed;

  _ix1rmfwn.EliminationRule eliminationRule;

  bool wildcardUsed;

  _irhyxwad.QuestionView? question;

  DateTime? questionEndsAt;

  DateTime serverTime;

  List<_ijz1mobl.PlayerView> players;

  _i044r49r.EliminationEvent? lastElimination;

  int? buzzerHolderId;

  /// Finalist who answered the current final question correctly, if any.
  int? buzzWinnerId;

  /// Returns a shallow copy of this [RoomState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoomState copyWith({
    String? code,
    _ilj1at52.RoomStatus? status,
    int? round,
    int? questionsPerRound,
    int? finalistTarget,
    int? finalQuestionCount,
    int? finalQuestionsPlayed,
    _ix1rmfwn.EliminationRule? eliminationRule,
    bool? wildcardUsed,
    _irhyxwad.QuestionView? question,
    DateTime? questionEndsAt,
    DateTime? serverTime,
    List<_ijz1mobl.PlayerView>? players,
    _i044r49r.EliminationEvent? lastElimination,
    int? buzzerHolderId,
    int? buzzWinnerId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomState',
      'code': code,
      'status': status.toJson(),
      'round': round,
      'questionsPerRound': questionsPerRound,
      'finalistTarget': finalistTarget,
      'finalQuestionCount': finalQuestionCount,
      'finalQuestionsPlayed': finalQuestionsPlayed,
      'eliminationRule': eliminationRule.toJson(),
      'wildcardUsed': wildcardUsed,
      if (question != null) 'question': question?.toJson(),
      if (questionEndsAt != null) 'questionEndsAt': questionEndsAt?.toJson(),
      'serverTime': serverTime.toJson(),
      'players': players.toJson(valueToJson: (v) => v.toJson()),
      if (lastElimination != null) 'lastElimination': lastElimination?.toJson(),
      if (buzzerHolderId != null) 'buzzerHolderId': buzzerHolderId,
      if (buzzWinnerId != null) 'buzzWinnerId': buzzWinnerId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomState',
      'code': code,
      'status': status.toJson(),
      'round': round,
      'questionsPerRound': questionsPerRound,
      'finalistTarget': finalistTarget,
      'finalQuestionCount': finalQuestionCount,
      'finalQuestionsPlayed': finalQuestionsPlayed,
      'eliminationRule': eliminationRule.toJson(),
      'wildcardUsed': wildcardUsed,
      if (question != null) 'question': question?.toJsonForProtocol(),
      if (questionEndsAt != null) 'questionEndsAt': questionEndsAt?.toJson(),
      'serverTime': serverTime.toJson(),
      'players': players.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (lastElimination != null)
        'lastElimination': lastElimination?.toJsonForProtocol(),
      if (buzzerHolderId != null) 'buzzerHolderId': buzzerHolderId,
      if (buzzWinnerId != null) 'buzzWinnerId': buzzWinnerId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomStateImpl extends RoomState {
  _RoomStateImpl({
    required String code,
    required _ilj1at52.RoomStatus status,
    required int round,
    required int questionsPerRound,
    required int finalistTarget,
    required int finalQuestionCount,
    required int finalQuestionsPlayed,
    required _ix1rmfwn.EliminationRule eliminationRule,
    required bool wildcardUsed,
    _irhyxwad.QuestionView? question,
    DateTime? questionEndsAt,
    required DateTime serverTime,
    required List<_ijz1mobl.PlayerView> players,
    _i044r49r.EliminationEvent? lastElimination,
    int? buzzerHolderId,
    int? buzzWinnerId,
  }) : super._(
         code: code,
         status: status,
         round: round,
         questionsPerRound: questionsPerRound,
         finalistTarget: finalistTarget,
         finalQuestionCount: finalQuestionCount,
         finalQuestionsPlayed: finalQuestionsPlayed,
         eliminationRule: eliminationRule,
         wildcardUsed: wildcardUsed,
         question: question,
         questionEndsAt: questionEndsAt,
         serverTime: serverTime,
         players: players,
         lastElimination: lastElimination,
         buzzerHolderId: buzzerHolderId,
         buzzWinnerId: buzzWinnerId,
       );

  /// Returns a shallow copy of this [RoomState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoomState copyWith({
    String? code,
    _ilj1at52.RoomStatus? status,
    int? round,
    int? questionsPerRound,
    int? finalistTarget,
    int? finalQuestionCount,
    int? finalQuestionsPlayed,
    _ix1rmfwn.EliminationRule? eliminationRule,
    bool? wildcardUsed,
    Object? question = _Undefined,
    Object? questionEndsAt = _Undefined,
    DateTime? serverTime,
    List<_ijz1mobl.PlayerView>? players,
    Object? lastElimination = _Undefined,
    Object? buzzerHolderId = _Undefined,
    Object? buzzWinnerId = _Undefined,
  }) {
    return RoomState(
      code: code ?? this.code,
      status: status ?? this.status,
      round: round ?? this.round,
      questionsPerRound: questionsPerRound ?? this.questionsPerRound,
      finalistTarget: finalistTarget ?? this.finalistTarget,
      finalQuestionCount: finalQuestionCount ?? this.finalQuestionCount,
      finalQuestionsPlayed: finalQuestionsPlayed ?? this.finalQuestionsPlayed,
      eliminationRule: eliminationRule ?? this.eliminationRule,
      wildcardUsed: wildcardUsed ?? this.wildcardUsed,
      question: question is _irhyxwad.QuestionView?
          ? question
          : this.question?.copyWith(),
      questionEndsAt: questionEndsAt is DateTime?
          ? questionEndsAt
          : this.questionEndsAt,
      serverTime: serverTime ?? this.serverTime,
      players: players ?? this.players.map((e0) => e0.copyWith()).toList(),
      lastElimination: lastElimination is _i044r49r.EliminationEvent?
          ? lastElimination
          : this.lastElimination?.copyWith(),
      buzzerHolderId: buzzerHolderId is int?
          ? buzzerHolderId
          : this.buzzerHolderId,
      buzzWinnerId: buzzWinnerId is int? ? buzzWinnerId : this.buzzWinnerId,
    );
  }
}

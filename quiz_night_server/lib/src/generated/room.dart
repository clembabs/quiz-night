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
import 'room_end_reason.dart' as _i1z47hfo;
import 'room_status.dart' as _ilj1at52;
import 'tiebreak_mode.dart' as _ixk2jfuv;

abstract class Room implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Room._({
    this.id,
    required this.code,
    this.hostToken,
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
    bool? remote,
    bool? lockOnStart,
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
    this.hostAwaySince,
    this.endReason,
    this.packId,
  }) : status = status ?? _ilj1at52.RoomStatus.lobby,
       currentRound = currentRound ?? 0,
       currentQuestionIndex = currentQuestionIndex ?? 0,
       showQuestionOnPhones = showQuestionOnPhones ?? true,
       remote = remote ?? false,
       lockOnStart = lockOnStart ?? false,
       wildcardUsed = wildcardUsed ?? false,
       locked = locked ?? false,
       lastCutRound = lastCutRound ?? 0,
       finalQuestionsPlayed = finalQuestionsPlayed ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       lastActivityAt = lastActivityAt ?? DateTime.now();

  factory Room({
    int? id,
    required String code,
    String? hostToken,
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
    bool? remote,
    bool? lockOnStart,
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
    DateTime? hostAwaySince,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  }) = _RoomImpl;

  factory Room.fromJson(Map<String, dynamic> jsonSerialization) {
    return Room(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      hostToken: jsonSerialization['hostToken'] as String?,
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
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['showQuestionOnPhones'],
            ),
      remote: jsonSerialization['remote'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['remote']),
      lockOnStart: jsonSerialization['lockOnStart'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['lockOnStart']),
      wildcardUsed: jsonSerialization['wildcardUsed'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['wildcardUsed']),
      locked: jsonSerialization['locked'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['locked']),
      startingPlayerCount: jsonSerialization['startingPlayerCount'] as int?,
      questionStartedAt: jsonSerialization['questionStartedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['questionStartedAt'],
            ),
      questionEndsAt: jsonSerialization['questionEndsAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['questionEndsAt'],
            ),
      lastCutRound: jsonSerialization['lastCutRound'] as int?,
      finalQuestionsPlayed: jsonSerialization['finalQuestionsPlayed'] as int?,
      buzzerHolderId: jsonSerialization['buzzerHolderId'] as int?,
      lastElimination: jsonSerialization['lastElimination'] == null
          ? null
          : _izn0xfae.Protocol().deserialize<_i044r49r.EliminationEvent>(
              jsonSerialization['lastElimination'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      lastActivityAt: jsonSerialization['lastActivityAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastActivityAt'],
            ),
      hostAwaySince: jsonSerialization['hostAwaySince'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['hostAwaySince'],
            ),
      endReason: jsonSerialization['endReason'] == null
          ? null
          : _i1z47hfo.RoomEndReason.fromJson(
              (jsonSerialization['endReason'] as String),
            ),
      packId: jsonSerialization['packId'] as int?,
    );
  }

  static final t = RoomTable();

  static const db = RoomRepository._();

  @override
  int? id;

  String code;

  String? hostToken;

  _ilj1at52.RoomStatus status;

  int currentRound;

  /// Question index within the round (1-based; 0 = none yet).
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

  /// Players join from wherever they are; phones show the whole game.
  bool remote;

  /// Lock to new players when the host presses Start.
  bool lockOnStart;

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

  /// Last change (join, answer, host action); rooms idle 30 minutes close.
  DateTime lastActivityAt;

  /// When the host's last screen disconnected; null while one is connected.
  DateTime? hostAwaySince;

  /// Set when the game ends.
  _i1z47hfo.RoomEndReason? endReason;

  /// AI-written questions played before the built-in bank.
  int? packId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Room copyWith({
    int? id,
    String? code,
    String? hostToken,
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
    bool? remote,
    bool? lockOnStart,
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
    DateTime? hostAwaySince,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'code': code,
      if (hostToken != null) 'hostToken': hostToken,
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
      'remote': remote,
      'lockOnStart': lockOnStart,
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
      if (hostAwaySince != null) 'hostAwaySince': hostAwaySince?.toJson(),
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
      'remote': remote,
      'lockOnStart': lockOnStart,
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
      if (hostAwaySince != null) 'hostAwaySince': hostAwaySince?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
      if (packId != null) 'packId': packId,
    };
  }

  static RoomInclude include() {
    return RoomInclude._();
  }

  static RoomIncludeList includeList({
    _is.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    RoomInclude? include,
  }) {
    return RoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomImpl extends Room {
  _RoomImpl({
    int? id,
    required String code,
    String? hostToken,
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
    bool? remote,
    bool? lockOnStart,
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
    DateTime? hostAwaySince,
    _i1z47hfo.RoomEndReason? endReason,
    int? packId,
  }) : super._(
         id: id,
         code: code,
         hostToken: hostToken,
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
         remote: remote,
         lockOnStart: lockOnStart,
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
         hostAwaySince: hostAwaySince,
         endReason: endReason,
         packId: packId,
       );

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Room copyWith({
    Object? id = _Undefined,
    String? code,
    Object? hostToken = _Undefined,
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
    bool? remote,
    bool? lockOnStart,
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
    Object? hostAwaySince = _Undefined,
    Object? endReason = _Undefined,
    Object? packId = _Undefined,
  }) {
    return Room(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      hostToken: hostToken is String? ? hostToken : this.hostToken,
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
      remote: remote ?? this.remote,
      lockOnStart: lockOnStart ?? this.lockOnStart,
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
      hostAwaySince: hostAwaySince is DateTime?
          ? hostAwaySince
          : this.hostAwaySince,
      endReason: endReason is _i1z47hfo.RoomEndReason?
          ? endReason
          : this.endReason,
      packId: packId is int? ? packId : this.packId,
    );
  }
}

class RoomUpdateTable extends _is.UpdateTable<RoomTable> {
  RoomUpdateTable(super.table);

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<String, String> hostToken(String? value) => _is.ColumnValue(
    table.hostToken,
    value,
  );

  _is.ColumnValue<_ilj1at52.RoomStatus, _ilj1at52.RoomStatus> status(
    _ilj1at52.RoomStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> currentRound(int value) => _is.ColumnValue(
    table.currentRound,
    value,
  );

  _is.ColumnValue<int, int> currentQuestionIndex(int value) => _is.ColumnValue(
    table.currentQuestionIndex,
    value,
  );

  _is.ColumnValue<int, int> currentQuestionId(int? value) => _is.ColumnValue(
    table.currentQuestionId,
    value,
  );

  _is.ColumnValue<int, int> questionsPerRound(int value) => _is.ColumnValue(
    table.questionsPerRound,
    value,
  );

  _is.ColumnValue<_ix1rmfwn.EliminationRule, _ix1rmfwn.EliminationRule>
  eliminationRule(_ix1rmfwn.EliminationRule value) => _is.ColumnValue(
    table.eliminationRule,
    value,
  );

  _is.ColumnValue<double, double> eliminationPercent(double value) =>
      _is.ColumnValue(
        table.eliminationPercent,
        value,
      );

  _is.ColumnValue<int, int> finalistTarget(int value) => _is.ColumnValue(
    table.finalistTarget,
    value,
  );

  _is.ColumnValue<int, int> roundsBeforeFinal(int value) => _is.ColumnValue(
    table.roundsBeforeFinal,
    value,
  );

  _is.ColumnValue<_ixk2jfuv.TiebreakMode, _ixk2jfuv.TiebreakMode> tiebreakMode(
    _ixk2jfuv.TiebreakMode value,
  ) => _is.ColumnValue(
    table.tiebreakMode,
    value,
  );

  _is.ColumnValue<int, int> finalQuestionCount(int value) => _is.ColumnValue(
    table.finalQuestionCount,
    value,
  );

  _is.ColumnValue<int, int> timeLimitSeconds(int value) => _is.ColumnValue(
    table.timeLimitSeconds,
    value,
  );

  _is.ColumnValue<bool, bool> showQuestionOnPhones(bool value) =>
      _is.ColumnValue(
        table.showQuestionOnPhones,
        value,
      );

  _is.ColumnValue<bool, bool> remote(bool value) => _is.ColumnValue(
    table.remote,
    value,
  );

  _is.ColumnValue<bool, bool> lockOnStart(bool value) => _is.ColumnValue(
    table.lockOnStart,
    value,
  );

  _is.ColumnValue<bool, bool> wildcardUsed(bool value) => _is.ColumnValue(
    table.wildcardUsed,
    value,
  );

  _is.ColumnValue<bool, bool> locked(bool value) => _is.ColumnValue(
    table.locked,
    value,
  );

  _is.ColumnValue<int, int> startingPlayerCount(int? value) => _is.ColumnValue(
    table.startingPlayerCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> questionStartedAt(DateTime? value) =>
      _is.ColumnValue(
        table.questionStartedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> questionEndsAt(DateTime? value) =>
      _is.ColumnValue(
        table.questionEndsAt,
        value,
      );

  _is.ColumnValue<int, int> lastCutRound(int value) => _is.ColumnValue(
    table.lastCutRound,
    value,
  );

  _is.ColumnValue<int, int> finalQuestionsPlayed(int value) => _is.ColumnValue(
    table.finalQuestionsPlayed,
    value,
  );

  _is.ColumnValue<int, int> buzzerHolderId(int? value) => _is.ColumnValue(
    table.buzzerHolderId,
    value,
  );

  _is.ColumnValue<_i044r49r.EliminationEvent, _i044r49r.EliminationEvent>
  lastElimination(_i044r49r.EliminationEvent? value) => _is.ColumnValue(
    table.lastElimination,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> startedAt(DateTime? value) =>
      _is.ColumnValue(
        table.startedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastActivityAt(DateTime value) =>
      _is.ColumnValue(
        table.lastActivityAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> hostAwaySince(DateTime? value) =>
      _is.ColumnValue(
        table.hostAwaySince,
        value,
      );

  _is.ColumnValue<_i1z47hfo.RoomEndReason, _i1z47hfo.RoomEndReason> endReason(
    _i1z47hfo.RoomEndReason? value,
  ) => _is.ColumnValue(
    table.endReason,
    value,
  );

  _is.ColumnValue<int, int> packId(int? value) => _is.ColumnValue(
    table.packId,
    value,
  );
}

class RoomTable extends _is.Table<int?> {
  RoomTable({super.tableRelation}) : super(tableName: 'room') {
    updateTable = RoomUpdateTable(this);
    code = _is.ColumnString(
      'code',
      this,
    );
    hostToken = _is.ColumnString(
      'hostToken',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    currentRound = _is.ColumnInt(
      'currentRound',
      this,
      hasDefault: true,
    );
    currentQuestionIndex = _is.ColumnInt(
      'currentQuestionIndex',
      this,
      hasDefault: true,
    );
    currentQuestionId = _is.ColumnInt(
      'currentQuestionId',
      this,
    );
    questionsPerRound = _is.ColumnInt(
      'questionsPerRound',
      this,
    );
    eliminationRule = _is.ColumnEnum(
      'eliminationRule',
      this,
      _is.EnumSerialization.byName,
    );
    eliminationPercent = _is.ColumnDouble(
      'eliminationPercent',
      this,
    );
    finalistTarget = _is.ColumnInt(
      'finalistTarget',
      this,
    );
    roundsBeforeFinal = _is.ColumnInt(
      'roundsBeforeFinal',
      this,
    );
    tiebreakMode = _is.ColumnEnum(
      'tiebreakMode',
      this,
      _is.EnumSerialization.byName,
    );
    finalQuestionCount = _is.ColumnInt(
      'finalQuestionCount',
      this,
    );
    timeLimitSeconds = _is.ColumnInt(
      'timeLimitSeconds',
      this,
    );
    showQuestionOnPhones = _is.ColumnBool(
      'showQuestionOnPhones',
      this,
      hasDefault: true,
    );
    remote = _is.ColumnBool(
      'remote',
      this,
      hasDefault: true,
    );
    lockOnStart = _is.ColumnBool(
      'lockOnStart',
      this,
      hasDefault: true,
    );
    wildcardUsed = _is.ColumnBool(
      'wildcardUsed',
      this,
      hasDefault: true,
    );
    locked = _is.ColumnBool(
      'locked',
      this,
      hasDefault: true,
    );
    startingPlayerCount = _is.ColumnInt(
      'startingPlayerCount',
      this,
    );
    questionStartedAt = _is.ColumnDateTime(
      'questionStartedAt',
      this,
    );
    questionEndsAt = _is.ColumnDateTime(
      'questionEndsAt',
      this,
    );
    lastCutRound = _is.ColumnInt(
      'lastCutRound',
      this,
      hasDefault: true,
    );
    finalQuestionsPlayed = _is.ColumnInt(
      'finalQuestionsPlayed',
      this,
      hasDefault: true,
    );
    buzzerHolderId = _is.ColumnInt(
      'buzzerHolderId',
      this,
    );
    lastElimination = _is.ColumnSerializable<_i044r49r.EliminationEvent>(
      'lastElimination',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    startedAt = _is.ColumnDateTime(
      'startedAt',
      this,
    );
    lastActivityAt = _is.ColumnDateTime(
      'lastActivityAt',
      this,
      hasDefault: true,
    );
    hostAwaySince = _is.ColumnDateTime(
      'hostAwaySince',
      this,
    );
    endReason = _is.ColumnEnum(
      'endReason',
      this,
      _is.EnumSerialization.byName,
    );
    packId = _is.ColumnInt(
      'packId',
      this,
    );
  }

  late final RoomUpdateTable updateTable;

  late final _is.ColumnString code;

  late final _is.ColumnString hostToken;

  late final _is.ColumnEnum<_ilj1at52.RoomStatus> status;

  late final _is.ColumnInt currentRound;

  /// Question index within the round (1-based; 0 = none yet).
  late final _is.ColumnInt currentQuestionIndex;

  late final _is.ColumnInt currentQuestionId;

  late final _is.ColumnInt questionsPerRound;

  late final _is.ColumnEnum<_ix1rmfwn.EliminationRule> eliminationRule;

  late final _is.ColumnDouble eliminationPercent;

  late final _is.ColumnInt finalistTarget;

  late final _is.ColumnInt roundsBeforeFinal;

  late final _is.ColumnEnum<_ixk2jfuv.TiebreakMode> tiebreakMode;

  late final _is.ColumnInt finalQuestionCount;

  late final _is.ColumnInt timeLimitSeconds;

  late final _is.ColumnBool showQuestionOnPhones;

  /// Players join from wherever they are; phones show the whole game.
  late final _is.ColumnBool remote;

  /// Lock to new players when the host presses Start.
  late final _is.ColumnBool lockOnStart;

  late final _is.ColumnBool wildcardUsed;

  /// Host has closed the room to new players.
  late final _is.ColumnBool locked;

  late final _is.ColumnInt startingPlayerCount;

  late final _is.ColumnDateTime questionStartedAt;

  late final _is.ColumnDateTime questionEndsAt;

  /// Last round whose cut has been applied; makes endRound idempotent.
  late final _is.ColumnInt lastCutRound;

  late final _is.ColumnInt finalQuestionsPlayed;

  late final _is.ColumnInt buzzerHolderId;

  late final _is.ColumnSerializable<_i044r49r.EliminationEvent> lastElimination;

  late final _is.ColumnDateTime createdAt;

  /// When the host started the game; the 30-minute game clock runs from here.
  late final _is.ColumnDateTime startedAt;

  /// Last change (join, answer, host action); rooms idle 30 minutes close.
  late final _is.ColumnDateTime lastActivityAt;

  /// When the host's last screen disconnected; null while one is connected.
  late final _is.ColumnDateTime hostAwaySince;

  /// Set when the game ends.
  late final _is.ColumnEnum<_i1z47hfo.RoomEndReason> endReason;

  /// AI-written questions played before the built-in bank.
  late final _is.ColumnInt packId;

  @override
  List<_is.Column> get columns => [
    id,
    code,
    hostToken,
    status,
    currentRound,
    currentQuestionIndex,
    currentQuestionId,
    questionsPerRound,
    eliminationRule,
    eliminationPercent,
    finalistTarget,
    roundsBeforeFinal,
    tiebreakMode,
    finalQuestionCount,
    timeLimitSeconds,
    showQuestionOnPhones,
    remote,
    lockOnStart,
    wildcardUsed,
    locked,
    startingPlayerCount,
    questionStartedAt,
    questionEndsAt,
    lastCutRound,
    finalQuestionsPlayed,
    buzzerHolderId,
    lastElimination,
    createdAt,
    startedAt,
    lastActivityAt,
    hostAwaySince,
    endReason,
    packId,
  ];
}

class RoomInclude extends _is.IncludeObject {
  RoomInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Room.t;
}

class RoomIncludeList extends _is.IncludeList {
  RoomIncludeList._({
    _is.WhereExpressionBuilder<RoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Room.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Room.t;
}

class RoomRepository {
  const RoomRepository._();

  /// Returns a list of [Room]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Room>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Room>(
      where: where?.call(Room.t),
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Room] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Room?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTable>? where,
    int? offset,
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Room>(
      where: where?.call(Room.t),
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Room] by its [id] or null if no such row exists.
  Future<Room?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Room>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Room]s in the list and returns the inserted rows.
  ///
  /// The returned [Room]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> insert(
    _is.DatabaseSession session,
    List<Room> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Room>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Room] and returns the inserted row.
  ///
  /// The returned [Room] will have its `id` field set.
  Future<Room> insertRow(
    _is.DatabaseSession session,
    Room row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Room>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Room]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Room]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> upsert(
    _is.DatabaseSession session,
    List<Room> rows, {
    required _is.ColumnSelections<RoomTable> conflictColumns,
    _is.ColumnSelections<RoomTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Room>(
      rows,
      conflictColumns: conflictColumns(Room.t),
      updateColumns: updateColumns?.call(Room.t),
      updateWhere: updateWhere?.call(Room.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Room] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Room] will have its `id` field set.
  Future<Room?> upsertRow(
    _is.DatabaseSession session,
    Room row, {
    required _is.ColumnSelections<RoomTable> conflictColumns,
    _is.ColumnSelections<RoomTable>? updateColumns,
    _is.WhereExpressionBuilder<RoomTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Room>(
      row,
      conflictColumns: conflictColumns(Room.t),
      updateColumns: updateColumns?.call(Room.t),
      updateWhere: updateWhere?.call(Room.t),
      transaction: transaction,
    );
  }

  /// Updates all [Room]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> update(
    _is.DatabaseSession session,
    List<Room> rows, {
    _is.ColumnSelections<RoomTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Room>(
      rows,
      columns: columns?.call(Room.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Room]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Room> updateRow(
    _is.DatabaseSession session,
    Room row, {
    _is.ColumnSelections<RoomTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Room>(
      row,
      columns: columns?.call(Room.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Room] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Room?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RoomUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Room>(
      id,
      columnValues: columnValues(Room.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Room]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RoomUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<RoomTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Room>(
      columnValues: columnValues(Room.t.updateTable),
      where: where(Room.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Room]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> delete(
    _is.DatabaseSession session,
    List<Room> rows, {
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Room>(
      rows,
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Room].
  Future<Room> deleteRow(
    _is.DatabaseSession session,
    Room row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Room>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Room>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomTable> where,
    _is.OrderByBuilder<RoomTable>? orderBy,
    _is.OrderByListBuilder<RoomTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Room>(
      where: where(Room.t),
      orderBy: orderBy?.call(Room.t),
      orderByList: orderByList?.call(Room.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RoomTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Room>(
      where: where?.call(Room.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Room] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RoomTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Room>(
      where: where(Room.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

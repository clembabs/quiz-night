/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'answer.dart' as _i6pk958y;
import 'answer_result.dart' as _irbcmcg9;
import 'buzz.dart' as _izgfeu3b;
import 'buzz_result.dart' as _iofgdbfb;
import 'create_room_result.dart' as _imz5iufx;
import 'elimination_event.dart' as _i044r49r;
import 'elimination_rule.dart' as _ix1rmfwn;
import 'join_result.dart' as _irdkvnmr;
import 'player.dart' as _imuqra0a;
import 'player_status.dart' as _iarmrzsm;
import 'player_view.dart' as _ijz1mobl;
import 'question.dart' as _in6mynjk;
import 'question_view.dart' as _irhyxwad;
import 'quiz_error_code.dart' as _ig7vrbjo;
import 'quiz_exception.dart' as _izdirdeu;
import 'room.dart' as _ieflxecy;
import 'room_config.dart' as _iwzadpd6;
import 'room_state.dart' as _i1uzd9w7;
import 'room_status.dart' as _ilj1at52;
import 'tiebreak_mode.dart' as _ixk2jfuv;
export 'answer.dart';
export 'answer_result.dart';
export 'buzz.dart';
export 'buzz_result.dart';
export 'create_room_result.dart';
export 'elimination_event.dart';
export 'elimination_rule.dart';
export 'join_result.dart';
export 'player.dart';
export 'player_status.dart';
export 'player_view.dart';
export 'question.dart';
export 'question_view.dart';
export 'quiz_error_code.dart';
export 'quiz_exception.dart';
export 'room.dart';
export 'room_config.dart';
export 'room_state.dart';
export 'room_status.dart';
export 'tiebreak_mode.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'answer',
      dartName: 'Answer',
      schema: 'public',
      module: 'quiz_night',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'playerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'questionId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'choiceIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'answeredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'elapsedMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'isCorrect',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'pointsAwarded',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'isShadow',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'answer_fk_0',
          columns: ['playerId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'answer_fk_1',
          columns: ['questionId'],
          referenceTable: 'question',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'answer_player_question_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'playerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'answer_question_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'buzz',
      dartName: 'Buzz',
      schema: 'public',
      module: 'quiz_night',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'playerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'questionId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'buzzedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'wasCorrect',
          columnType: _isp.ColumnType.boolean,
          isNullable: true,
          dartType: 'bool?',
        ),
        _isp.ColumnDefinition(
          name: 'lockedOut',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'buzz_fk_0',
          columns: ['playerId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'buzz_fk_1',
          columns: ['questionId'],
          referenceTable: 'question',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'buzz_player_question_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'playerId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'player',
      dartName: 'Player',
      schema: 'public',
      module: 'quiz_night',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'nickname',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'score',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'shadowScore',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'finalScore',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'totalCorrectAnswerMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PlayerStatus',
          columnDefault: '\'active\'',
        ),
        _isp.ColumnDefinition(
          name: 'eliminatedInRound',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'backedPlayerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'player_fk_0',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'player_room_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'player_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'question',
      dartName: 'Question',
      schema: 'public',
      module: 'quiz_night',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'orderIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'round',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'isFinal',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'isTiebreak',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'options',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
        _isp.ColumnDefinition(
          name: 'correctIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'timeLimitSeconds',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'question_fk_0',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'question_room_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'orderIndex',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room',
      dartName: 'Room',
      schema: 'public',
      module: 'quiz_night',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'hostToken',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:RoomStatus',
          columnDefault: '\'lobby\'',
        ),
        _isp.ColumnDefinition(
          name: 'currentRound',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'currentQuestionIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'currentQuestionId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'questionsPerRound',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'eliminationRule',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EliminationRule',
        ),
        _isp.ColumnDefinition(
          name: 'eliminationPercent',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'finalistTarget',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'roundsBeforeFinal',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tiebreakMode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TiebreakMode',
        ),
        _isp.ColumnDefinition(
          name: 'finalQuestionCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'timeLimitSeconds',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'showQuestionOnPhones',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'wildcardUsed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'startingPlayerCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'questionStartedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'questionEndsAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastCutRound',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'finalQuestionsPlayed',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'buzzerHolderId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'lastElimination',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:EliminationEvent?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6pk958y.Answer) {
      return _i6pk958y.Answer.fromJson(data) as T;
    }
    if (t == _irbcmcg9.AnswerResult) {
      return _irbcmcg9.AnswerResult.fromJson(data) as T;
    }
    if (t == _izgfeu3b.Buzz) {
      return _izgfeu3b.Buzz.fromJson(data) as T;
    }
    if (t == _iofgdbfb.BuzzResult) {
      return _iofgdbfb.BuzzResult.fromJson(data) as T;
    }
    if (t == _imz5iufx.CreateRoomResult) {
      return _imz5iufx.CreateRoomResult.fromJson(data) as T;
    }
    if (t == _i044r49r.EliminationEvent) {
      return _i044r49r.EliminationEvent.fromJson(data) as T;
    }
    if (t == _ix1rmfwn.EliminationRule) {
      return _ix1rmfwn.EliminationRule.fromJson(data) as T;
    }
    if (t == _irdkvnmr.JoinResult) {
      return _irdkvnmr.JoinResult.fromJson(data) as T;
    }
    if (t == _imuqra0a.Player) {
      return _imuqra0a.Player.fromJson(data) as T;
    }
    if (t == _iarmrzsm.PlayerStatus) {
      return _iarmrzsm.PlayerStatus.fromJson(data) as T;
    }
    if (t == _ijz1mobl.PlayerView) {
      return _ijz1mobl.PlayerView.fromJson(data) as T;
    }
    if (t == _in6mynjk.Question) {
      return _in6mynjk.Question.fromJson(data) as T;
    }
    if (t == _irhyxwad.QuestionView) {
      return _irhyxwad.QuestionView.fromJson(data) as T;
    }
    if (t == _ig7vrbjo.QuizErrorCode) {
      return _ig7vrbjo.QuizErrorCode.fromJson(data) as T;
    }
    if (t == _izdirdeu.QuizException) {
      return _izdirdeu.QuizException.fromJson(data) as T;
    }
    if (t == _ieflxecy.Room) {
      return _ieflxecy.Room.fromJson(data) as T;
    }
    if (t == _iwzadpd6.RoomConfig) {
      return _iwzadpd6.RoomConfig.fromJson(data) as T;
    }
    if (t == _i1uzd9w7.RoomState) {
      return _i1uzd9w7.RoomState.fromJson(data) as T;
    }
    if (t == _ilj1at52.RoomStatus) {
      return _ilj1at52.RoomStatus.fromJson(data) as T;
    }
    if (t == _ixk2jfuv.TiebreakMode) {
      return _ixk2jfuv.TiebreakMode.fromJson(data) as T;
    }
    if (t == _is.getType<_i6pk958y.Answer?>()) {
      return (data != null ? _i6pk958y.Answer.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irbcmcg9.AnswerResult?>()) {
      return (data != null ? _irbcmcg9.AnswerResult.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izgfeu3b.Buzz?>()) {
      return (data != null ? _izgfeu3b.Buzz.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iofgdbfb.BuzzResult?>()) {
      return (data != null ? _iofgdbfb.BuzzResult.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imz5iufx.CreateRoomResult?>()) {
      return (data != null ? _imz5iufx.CreateRoomResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i044r49r.EliminationEvent?>()) {
      return (data != null ? _i044r49r.EliminationEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ix1rmfwn.EliminationRule?>()) {
      return (data != null ? _ix1rmfwn.EliminationRule.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_irdkvnmr.JoinResult?>()) {
      return (data != null ? _irdkvnmr.JoinResult.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imuqra0a.Player?>()) {
      return (data != null ? _imuqra0a.Player.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iarmrzsm.PlayerStatus?>()) {
      return (data != null ? _iarmrzsm.PlayerStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijz1mobl.PlayerView?>()) {
      return (data != null ? _ijz1mobl.PlayerView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_in6mynjk.Question?>()) {
      return (data != null ? _in6mynjk.Question.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irhyxwad.QuestionView?>()) {
      return (data != null ? _irhyxwad.QuestionView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ig7vrbjo.QuizErrorCode?>()) {
      return (data != null ? _ig7vrbjo.QuizErrorCode.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izdirdeu.QuizException?>()) {
      return (data != null ? _izdirdeu.QuizException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ieflxecy.Room?>()) {
      return (data != null ? _ieflxecy.Room.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwzadpd6.RoomConfig?>()) {
      return (data != null ? _iwzadpd6.RoomConfig.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1uzd9w7.RoomState?>()) {
      return (data != null ? _i1uzd9w7.RoomState.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilj1at52.RoomStatus?>()) {
      return (data != null ? _ilj1at52.RoomStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixk2jfuv.TiebreakMode?>()) {
      return (data != null ? _ixk2jfuv.TiebreakMode.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_ijz1mobl.PlayerView>) {
      return (data as List)
              .map((e) => deserialize<_ijz1mobl.PlayerView>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6pk958y.Answer => 'Answer',
      _irbcmcg9.AnswerResult => 'AnswerResult',
      _izgfeu3b.Buzz => 'Buzz',
      _iofgdbfb.BuzzResult => 'BuzzResult',
      _imz5iufx.CreateRoomResult => 'CreateRoomResult',
      _i044r49r.EliminationEvent => 'EliminationEvent',
      _ix1rmfwn.EliminationRule => 'EliminationRule',
      _irdkvnmr.JoinResult => 'JoinResult',
      _imuqra0a.Player => 'Player',
      _iarmrzsm.PlayerStatus => 'PlayerStatus',
      _ijz1mobl.PlayerView => 'PlayerView',
      _in6mynjk.Question => 'Question',
      _irhyxwad.QuestionView => 'QuestionView',
      _ig7vrbjo.QuizErrorCode => 'QuizErrorCode',
      _izdirdeu.QuizException => 'QuizException',
      _ieflxecy.Room => 'Room',
      _iwzadpd6.RoomConfig => 'RoomConfig',
      _i1uzd9w7.RoomState => 'RoomState',
      _ilj1at52.RoomStatus => 'RoomStatus',
      _ixk2jfuv.TiebreakMode => 'TiebreakMode',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('quiz_night.', '');
    }

    switch (data) {
      case _i6pk958y.Answer():
        return 'Answer';
      case _irbcmcg9.AnswerResult():
        return 'AnswerResult';
      case _izgfeu3b.Buzz():
        return 'Buzz';
      case _iofgdbfb.BuzzResult():
        return 'BuzzResult';
      case _imz5iufx.CreateRoomResult():
        return 'CreateRoomResult';
      case _i044r49r.EliminationEvent():
        return 'EliminationEvent';
      case _ix1rmfwn.EliminationRule():
        return 'EliminationRule';
      case _irdkvnmr.JoinResult():
        return 'JoinResult';
      case _imuqra0a.Player():
        return 'Player';
      case _iarmrzsm.PlayerStatus():
        return 'PlayerStatus';
      case _ijz1mobl.PlayerView():
        return 'PlayerView';
      case _in6mynjk.Question():
        return 'Question';
      case _irhyxwad.QuestionView():
        return 'QuestionView';
      case _ig7vrbjo.QuizErrorCode():
        return 'QuizErrorCode';
      case _izdirdeu.QuizException():
        return 'QuizException';
      case _ieflxecy.Room():
        return 'Room';
      case _iwzadpd6.RoomConfig():
        return 'RoomConfig';
      case _i1uzd9w7.RoomState():
        return 'RoomState';
      case _ilj1at52.RoomStatus():
        return 'RoomStatus';
      case _ixk2jfuv.TiebreakMode():
        return 'TiebreakMode';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Answer') {
      return deserialize<_i6pk958y.Answer>(data['data']);
    }
    if (dataClassName == 'AnswerResult') {
      return deserialize<_irbcmcg9.AnswerResult>(data['data']);
    }
    if (dataClassName == 'Buzz') {
      return deserialize<_izgfeu3b.Buzz>(data['data']);
    }
    if (dataClassName == 'BuzzResult') {
      return deserialize<_iofgdbfb.BuzzResult>(data['data']);
    }
    if (dataClassName == 'CreateRoomResult') {
      return deserialize<_imz5iufx.CreateRoomResult>(data['data']);
    }
    if (dataClassName == 'EliminationEvent') {
      return deserialize<_i044r49r.EliminationEvent>(data['data']);
    }
    if (dataClassName == 'EliminationRule') {
      return deserialize<_ix1rmfwn.EliminationRule>(data['data']);
    }
    if (dataClassName == 'JoinResult') {
      return deserialize<_irdkvnmr.JoinResult>(data['data']);
    }
    if (dataClassName == 'Player') {
      return deserialize<_imuqra0a.Player>(data['data']);
    }
    if (dataClassName == 'PlayerStatus') {
      return deserialize<_iarmrzsm.PlayerStatus>(data['data']);
    }
    if (dataClassName == 'PlayerView') {
      return deserialize<_ijz1mobl.PlayerView>(data['data']);
    }
    if (dataClassName == 'Question') {
      return deserialize<_in6mynjk.Question>(data['data']);
    }
    if (dataClassName == 'QuestionView') {
      return deserialize<_irhyxwad.QuestionView>(data['data']);
    }
    if (dataClassName == 'QuizErrorCode') {
      return deserialize<_ig7vrbjo.QuizErrorCode>(data['data']);
    }
    if (dataClassName == 'QuizException') {
      return deserialize<_izdirdeu.QuizException>(data['data']);
    }
    if (dataClassName == 'Room') {
      return deserialize<_ieflxecy.Room>(data['data']);
    }
    if (dataClassName == 'RoomConfig') {
      return deserialize<_iwzadpd6.RoomConfig>(data['data']);
    }
    if (dataClassName == 'RoomState') {
      return deserialize<_i1uzd9w7.RoomState>(data['data']);
    }
    if (dataClassName == 'RoomStatus') {
      return deserialize<_ilj1at52.RoomStatus>(data['data']);
    }
    if (dataClassName == 'TiebreakMode') {
      return deserialize<_ixk2jfuv.TiebreakMode>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('quiz_night', this);
    _iacs.Protocol().registerHostProtocol('quiz_night', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6pk958y.Answer:
        return _i6pk958y.Answer.t;
      case _izgfeu3b.Buzz:
        return _izgfeu3b.Buzz.t;
      case _imuqra0a.Player:
        return _imuqra0a.Player.t;
      case _in6mynjk.Question:
        return _in6mynjk.Question.t;
      case _ieflxecy.Room:
        return _ieflxecy.Room.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'quiz_night';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

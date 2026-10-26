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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'answer.dart' as _i6pk958y;
import 'answer_result.dart' as _irbcmcg9;
import 'buzz.dart' as _izgfeu3b;
import 'buzz_result.dart' as _iofgdbfb;
import 'create_room_result.dart' as _imz5iufx;
import 'elimination_event.dart' as _i044r49r;
import 'elimination_rule.dart' as _ix1rmfwn;
import 'join_result.dart' as _irdkvnmr;
import 'pack_draft.dart' as _i6u791n3;
import 'pack_question.dart' as _ib5lmu7a;
import 'pack_question_view.dart' as _iwaxsltl;
import 'player.dart' as _imuqra0a;
import 'player_status.dart' as _iarmrzsm;
import 'player_view.dart' as _ijz1mobl;
import 'question.dart' as _in6mynjk;
import 'question_difficulty.dart' as _i5mrkeak;
import 'question_pack.dart' as _i0rdilu0;
import 'question_view.dart' as _irhyxwad;
import 'quiz_error_code.dart' as _ig7vrbjo;
import 'quiz_exception.dart' as _izdirdeu;
import 'room.dart' as _ieflxecy;
import 'room_config.dart' as _iwzadpd6;
import 'room_end_reason.dart' as _i1z47hfo;
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
export 'pack_draft.dart';
export 'pack_question.dart';
export 'pack_question_view.dart';
export 'player.dart';
export 'player_status.dart';
export 'player_view.dart';
export 'question.dart';
export 'question_difficulty.dart';
export 'question_pack.dart';
export 'question_view.dart';
export 'quiz_error_code.dart';
export 'quiz_exception.dart';
export 'room.dart';
export 'room_config.dart';
export 'room_end_reason.dart';
export 'room_state.dart';
export 'room_status.dart';
export 'tiebreak_mode.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _i6u791n3.PackDraft) {
      return _i6u791n3.PackDraft.fromJson(data) as T;
    }
    if (t == _ib5lmu7a.PackQuestion) {
      return _ib5lmu7a.PackQuestion.fromJson(data) as T;
    }
    if (t == _iwaxsltl.PackQuestionView) {
      return _iwaxsltl.PackQuestionView.fromJson(data) as T;
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
    if (t == _i5mrkeak.QuestionDifficulty) {
      return _i5mrkeak.QuestionDifficulty.fromJson(data) as T;
    }
    if (t == _i0rdilu0.QuestionPack) {
      return _i0rdilu0.QuestionPack.fromJson(data) as T;
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
    if (t == _i1z47hfo.RoomEndReason) {
      return _i1z47hfo.RoomEndReason.fromJson(data) as T;
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
    if (t == _isc.getType<_i6pk958y.Answer?>()) {
      return (data != null ? _i6pk958y.Answer.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_irbcmcg9.AnswerResult?>()) {
      return (data != null ? _irbcmcg9.AnswerResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izgfeu3b.Buzz?>()) {
      return (data != null ? _izgfeu3b.Buzz.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iofgdbfb.BuzzResult?>()) {
      return (data != null ? _iofgdbfb.BuzzResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imz5iufx.CreateRoomResult?>()) {
      return (data != null ? _imz5iufx.CreateRoomResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i044r49r.EliminationEvent?>()) {
      return (data != null ? _i044r49r.EliminationEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ix1rmfwn.EliminationRule?>()) {
      return (data != null ? _ix1rmfwn.EliminationRule.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_irdkvnmr.JoinResult?>()) {
      return (data != null ? _irdkvnmr.JoinResult.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6u791n3.PackDraft?>()) {
      return (data != null ? _i6u791n3.PackDraft.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ib5lmu7a.PackQuestion?>()) {
      return (data != null ? _ib5lmu7a.PackQuestion.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwaxsltl.PackQuestionView?>()) {
      return (data != null ? _iwaxsltl.PackQuestionView.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imuqra0a.Player?>()) {
      return (data != null ? _imuqra0a.Player.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iarmrzsm.PlayerStatus?>()) {
      return (data != null ? _iarmrzsm.PlayerStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijz1mobl.PlayerView?>()) {
      return (data != null ? _ijz1mobl.PlayerView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_in6mynjk.Question?>()) {
      return (data != null ? _in6mynjk.Question.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5mrkeak.QuestionDifficulty?>()) {
      return (data != null ? _i5mrkeak.QuestionDifficulty.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i0rdilu0.QuestionPack?>()) {
      return (data != null ? _i0rdilu0.QuestionPack.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_irhyxwad.QuestionView?>()) {
      return (data != null ? _irhyxwad.QuestionView.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ig7vrbjo.QuizErrorCode?>()) {
      return (data != null ? _ig7vrbjo.QuizErrorCode.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izdirdeu.QuizException?>()) {
      return (data != null ? _izdirdeu.QuizException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ieflxecy.Room?>()) {
      return (data != null ? _ieflxecy.Room.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwzadpd6.RoomConfig?>()) {
      return (data != null ? _iwzadpd6.RoomConfig.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1z47hfo.RoomEndReason?>()) {
      return (data != null ? _i1z47hfo.RoomEndReason.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i1uzd9w7.RoomState?>()) {
      return (data != null ? _i1uzd9w7.RoomState.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilj1at52.RoomStatus?>()) {
      return (data != null ? _ilj1at52.RoomStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixk2jfuv.TiebreakMode?>()) {
      return (data != null ? _ixk2jfuv.TiebreakMode.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_iwaxsltl.PackQuestionView>) {
      return (data as List)
              .map((e) => deserialize<_iwaxsltl.PackQuestionView>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<int>?>()) {
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
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
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
      _i6u791n3.PackDraft => 'PackDraft',
      _ib5lmu7a.PackQuestion => 'PackQuestion',
      _iwaxsltl.PackQuestionView => 'PackQuestionView',
      _imuqra0a.Player => 'Player',
      _iarmrzsm.PlayerStatus => 'PlayerStatus',
      _ijz1mobl.PlayerView => 'PlayerView',
      _in6mynjk.Question => 'Question',
      _i5mrkeak.QuestionDifficulty => 'QuestionDifficulty',
      _i0rdilu0.QuestionPack => 'QuestionPack',
      _irhyxwad.QuestionView => 'QuestionView',
      _ig7vrbjo.QuizErrorCode => 'QuizErrorCode',
      _izdirdeu.QuizException => 'QuizException',
      _ieflxecy.Room => 'Room',
      _iwzadpd6.RoomConfig => 'RoomConfig',
      _i1z47hfo.RoomEndReason => 'RoomEndReason',
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
      case _i6u791n3.PackDraft():
        return 'PackDraft';
      case _ib5lmu7a.PackQuestion():
        return 'PackQuestion';
      case _iwaxsltl.PackQuestionView():
        return 'PackQuestionView';
      case _imuqra0a.Player():
        return 'Player';
      case _iarmrzsm.PlayerStatus():
        return 'PlayerStatus';
      case _ijz1mobl.PlayerView():
        return 'PlayerView';
      case _in6mynjk.Question():
        return 'Question';
      case _i5mrkeak.QuestionDifficulty():
        return 'QuestionDifficulty';
      case _i0rdilu0.QuestionPack():
        return 'QuestionPack';
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
      case _i1z47hfo.RoomEndReason():
        return 'RoomEndReason';
      case _i1uzd9w7.RoomState():
        return 'RoomState';
      case _ilj1at52.RoomStatus():
        return 'RoomStatus';
      case _ixk2jfuv.TiebreakMode():
        return 'TiebreakMode';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
    if (dataClassName == 'PackDraft') {
      return deserialize<_i6u791n3.PackDraft>(data['data']);
    }
    if (dataClassName == 'PackQuestion') {
      return deserialize<_ib5lmu7a.PackQuestion>(data['data']);
    }
    if (dataClassName == 'PackQuestionView') {
      return deserialize<_iwaxsltl.PackQuestionView>(data['data']);
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
    if (dataClassName == 'QuestionDifficulty') {
      return deserialize<_i5mrkeak.QuestionDifficulty>(data['data']);
    }
    if (dataClassName == 'QuestionPack') {
      return deserialize<_i0rdilu0.QuestionPack>(data['data']);
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
    if (dataClassName == 'RoomEndReason') {
      return deserialize<_i1z47hfo.RoomEndReason>(data['data']);
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
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('quiz_night', this);
    _iacc.Protocol().registerHostProtocol('quiz_night', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}

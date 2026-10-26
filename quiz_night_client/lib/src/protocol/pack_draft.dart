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
import 'pack_question_view.dart' as _iwaxsltl;
import 'question_difficulty.dart' as _i5mrkeak;

/// A generated pack as the host previews it, answers included (host only).
abstract class PackDraft
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PackDraft._({
    required this.packId,
    required this.packToken,
    required this.topic,
    required this.difficulty,
    required this.questions,
    required this.roundQuestionsNeeded,
    required this.finalQuestionsNeeded,
  });

  factory PackDraft({
    required int packId,
    required String packToken,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    required List<_iwaxsltl.PackQuestionView> questions,
    required int roundQuestionsNeeded,
    required int finalQuestionsNeeded,
  }) = _PackDraftImpl;

  factory PackDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return PackDraft(
      packId: jsonSerialization['packId'] as int,
      packToken: jsonSerialization['packToken'] as String,
      topic: jsonSerialization['topic'] as String,
      difficulty: _i5mrkeak.QuestionDifficulty.fromJson(
        (jsonSerialization['difficulty'] as String),
      ),
      questions: _ibnz9izf.Protocol()
          .deserialize<List<_iwaxsltl.PackQuestionView>>(
            jsonSerialization['questions'],
          ),
      roundQuestionsNeeded: jsonSerialization['roundQuestionsNeeded'] as int,
      finalQuestionsNeeded: jsonSerialization['finalQuestionsNeeded'] as int,
    );
  }

  int packId;

  /// Pass back in RoomConfig to play this pack.
  String packToken;

  String topic;

  _i5mrkeak.QuestionDifficulty difficulty;

  List<_iwaxsltl.PackQuestionView> questions;

  /// Round/final questions the game likely needs; the bank fills any shortfall.
  int roundQuestionsNeeded;

  int finalQuestionsNeeded;

  /// Returns a shallow copy of this [PackDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PackDraft copyWith({
    int? packId,
    String? packToken,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    List<_iwaxsltl.PackQuestionView>? questions,
    int? roundQuestionsNeeded,
    int? finalQuestionsNeeded,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PackDraft',
      'packId': packId,
      'packToken': packToken,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      'questions': questions.toJson(valueToJson: (v) => v.toJson()),
      'roundQuestionsNeeded': roundQuestionsNeeded,
      'finalQuestionsNeeded': finalQuestionsNeeded,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PackDraft',
      'packId': packId,
      'packToken': packToken,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      'questions': questions.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'roundQuestionsNeeded': roundQuestionsNeeded,
      'finalQuestionsNeeded': finalQuestionsNeeded,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PackDraftImpl extends PackDraft {
  _PackDraftImpl({
    required int packId,
    required String packToken,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    required List<_iwaxsltl.PackQuestionView> questions,
    required int roundQuestionsNeeded,
    required int finalQuestionsNeeded,
  }) : super._(
         packId: packId,
         packToken: packToken,
         topic: topic,
         difficulty: difficulty,
         questions: questions,
         roundQuestionsNeeded: roundQuestionsNeeded,
         finalQuestionsNeeded: finalQuestionsNeeded,
       );

  /// Returns a shallow copy of this [PackDraft]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PackDraft copyWith({
    int? packId,
    String? packToken,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    List<_iwaxsltl.PackQuestionView>? questions,
    int? roundQuestionsNeeded,
    int? finalQuestionsNeeded,
  }) {
    return PackDraft(
      packId: packId ?? this.packId,
      packToken: packToken ?? this.packToken,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      questions:
          questions ?? this.questions.map((e0) => e0.copyWith()).toList(),
      roundQuestionsNeeded: roundQuestionsNeeded ?? this.roundQuestionsNeeded,
      finalQuestionsNeeded: finalQuestionsNeeded ?? this.finalQuestionsNeeded,
    );
  }
}

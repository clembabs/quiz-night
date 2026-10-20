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

/// Question as sent to clients. correctIndex is null until reveal.
abstract class QuestionView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  QuestionView._({
    required this.id,
    required this.round,
    required this.indexInRound,
    required this.isFinal,
    required this.text,
    required this.options,
    required this.timeLimitSeconds,
    this.correctIndex,
    this.answerCounts,
  });

  factory QuestionView({
    required int id,
    required int round,
    required int indexInRound,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int timeLimitSeconds,
    int? correctIndex,
    List<int>? answerCounts,
  }) = _QuestionViewImpl;

  factory QuestionView.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuestionView(
      id: jsonSerialization['id'] as int,
      round: jsonSerialization['round'] as int,
      indexInRound: jsonSerialization['indexInRound'] as int,
      isFinal: _is.BoolJsonExtension.fromJson(jsonSerialization['isFinal']),
      text: jsonSerialization['text'] as String,
      options: _izn0xfae.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
      timeLimitSeconds: jsonSerialization['timeLimitSeconds'] as int,
      correctIndex: jsonSerialization['correctIndex'] as int?,
      answerCounts: jsonSerialization['answerCounts'] == null
          ? null
          : _izn0xfae.Protocol().deserialize<List<int>>(
              jsonSerialization['answerCounts'],
            ),
    );
  }

  int id;

  int round;

  int indexInRound;

  bool isFinal;

  String text;

  List<String> options;

  int timeLimitSeconds;

  int? correctIndex;

  /// Votes per option (active players only); only set after reveal.
  List<int>? answerCounts;

  /// Returns a shallow copy of this [QuestionView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuestionView copyWith({
    int? id,
    int? round,
    int? indexInRound,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? timeLimitSeconds,
    int? correctIndex,
    List<int>? answerCounts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuestionView',
      'id': id,
      'round': round,
      'indexInRound': indexInRound,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'timeLimitSeconds': timeLimitSeconds,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (answerCounts != null) 'answerCounts': answerCounts?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuestionView',
      'id': id,
      'round': round,
      'indexInRound': indexInRound,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'timeLimitSeconds': timeLimitSeconds,
      if (correctIndex != null) 'correctIndex': correctIndex,
      if (answerCounts != null) 'answerCounts': answerCounts?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuestionViewImpl extends QuestionView {
  _QuestionViewImpl({
    required int id,
    required int round,
    required int indexInRound,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int timeLimitSeconds,
    int? correctIndex,
    List<int>? answerCounts,
  }) : super._(
         id: id,
         round: round,
         indexInRound: indexInRound,
         isFinal: isFinal,
         text: text,
         options: options,
         timeLimitSeconds: timeLimitSeconds,
         correctIndex: correctIndex,
         answerCounts: answerCounts,
       );

  /// Returns a shallow copy of this [QuestionView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuestionView copyWith({
    int? id,
    int? round,
    int? indexInRound,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? timeLimitSeconds,
    Object? correctIndex = _Undefined,
    Object? answerCounts = _Undefined,
  }) {
    return QuestionView(
      id: id ?? this.id,
      round: round ?? this.round,
      indexInRound: indexInRound ?? this.indexInRound,
      isFinal: isFinal ?? this.isFinal,
      text: text ?? this.text,
      options: options ?? this.options.map((e0) => e0).toList(),
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      correctIndex: correctIndex is int? ? correctIndex : this.correctIndex,
      answerCounts: answerCounts is List<int>?
          ? answerCounts
          : this.answerCounts?.map((e0) => e0).toList(),
    );
  }
}

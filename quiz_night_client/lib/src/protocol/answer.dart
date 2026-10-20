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

abstract class Answer
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Answer._({
    this.id,
    required this.playerId,
    required this.questionId,
    required this.choiceIndex,
    required this.answeredAt,
    required this.elapsedMs,
    required this.isCorrect,
    required this.pointsAwarded,
    required this.isShadow,
  });

  factory Answer({
    int? id,
    required int playerId,
    required int questionId,
    required int choiceIndex,
    required DateTime answeredAt,
    required int elapsedMs,
    required bool isCorrect,
    required int pointsAwarded,
    required bool isShadow,
  }) = _AnswerImpl;

  factory Answer.fromJson(Map<String, dynamic> jsonSerialization) {
    return Answer(
      id: jsonSerialization['id'] as int?,
      playerId: jsonSerialization['playerId'] as int,
      questionId: jsonSerialization['questionId'] as int,
      choiceIndex: jsonSerialization['choiceIndex'] as int,
      answeredAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['answeredAt'],
      ),
      elapsedMs: jsonSerialization['elapsedMs'] as int,
      isCorrect: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isCorrect'],
      ),
      pointsAwarded: jsonSerialization['pointsAwarded'] as int,
      isShadow: _isc.BoolJsonExtension.fromJson(jsonSerialization['isShadow']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int playerId;

  int questionId;

  int choiceIndex;

  DateTime answeredAt;

  int elapsedMs;

  bool isCorrect;

  int pointsAwarded;

  bool isShadow;

  /// Returns a shallow copy of this [Answer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Answer copyWith({
    int? id,
    int? playerId,
    int? questionId,
    int? choiceIndex,
    DateTime? answeredAt,
    int? elapsedMs,
    bool? isCorrect,
    int? pointsAwarded,
    bool? isShadow,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Answer',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
      'answeredAt': answeredAt.toJson(),
      'elapsedMs': elapsedMs,
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'isShadow': isShadow,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Answer',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
      'answeredAt': answeredAt.toJson(),
      'elapsedMs': elapsedMs,
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'isShadow': isShadow,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnswerImpl extends Answer {
  _AnswerImpl({
    int? id,
    required int playerId,
    required int questionId,
    required int choiceIndex,
    required DateTime answeredAt,
    required int elapsedMs,
    required bool isCorrect,
    required int pointsAwarded,
    required bool isShadow,
  }) : super._(
         id: id,
         playerId: playerId,
         questionId: questionId,
         choiceIndex: choiceIndex,
         answeredAt: answeredAt,
         elapsedMs: elapsedMs,
         isCorrect: isCorrect,
         pointsAwarded: pointsAwarded,
         isShadow: isShadow,
       );

  /// Returns a shallow copy of this [Answer]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Answer copyWith({
    Object? id = _Undefined,
    int? playerId,
    int? questionId,
    int? choiceIndex,
    DateTime? answeredAt,
    int? elapsedMs,
    bool? isCorrect,
    int? pointsAwarded,
    bool? isShadow,
  }) {
    return Answer(
      id: id is int? ? id : this.id,
      playerId: playerId ?? this.playerId,
      questionId: questionId ?? this.questionId,
      choiceIndex: choiceIndex ?? this.choiceIndex,
      answeredAt: answeredAt ?? this.answeredAt,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      isShadow: isShadow ?? this.isShadow,
    );
  }
}

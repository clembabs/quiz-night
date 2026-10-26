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
import 'question_difficulty.dart' as _i5mrkeak;

/// AI-written questions for one host's game, made before the room exists.
abstract class QuestionPack
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  QuestionPack._({
    this.id,
    required this.topic,
    required this.difficulty,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory QuestionPack({
    int? id,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    DateTime? createdAt,
  }) = _QuestionPackImpl;

  factory QuestionPack.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuestionPack(
      id: jsonSerialization['id'] as int?,
      topic: jsonSerialization['topic'] as String,
      difficulty: _i5mrkeak.QuestionDifficulty.fromJson(
        (jsonSerialization['difficulty'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String topic;

  _i5mrkeak.QuestionDifficulty difficulty;

  DateTime createdAt;

  /// Returns a shallow copy of this [QuestionPack]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  QuestionPack copyWith({
    int? id,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuestionPack',
      if (id != null) 'id': id,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuestionPack',
      if (id != null) 'id': id,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuestionPackImpl extends QuestionPack {
  _QuestionPackImpl({
    int? id,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    DateTime? createdAt,
  }) : super._(
         id: id,
         topic: topic,
         difficulty: difficulty,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [QuestionPack]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  QuestionPack copyWith({
    Object? id = _Undefined,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    DateTime? createdAt,
  }) {
    return QuestionPack(
      id: id is int? ? id : this.id,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

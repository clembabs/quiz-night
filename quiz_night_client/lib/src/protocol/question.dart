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

abstract class Question
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Question._({
    this.id,
    required this.roomId,
    required this.orderIndex,
    required this.round,
    bool? isFinal,
    bool? isTiebreak,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.timeLimitSeconds,
  }) : isFinal = isFinal ?? false,
       isTiebreak = isTiebreak ?? false;

  factory Question({
    int? id,
    required int roomId,
    required int orderIndex,
    required int round,
    bool? isFinal,
    bool? isTiebreak,
    required String text,
    required List<String> options,
    required int correctIndex,
    required int timeLimitSeconds,
  }) = _QuestionImpl;

  factory Question.fromJson(Map<String, dynamic> jsonSerialization) {
    return Question(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      orderIndex: jsonSerialization['orderIndex'] as int,
      round: jsonSerialization['round'] as int,
      isFinal: jsonSerialization['isFinal'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isFinal']),
      isTiebreak: jsonSerialization['isTiebreak'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isTiebreak']),
      text: jsonSerialization['text'] as String,
      options: _ibnz9izf.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
      correctIndex: jsonSerialization['correctIndex'] as int,
      timeLimitSeconds: jsonSerialization['timeLimitSeconds'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  int orderIndex;

  int round;

  bool isFinal;

  bool isTiebreak;

  String text;

  List<String> options;

  int correctIndex;

  int timeLimitSeconds;

  /// Returns a shallow copy of this [Question]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Question copyWith({
    int? id,
    int? roomId,
    int? orderIndex,
    int? round,
    bool? isFinal,
    bool? isTiebreak,
    String? text,
    List<String>? options,
    int? correctIndex,
    int? timeLimitSeconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Question',
      if (id != null) 'id': id,
      'roomId': roomId,
      'orderIndex': orderIndex,
      'round': round,
      'isFinal': isFinal,
      'isTiebreak': isTiebreak,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
      'timeLimitSeconds': timeLimitSeconds,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Question',
      if (id != null) 'id': id,
      'roomId': roomId,
      'orderIndex': orderIndex,
      'round': round,
      'isFinal': isFinal,
      'isTiebreak': isTiebreak,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
      'timeLimitSeconds': timeLimitSeconds,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuestionImpl extends Question {
  _QuestionImpl({
    int? id,
    required int roomId,
    required int orderIndex,
    required int round,
    bool? isFinal,
    bool? isTiebreak,
    required String text,
    required List<String> options,
    required int correctIndex,
    required int timeLimitSeconds,
  }) : super._(
         id: id,
         roomId: roomId,
         orderIndex: orderIndex,
         round: round,
         isFinal: isFinal,
         isTiebreak: isTiebreak,
         text: text,
         options: options,
         correctIndex: correctIndex,
         timeLimitSeconds: timeLimitSeconds,
       );

  /// Returns a shallow copy of this [Question]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Question copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? orderIndex,
    int? round,
    bool? isFinal,
    bool? isTiebreak,
    String? text,
    List<String>? options,
    int? correctIndex,
    int? timeLimitSeconds,
  }) {
    return Question(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      orderIndex: orderIndex ?? this.orderIndex,
      round: round ?? this.round,
      isFinal: isFinal ?? this.isFinal,
      isTiebreak: isTiebreak ?? this.isTiebreak,
      text: text ?? this.text,
      options: options ?? this.options.map((e0) => e0).toList(),
      correctIndex: correctIndex ?? this.correctIndex,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
    );
  }
}

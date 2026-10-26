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

/// One question in a [QuestionPack].
abstract class PackQuestion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PackQuestion._({
    this.id,
    required this.packId,
    required this.orderIndex,
    required this.isFinal,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory PackQuestion({
    int? id,
    required int packId,
    required int orderIndex,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) = _PackQuestionImpl;

  factory PackQuestion.fromJson(Map<String, dynamic> jsonSerialization) {
    return PackQuestion(
      id: jsonSerialization['id'] as int?,
      packId: jsonSerialization['packId'] as int,
      orderIndex: jsonSerialization['orderIndex'] as int,
      isFinal: _isc.BoolJsonExtension.fromJson(jsonSerialization['isFinal']),
      text: jsonSerialization['text'] as String,
      options: _ibnz9izf.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
      correctIndex: jsonSerialization['correctIndex'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int packId;

  /// Play order within its kind (rounds or final).
  int orderIndex;

  bool isFinal;

  String text;

  List<String> options;

  int correctIndex;

  /// Returns a shallow copy of this [PackQuestion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PackQuestion copyWith({
    int? id,
    int? packId,
    int? orderIndex,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PackQuestion',
      if (id != null) 'id': id,
      'packId': packId,
      'orderIndex': orderIndex,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PackQuestion',
      if (id != null) 'id': id,
      'packId': packId,
      'orderIndex': orderIndex,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PackQuestionImpl extends PackQuestion {
  _PackQuestionImpl({
    int? id,
    required int packId,
    required int orderIndex,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) : super._(
         id: id,
         packId: packId,
         orderIndex: orderIndex,
         isFinal: isFinal,
         text: text,
         options: options,
         correctIndex: correctIndex,
       );

  /// Returns a shallow copy of this [PackQuestion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PackQuestion copyWith({
    Object? id = _Undefined,
    int? packId,
    int? orderIndex,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  }) {
    return PackQuestion(
      id: id is int? ? id : this.id,
      packId: packId ?? this.packId,
      orderIndex: orderIndex ?? this.orderIndex,
      isFinal: isFinal ?? this.isFinal,
      text: text ?? this.text,
      options: options ?? this.options.map((e0) => e0).toList(),
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

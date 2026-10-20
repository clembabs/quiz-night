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

abstract class Buzz
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Buzz._({
    this.id,
    required this.playerId,
    required this.questionId,
    required this.buzzedAt,
    this.wasCorrect,
    bool? lockedOut,
  }) : lockedOut = lockedOut ?? false;

  factory Buzz({
    int? id,
    required int playerId,
    required int questionId,
    required DateTime buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  }) = _BuzzImpl;

  factory Buzz.fromJson(Map<String, dynamic> jsonSerialization) {
    return Buzz(
      id: jsonSerialization['id'] as int?,
      playerId: jsonSerialization['playerId'] as int,
      questionId: jsonSerialization['questionId'] as int,
      buzzedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['buzzedAt'],
      ),
      wasCorrect: jsonSerialization['wasCorrect'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['wasCorrect']),
      lockedOut: jsonSerialization['lockedOut'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['lockedOut']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int playerId;

  int questionId;

  DateTime buzzedAt;

  bool? wasCorrect;

  bool lockedOut;

  /// Returns a shallow copy of this [Buzz]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Buzz copyWith({
    int? id,
    int? playerId,
    int? questionId,
    DateTime? buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Buzz',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'buzzedAt': buzzedAt.toJson(),
      if (wasCorrect != null) 'wasCorrect': wasCorrect,
      'lockedOut': lockedOut,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Buzz',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'buzzedAt': buzzedAt.toJson(),
      if (wasCorrect != null) 'wasCorrect': wasCorrect,
      'lockedOut': lockedOut,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BuzzImpl extends Buzz {
  _BuzzImpl({
    int? id,
    required int playerId,
    required int questionId,
    required DateTime buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  }) : super._(
         id: id,
         playerId: playerId,
         questionId: questionId,
         buzzedAt: buzzedAt,
         wasCorrect: wasCorrect,
         lockedOut: lockedOut,
       );

  /// Returns a shallow copy of this [Buzz]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Buzz copyWith({
    Object? id = _Undefined,
    int? playerId,
    int? questionId,
    DateTime? buzzedAt,
    Object? wasCorrect = _Undefined,
    bool? lockedOut,
  }) {
    return Buzz(
      id: id is int? ? id : this.id,
      playerId: playerId ?? this.playerId,
      questionId: questionId ?? this.questionId,
      buzzedAt: buzzedAt ?? this.buzzedAt,
      wasCorrect: wasCorrect is bool? ? wasCorrect : this.wasCorrect,
      lockedOut: lockedOut ?? this.lockedOut,
    );
  }
}

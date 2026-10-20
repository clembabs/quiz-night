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
import 'package:serverpod/serverpod.dart' as _is;

abstract class AnswerResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AnswerResult._({
    required this.accepted,
    required this.isShadow,
  });

  factory AnswerResult({
    required bool accepted,
    required bool isShadow,
  }) = _AnswerResultImpl;

  factory AnswerResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnswerResult(
      accepted: _is.BoolJsonExtension.fromJson(jsonSerialization['accepted']),
      isShadow: _is.BoolJsonExtension.fromJson(jsonSerialization['isShadow']),
    );
  }

  bool accepted;

  bool isShadow;

  /// Returns a shallow copy of this [AnswerResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AnswerResult copyWith({
    bool? accepted,
    bool? isShadow,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnswerResult',
      'accepted': accepted,
      'isShadow': isShadow,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AnswerResult',
      'accepted': accepted,
      'isShadow': isShadow,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AnswerResultImpl extends AnswerResult {
  _AnswerResultImpl({
    required bool accepted,
    required bool isShadow,
  }) : super._(
         accepted: accepted,
         isShadow: isShadow,
       );

  /// Returns a shallow copy of this [AnswerResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AnswerResult copyWith({
    bool? accepted,
    bool? isShadow,
  }) {
    return AnswerResult(
      accepted: accepted ?? this.accepted,
      isShadow: isShadow ?? this.isShadow,
    );
  }
}

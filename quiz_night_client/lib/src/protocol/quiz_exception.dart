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
import 'quiz_error_code.dart' as _ig7vrbjo;

abstract class QuizException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  QuizException._({
    required this.code,
    required this.message,
  });

  factory QuizException({
    required _ig7vrbjo.QuizErrorCode code,
    required String message,
  }) = _QuizExceptionImpl;

  factory QuizException.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizException(
      code: _ig7vrbjo.QuizErrorCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _ig7vrbjo.QuizErrorCode code;

  String message;

  /// Returns a shallow copy of this [QuizException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  QuizException copyWith({
    _ig7vrbjo.QuizErrorCode? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuizException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'QuizException(code: $code, message: $message)';
  }
}

class _QuizExceptionImpl extends QuizException {
  _QuizExceptionImpl({
    required _ig7vrbjo.QuizErrorCode code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [QuizException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  QuizException copyWith({
    _ig7vrbjo.QuizErrorCode? code,
    String? message,
  }) {
    return QuizException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}

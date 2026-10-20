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

abstract class BuzzResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  BuzzResult._({
    required this.gotBuzzer,
    this.reason,
  });

  factory BuzzResult({
    required bool gotBuzzer,
    String? reason,
  }) = _BuzzResultImpl;

  factory BuzzResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return BuzzResult(
      gotBuzzer: _is.BoolJsonExtension.fromJson(jsonSerialization['gotBuzzer']),
      reason: jsonSerialization['reason'] as String?,
    );
  }

  bool gotBuzzer;

  String? reason;

  /// Returns a shallow copy of this [BuzzResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BuzzResult copyWith({
    bool? gotBuzzer,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BuzzResult',
      'gotBuzzer': gotBuzzer,
      if (reason != null) 'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BuzzResult',
      'gotBuzzer': gotBuzzer,
      if (reason != null) 'reason': reason,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BuzzResultImpl extends BuzzResult {
  _BuzzResultImpl({
    required bool gotBuzzer,
    String? reason,
  }) : super._(
         gotBuzzer: gotBuzzer,
         reason: reason,
       );

  /// Returns a shallow copy of this [BuzzResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BuzzResult copyWith({
    bool? gotBuzzer,
    Object? reason = _Undefined,
  }) {
    return BuzzResult(
      gotBuzzer: gotBuzzer ?? this.gotBuzzer,
      reason: reason is String? ? reason : this.reason,
    );
  }
}

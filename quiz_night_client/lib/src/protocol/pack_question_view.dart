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

/// A pack question in the host's preview.
abstract class PackQuestionView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PackQuestionView._({
    required this.id,
    required this.isFinal,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory PackQuestionView({
    required int id,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) = _PackQuestionViewImpl;

  factory PackQuestionView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PackQuestionView(
      id: jsonSerialization['id'] as int,
      isFinal: _isc.BoolJsonExtension.fromJson(jsonSerialization['isFinal']),
      text: jsonSerialization['text'] as String,
      options: _ibnz9izf.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
      correctIndex: jsonSerialization['correctIndex'] as int,
    );
  }

  int id;

  bool isFinal;

  String text;

  List<String> options;

  int correctIndex;

  /// Returns a shallow copy of this [PackQuestionView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PackQuestionView copyWith({
    int? id,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PackQuestionView',
      'id': id,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PackQuestionView',
      'id': id,
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

class _PackQuestionViewImpl extends PackQuestionView {
  _PackQuestionViewImpl({
    required int id,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) : super._(
         id: id,
         isFinal: isFinal,
         text: text,
         options: options,
         correctIndex: correctIndex,
       );

  /// Returns a shallow copy of this [PackQuestionView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PackQuestionView copyWith({
    int? id,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  }) {
    return PackQuestionView(
      id: id ?? this.id,
      isFinal: isFinal ?? this.isFinal,
      text: text ?? this.text,
      options: options ?? this.options.map((e0) => e0).toList(),
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

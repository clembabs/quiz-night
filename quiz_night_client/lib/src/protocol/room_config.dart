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
import 'elimination_rule.dart' as _ix1rmfwn;
import 'tiebreak_mode.dart' as _ixk2jfuv;

/// Host-chosen settings for a new room.
abstract class RoomConfig
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomConfig._({
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    this.packId,
    this.packToken,
  }) : questionsPerRound = questionsPerRound ?? 5,
       eliminationRule =
           eliminationRule ?? _ix1rmfwn.EliminationRule.bottomPercent,
       eliminationPercent = eliminationPercent ?? 0.3,
       finalistTarget = finalistTarget ?? 3,
       roundsBeforeFinal = roundsBeforeFinal ?? 3,
       tiebreakMode = tiebreakMode ?? _ixk2jfuv.TiebreakMode.speed,
       finalQuestionCount = finalQuestionCount ?? 5,
       timeLimitSeconds = timeLimitSeconds ?? 20,
       showQuestionOnPhones = showQuestionOnPhones ?? true;

  factory RoomConfig({
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    int? packId,
    String? packToken,
  }) = _RoomConfigImpl;

  factory RoomConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomConfig(
      questionsPerRound: jsonSerialization['questionsPerRound'] as int?,
      eliminationRule: jsonSerialization['eliminationRule'] == null
          ? null
          : _ix1rmfwn.EliminationRule.fromJson(
              (jsonSerialization['eliminationRule'] as String),
            ),
      eliminationPercent: (jsonSerialization['eliminationPercent'] as num?)
          ?.toDouble(),
      finalistTarget: jsonSerialization['finalistTarget'] as int?,
      roundsBeforeFinal: jsonSerialization['roundsBeforeFinal'] as int?,
      tiebreakMode: jsonSerialization['tiebreakMode'] == null
          ? null
          : _ixk2jfuv.TiebreakMode.fromJson(
              (jsonSerialization['tiebreakMode'] as String),
            ),
      finalQuestionCount: jsonSerialization['finalQuestionCount'] as int?,
      timeLimitSeconds: jsonSerialization['timeLimitSeconds'] as int?,
      showQuestionOnPhones: jsonSerialization['showQuestionOnPhones'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['showQuestionOnPhones'],
            ),
      packId: jsonSerialization['packId'] as int?,
      packToken: jsonSerialization['packToken'] as String?,
    );
  }

  int questionsPerRound;

  _ix1rmfwn.EliminationRule eliminationRule;

  /// Fraction (0-1) of active players cut each round for bottomPercent.
  double eliminationPercent;

  int finalistTarget;

  /// Rounds before the final; used by autoScaled.
  int roundsBeforeFinal;

  _ixk2jfuv.TiebreakMode tiebreakMode;

  int finalQuestionCount;

  int timeLimitSeconds;

  /// Whether players' phones show the question text, or only the projector.
  bool showQuestionOnPhones;

  /// An AI-written pack to play, from generatePack; with its token.
  int? packId;

  String? packToken;

  /// Returns a shallow copy of this [RoomConfig]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomConfig copyWith({
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    int? packId,
    String? packToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomConfig',
      'questionsPerRound': questionsPerRound,
      'eliminationRule': eliminationRule.toJson(),
      'eliminationPercent': eliminationPercent,
      'finalistTarget': finalistTarget,
      'roundsBeforeFinal': roundsBeforeFinal,
      'tiebreakMode': tiebreakMode.toJson(),
      'finalQuestionCount': finalQuestionCount,
      'timeLimitSeconds': timeLimitSeconds,
      'showQuestionOnPhones': showQuestionOnPhones,
      if (packId != null) 'packId': packId,
      if (packToken != null) 'packToken': packToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomConfig',
      'questionsPerRound': questionsPerRound,
      'eliminationRule': eliminationRule.toJson(),
      'eliminationPercent': eliminationPercent,
      'finalistTarget': finalistTarget,
      'roundsBeforeFinal': roundsBeforeFinal,
      'tiebreakMode': tiebreakMode.toJson(),
      'finalQuestionCount': finalQuestionCount,
      'timeLimitSeconds': timeLimitSeconds,
      'showQuestionOnPhones': showQuestionOnPhones,
      if (packId != null) 'packId': packId,
      if (packToken != null) 'packToken': packToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomConfigImpl extends RoomConfig {
  _RoomConfigImpl({
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    int? packId,
    String? packToken,
  }) : super._(
         questionsPerRound: questionsPerRound,
         eliminationRule: eliminationRule,
         eliminationPercent: eliminationPercent,
         finalistTarget: finalistTarget,
         roundsBeforeFinal: roundsBeforeFinal,
         tiebreakMode: tiebreakMode,
         finalQuestionCount: finalQuestionCount,
         timeLimitSeconds: timeLimitSeconds,
         showQuestionOnPhones: showQuestionOnPhones,
         packId: packId,
         packToken: packToken,
       );

  /// Returns a shallow copy of this [RoomConfig]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomConfig copyWith({
    int? questionsPerRound,
    _ix1rmfwn.EliminationRule? eliminationRule,
    double? eliminationPercent,
    int? finalistTarget,
    int? roundsBeforeFinal,
    _ixk2jfuv.TiebreakMode? tiebreakMode,
    int? finalQuestionCount,
    int? timeLimitSeconds,
    bool? showQuestionOnPhones,
    Object? packId = _Undefined,
    Object? packToken = _Undefined,
  }) {
    return RoomConfig(
      questionsPerRound: questionsPerRound ?? this.questionsPerRound,
      eliminationRule: eliminationRule ?? this.eliminationRule,
      eliminationPercent: eliminationPercent ?? this.eliminationPercent,
      finalistTarget: finalistTarget ?? this.finalistTarget,
      roundsBeforeFinal: roundsBeforeFinal ?? this.roundsBeforeFinal,
      tiebreakMode: tiebreakMode ?? this.tiebreakMode,
      finalQuestionCount: finalQuestionCount ?? this.finalQuestionCount,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      showQuestionOnPhones: showQuestionOnPhones ?? this.showQuestionOnPhones,
      packId: packId is int? ? packId : this.packId,
      packToken: packToken is String? ? packToken : this.packToken,
    );
  }
}

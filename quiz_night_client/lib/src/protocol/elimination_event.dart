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

abstract class EliminationEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EliminationEvent._({
    required this.round,
    required this.eliminatedPlayerIds,
    required this.survivorsCount,
    required this.tieBrokenBySpeed,
    required this.finalistsDecided,
  });

  factory EliminationEvent({
    required int round,
    required List<int> eliminatedPlayerIds,
    required int survivorsCount,
    required bool tieBrokenBySpeed,
    required bool finalistsDecided,
  }) = _EliminationEventImpl;

  factory EliminationEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return EliminationEvent(
      round: jsonSerialization['round'] as int,
      eliminatedPlayerIds: _ibnz9izf.Protocol().deserialize<List<int>>(
        jsonSerialization['eliminatedPlayerIds'],
      ),
      survivorsCount: jsonSerialization['survivorsCount'] as int,
      tieBrokenBySpeed: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['tieBrokenBySpeed'],
      ),
      finalistsDecided: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['finalistsDecided'],
      ),
    );
  }

  int round;

  /// Eliminated players in reveal order (worst first, the bubble last).
  List<int> eliminatedPlayerIds;

  int survivorsCount;

  /// True when players tied on score at the cutoff and speed decided it.
  bool tieBrokenBySpeed;

  /// True when this cut produced the finalists.
  bool finalistsDecided;

  /// Returns a shallow copy of this [EliminationEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EliminationEvent copyWith({
    int? round,
    List<int>? eliminatedPlayerIds,
    int? survivorsCount,
    bool? tieBrokenBySpeed,
    bool? finalistsDecided,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EliminationEvent',
      'round': round,
      'eliminatedPlayerIds': eliminatedPlayerIds.toJson(),
      'survivorsCount': survivorsCount,
      'tieBrokenBySpeed': tieBrokenBySpeed,
      'finalistsDecided': finalistsDecided,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EliminationEvent',
      'round': round,
      'eliminatedPlayerIds': eliminatedPlayerIds.toJson(),
      'survivorsCount': survivorsCount,
      'tieBrokenBySpeed': tieBrokenBySpeed,
      'finalistsDecided': finalistsDecided,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EliminationEventImpl extends EliminationEvent {
  _EliminationEventImpl({
    required int round,
    required List<int> eliminatedPlayerIds,
    required int survivorsCount,
    required bool tieBrokenBySpeed,
    required bool finalistsDecided,
  }) : super._(
         round: round,
         eliminatedPlayerIds: eliminatedPlayerIds,
         survivorsCount: survivorsCount,
         tieBrokenBySpeed: tieBrokenBySpeed,
         finalistsDecided: finalistsDecided,
       );

  /// Returns a shallow copy of this [EliminationEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EliminationEvent copyWith({
    int? round,
    List<int>? eliminatedPlayerIds,
    int? survivorsCount,
    bool? tieBrokenBySpeed,
    bool? finalistsDecided,
  }) {
    return EliminationEvent(
      round: round ?? this.round,
      eliminatedPlayerIds:
          eliminatedPlayerIds ??
          this.eliminatedPlayerIds.map((e0) => e0).toList(),
      survivorsCount: survivorsCount ?? this.survivorsCount,
      tieBrokenBySpeed: tieBrokenBySpeed ?? this.tieBrokenBySpeed,
      finalistsDecided: finalistsDecided ?? this.finalistsDecided,
    );
  }
}

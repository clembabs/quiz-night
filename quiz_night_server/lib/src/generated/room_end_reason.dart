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

/// Why a game ended.
enum RoomEndReason implements _is.SerializableModel {
  /// Played through to the podium.
  completed,

  /// The 30-minute game limit ran out; results stand where they were.
  timeUp,

  /// Nothing happened in the room for 30 minutes.
  inactive;

  static RoomEndReason fromJson(String name) {
    switch (name) {
      case 'completed':
        return RoomEndReason.completed;
      case 'timeUp':
        return RoomEndReason.timeUp;
      case 'inactive':
        return RoomEndReason.inactive;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "RoomEndReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

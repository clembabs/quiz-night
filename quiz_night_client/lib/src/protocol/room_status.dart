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

enum RoomStatus implements _isc.SerializableModel {
  lobby,
  question,
  reveal,
  elimination,
  tiebreak,
  buzzerFinal,
  finished;

  static RoomStatus fromJson(String name) {
    switch (name) {
      case 'lobby':
        return RoomStatus.lobby;
      case 'question':
        return RoomStatus.question;
      case 'reveal':
        return RoomStatus.reveal;
      case 'elimination':
        return RoomStatus.elimination;
      case 'tiebreak':
        return RoomStatus.tiebreak;
      case 'buzzerFinal':
        return RoomStatus.buzzerFinal;
      case 'finished':
        return RoomStatus.finished;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "RoomStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

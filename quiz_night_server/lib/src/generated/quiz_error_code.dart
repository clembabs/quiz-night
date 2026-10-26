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

enum QuizErrorCode implements _is.SerializableModel {
  roomNotFound,
  playerNotFound,
  notHost,
  invalidState,
  nicknameTaken,
  invalidInput,
  tooLate,
  alreadyAnswered,
  notAllowed,
  rateLimited,
  roomFull,
  roomLocked,
  aiUnavailable,
  generationFailed;

  static QuizErrorCode fromJson(String name) {
    switch (name) {
      case 'roomNotFound':
        return QuizErrorCode.roomNotFound;
      case 'playerNotFound':
        return QuizErrorCode.playerNotFound;
      case 'notHost':
        return QuizErrorCode.notHost;
      case 'invalidState':
        return QuizErrorCode.invalidState;
      case 'nicknameTaken':
        return QuizErrorCode.nicknameTaken;
      case 'invalidInput':
        return QuizErrorCode.invalidInput;
      case 'tooLate':
        return QuizErrorCode.tooLate;
      case 'alreadyAnswered':
        return QuizErrorCode.alreadyAnswered;
      case 'notAllowed':
        return QuizErrorCode.notAllowed;
      case 'rateLimited':
        return QuizErrorCode.rateLimited;
      case 'roomFull':
        return QuizErrorCode.roomFull;
      case 'roomLocked':
        return QuizErrorCode.roomLocked;
      case 'aiUnavailable':
        return QuizErrorCode.aiUnavailable;
      case 'generationFailed':
        return QuizErrorCode.generationFailed;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "QuizErrorCode"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}

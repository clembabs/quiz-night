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
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:quiz_night_client/src/protocol/answer_result.dart' as _ikiqe5uy;
import 'package:quiz_night_client/src/protocol/buzz_result.dart' as _i6x4qugu;
import 'package:quiz_night_client/src/protocol/create_room_result.dart'
    as _if7vktiw;
import 'package:quiz_night_client/src/protocol/join_result.dart' as _ik8s3h8i;
import 'package:quiz_night_client/src/protocol/room_config.dart' as _i2v75h2f;
import 'package:quiz_night_client/src/protocol/room_state.dart' as _inkt92gq;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAnswer extends _isc.EndpointRef {
  EndpointAnswer(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'answer';

  /// Active players score; eliminated players' answers count as shadow score.
  _ida.Future<_ikiqe5uy.AnswerResult> submitAnswer(
    String playerToken,
    int questionId,
    int choiceIndex,
  ) => caller.callServerEndpoint<_ikiqe5uy.AnswerResult>(
    'answer',
    'submitAnswer',
    {
      'playerToken': playerToken,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
    },
  );
}

/// The buzzer final.
/// {@category Endpoint}
class EndpointBuzzer extends _isc.EndpointRef {
  EndpointBuzzer(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'buzzer';

  /// Claims the buzzer; only the first valid buzz wins.
  _ida.Future<_i6x4qugu.BuzzResult> buzz(
    String playerToken,
    int questionId,
  ) => caller.callServerEndpoint<_i6x4qugu.BuzzResult>(
    'buzzer',
    'buzz',
    {
      'playerToken': playerToken,
      'questionId': questionId,
    },
  );

  /// Answers while holding the buzzer. Returns whether it was correct.
  _ida.Future<bool> submitBuzzAnswer(
    String playerToken,
    int questionId,
    int choiceIndex,
  ) => caller.callServerEndpoint<bool>(
    'buzzer',
    'submitBuzzAnswer',
    {
      'playerToken': playerToken,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
    },
  );

  /// An eliminated player picks the finalist they think will win.
  _ida.Future<void> backFinalist(
    String playerToken,
    int finalistId,
  ) => caller.callServerEndpoint<void>(
    'buzzer',
    'backFinalist',
    {
      'playerToken': playerToken,
      'finalistId': finalistId,
    },
  );
}

/// Room lifecycle. Host-only methods take the `hostToken` returned by
/// [createRoom]; the server rejects them without it.
/// {@category Endpoint}
class EndpointRoom extends _isc.EndpointRef {
  EndpointRoom(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'room';

  _ida.Future<_if7vktiw.CreateRoomResult> createRoom(
    _i2v75h2f.RoomConfig config,
  ) => caller.callServerEndpoint<_if7vktiw.CreateRoomResult>(
    'room',
    'createRoom',
    {'config': config},
  );

  _ida.Future<_ik8s3h8i.JoinResult> joinRoom(
    String code,
    String nickname,
  ) => caller.callServerEndpoint<_ik8s3h8i.JoinResult>(
    'room',
    'joinRoom',
    {
      'code': code,
      'nickname': nickname,
    },
  );

  /// Recovers a player's identity after a reload, using their stored token.
  _ida.Future<_ik8s3h8i.JoinResult> rejoin(
    String code,
    String playerToken,
  ) => caller.callServerEndpoint<_ik8s3h8i.JoinResult>(
    'room',
    'rejoin',
    {
      'code': code,
      'playerToken': playerToken,
    },
  );

  _ida.Future<void> startGame(
    String code,
    String hostToken,
  ) => caller.callServerEndpoint<void>(
    'room',
    'startGame',
    {
      'code': code,
      'hostToken': hostToken,
    },
  );

  _ida.Future<void> nextQuestion(
    String code,
    String hostToken,
  ) => caller.callServerEndpoint<void>(
    'room',
    'nextQuestion',
    {
      'code': code,
      'hostToken': hostToken,
    },
  );

  _ida.Future<void> reveal(
    String code,
    String hostToken,
  ) => caller.callServerEndpoint<void>(
    'room',
    'reveal',
    {
      'code': code,
      'hostToken': hostToken,
    },
  );

  /// Runs the elimination cut for the current round. Safe to call twice.
  _ida.Future<void> endRound(
    String code,
    String hostToken,
  ) => caller.callServerEndpoint<void>(
    'room',
    'endRound',
    {
      'code': code,
      'hostToken': hostToken,
    },
  );

  _ida.Future<void> useWildcard(
    String code,
    String hostToken,
    int playerId,
  ) => caller.callServerEndpoint<void>(
    'room',
    'useWildcard',
    {
      'code': code,
      'hostToken': hostToken,
      'playerId': playerId,
    },
  );

  /// Live room updates. The first event is always a full snapshot, so
  /// re-subscribing after a disconnect restores the client's view.
  _ida.Stream<_inkt92gq.RoomState> watchRoom(String code) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_inkt92gq.RoomState>,
        _inkt92gq.RoomState
      >(
        'room',
        'watchRoom',
        {'code': code},
        {},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    answer = EndpointAnswer(this);
    buzzer = EndpointBuzzer(this);
    room = EndpointRoom(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAnswer answer;

  late final EndpointBuzzer buzzer;

  late final EndpointRoom room;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'answer': answer,
    'buzzer': buzzer,
    'room': room,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}

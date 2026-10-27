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
import 'package:quiz_night_server/src/generated/question_difficulty.dart'
    as _i4ozqmvk;
import 'package:quiz_night_server/src/generated/room_config.dart' as _i3izb6ro;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/answer_endpoint.dart' as _iytsf7o6;
import '../endpoints/buzzer_endpoint.dart' as _ikgggm1x;
import '../endpoints/diagnostics_endpoint.dart' as _i9j3ee4w;
import '../endpoints/questions_endpoint.dart' as _ixz1m1z5;
import '../endpoints/room_endpoint.dart' as _io7erjyw;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'answer': _iytsf7o6.AnswerEndpoint()
        ..initialize(
          server,
          'answer',
          null,
        ),
      'buzzer': _ikgggm1x.BuzzerEndpoint()
        ..initialize(
          server,
          'buzzer',
          null,
        ),
      'diagnostics': _i9j3ee4w.DiagnosticsEndpoint()
        ..initialize(
          server,
          'diagnostics',
          null,
        ),
      'questions': _ixz1m1z5.QuestionsEndpoint()
        ..initialize(
          server,
          'questions',
          null,
        ),
      'room': _io7erjyw.RoomEndpoint()
        ..initialize(
          server,
          'room',
          null,
        ),
    };
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['answer'] = _is.EndpointConnector(
      name: 'answer',
      endpoint: endpoints['answer']!,
      methodConnectors: {
        'submitAnswer': _is.MethodConnector(
          name: 'submitAnswer',
          params: {
            'playerToken': _is.ParameterDescription(
              name: 'playerToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'questionId': _is.ParameterDescription(
              name: 'questionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'choiceIndex': _is.ParameterDescription(
              name: 'choiceIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['answer'] as _iytsf7o6.AnswerEndpoint)
                  .submitAnswer(
                    session,
                    params['playerToken'],
                    params['questionId'],
                    params['choiceIndex'],
                  ),
        ),
      },
    );
    connectors['buzzer'] = _is.EndpointConnector(
      name: 'buzzer',
      endpoint: endpoints['buzzer']!,
      methodConnectors: {
        'buzz': _is.MethodConnector(
          name: 'buzz',
          params: {
            'playerToken': _is.ParameterDescription(
              name: 'playerToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'questionId': _is.ParameterDescription(
              name: 'questionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['buzzer'] as _ikgggm1x.BuzzerEndpoint).buzz(
                session,
                params['playerToken'],
                params['questionId'],
              ),
        ),
        'submitBuzzAnswer': _is.MethodConnector(
          name: 'submitBuzzAnswer',
          params: {
            'playerToken': _is.ParameterDescription(
              name: 'playerToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'questionId': _is.ParameterDescription(
              name: 'questionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'choiceIndex': _is.ParameterDescription(
              name: 'choiceIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['buzzer'] as _ikgggm1x.BuzzerEndpoint)
                  .submitBuzzAnswer(
                    session,
                    params['playerToken'],
                    params['questionId'],
                    params['choiceIndex'],
                  ),
        ),
        'backFinalist': _is.MethodConnector(
          name: 'backFinalist',
          params: {
            'playerToken': _is.ParameterDescription(
              name: 'playerToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'finalistId': _is.ParameterDescription(
              name: 'finalistId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['buzzer'] as _ikgggm1x.BuzzerEndpoint)
                  .backFinalist(
                    session,
                    params['playerToken'],
                    params['finalistId'],
                  ),
        ),
      },
    );
    connectors['diagnostics'] = _is.EndpointConnector(
      name: 'diagnostics',
      endpoint: endpoints['diagnostics']!,
      methodConnectors: {
        'reportError': _is.MethodConnector(
          name: 'reportError',
          params: {
            'message': _is.ParameterDescription(
              name: 'message',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'stackTrace': _is.ParameterDescription(
              name: 'stackTrace',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'route': _is.ParameterDescription(
              name: 'route',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['diagnostics'] as _i9j3ee4w.DiagnosticsEndpoint)
                      .reportError(
                        session,
                        params['message'],
                        params['stackTrace'],
                        params['route'],
                      ),
        ),
      },
    );
    connectors['questions'] = _is.EndpointConnector(
      name: 'questions',
      endpoint: endpoints['questions']!,
      methodConnectors: {
        'aiAvailable': _is.MethodConnector(
          name: 'aiAvailable',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['questions'] as _ixz1m1z5.QuestionsEndpoint)
                  .aiAvailable(session),
        ),
        'generatePack': _is.MethodConnector(
          name: 'generatePack',
          params: {
            'topic': _is.ParameterDescription(
              name: 'topic',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'difficulty': _is.ParameterDescription(
              name: 'difficulty',
              type: _is.getType<_i4ozqmvk.QuestionDifficulty>(),
              nullable: false,
            ),
            'questionCount': _is.ParameterDescription(
              name: 'questionCount',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'config': _is.ParameterDescription(
              name: 'config',
              type: _is.getType<_i3izb6ro.RoomConfig>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['questions'] as _ixz1m1z5.QuestionsEndpoint)
                  .generatePack(
                    session,
                    params['topic'],
                    params['difficulty'],
                    params['questionCount'],
                    params['config'],
                  ),
        ),
        'removePackQuestion': _is.MethodConnector(
          name: 'removePackQuestion',
          params: {
            'packId': _is.ParameterDescription(
              name: 'packId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'packToken': _is.ParameterDescription(
              name: 'packToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'questionId': _is.ParameterDescription(
              name: 'questionId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'config': _is.ParameterDescription(
              name: 'config',
              type: _is.getType<_i3izb6ro.RoomConfig>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['questions'] as _ixz1m1z5.QuestionsEndpoint)
                  .removePackQuestion(
                    session,
                    params['packId'],
                    params['packToken'],
                    params['questionId'],
                    params['config'],
                  ),
        ),
      },
    );
    connectors['room'] = _is.EndpointConnector(
      name: 'room',
      endpoint: endpoints['room']!,
      methodConnectors: {
        'createRoom': _is.MethodConnector(
          name: 'createRoom',
          params: {
            'config': _is.ParameterDescription(
              name: 'config',
              type: _is.getType<_i3izb6ro.RoomConfig>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).createRoom(
                    session,
                    params['config'],
                  ),
        ),
        'joinRoom': _is.MethodConnector(
          name: 'joinRoom',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'nickname': _is.ParameterDescription(
              name: 'nickname',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['room'] as _io7erjyw.RoomEndpoint).joinRoom(
                session,
                params['code'],
                params['nickname'],
              ),
        ),
        'rejoin': _is.MethodConnector(
          name: 'rejoin',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'playerToken': _is.ParameterDescription(
              name: 'playerToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['room'] as _io7erjyw.RoomEndpoint).rejoin(
                session,
                params['code'],
                params['playerToken'],
              ),
        ),
        'startGame': _is.MethodConnector(
          name: 'startGame',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).startGame(
                    session,
                    params['code'],
                    params['hostToken'],
                  ),
        ),
        'nextQuestion': _is.MethodConnector(
          name: 'nextQuestion',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).nextQuestion(
                    session,
                    params['code'],
                    params['hostToken'],
                  ),
        ),
        'reveal': _is.MethodConnector(
          name: 'reveal',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['room'] as _io7erjyw.RoomEndpoint).reveal(
                session,
                params['code'],
                params['hostToken'],
              ),
        ),
        'endRound': _is.MethodConnector(
          name: 'endRound',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['room'] as _io7erjyw.RoomEndpoint).endRound(
                session,
                params['code'],
                params['hostToken'],
              ),
        ),
        'useWildcard': _is.MethodConnector(
          name: 'useWildcard',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).useWildcard(
                    session,
                    params['code'],
                    params['hostToken'],
                    params['playerId'],
                  ),
        ),
        'setLocked': _is.MethodConnector(
          name: 'setLocked',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'locked': _is.ParameterDescription(
              name: 'locked',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).setLocked(
                    session,
                    params['code'],
                    params['hostToken'],
                    params['locked'],
                  ),
        ),
        'removePlayer': _is.MethodConnector(
          name: 'removePlayer',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hostToken': _is.ParameterDescription(
              name: 'hostToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['room'] as _io7erjyw.RoomEndpoint).removePlayer(
                    session,
                    params['code'],
                    params['hostToken'],
                    params['playerId'],
                  ),
        ),
        'watchRoom': _is.MethodStreamConnector(
          name: 'watchRoom',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['room'] as _io7erjyw.RoomEndpoint).watchRoom(
                session,
                params['code'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}

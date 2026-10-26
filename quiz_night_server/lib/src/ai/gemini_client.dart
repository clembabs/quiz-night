import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'question_generator.dart';

/// Asks Gemini for JSON in a given schema, with a backup model.
class GeminiClient {
  final String apiKey;

  /// Tried in order; on 5xx, 429, timeout or no connection, the next one.
  final List<String> models;

  /// Per model, so the backup still has time.
  final Duration timeout;
  final GeminiPost _post;

  GeminiClient({
    required this.apiKey,
    required this.models,
    required this.timeout,
    GeminiPost? post,
  }) : _post = post ?? httpsPost;

  /// The request body for [instructions] (the system prompt) and [text].
  static Map<String, Object?> body({
    required String instructions,
    required String text,
    required Map<String, Object?> schema,
  }) => {
    'systemInstruction': {
      'parts': [
        {'text': instructions},
      ],
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': text},
        ],
      },
    ],
    'generationConfig': {
      'responseMimeType': 'application/json',
      'responseSchema': schema,
      'thinkingConfig': {'thinkingLevel': 'low'},
    },
  };

  /// The decoded JSON the model returned; [GenerationRefused] or
  /// [GenerationFailed] when there is none.
  Future<Object?> generateJson(Map<String, Object?> body) async {
    GenerationFailed? last;
    for (final model in models) {
      try {
        return await _ask(model, body);
      } on _TryNext catch (e) {
        last = GenerationFailed(e.reason);
      }
    }
    throw last ?? const GenerationFailed('no models');
  }

  /// One model, once. [_TryNext] for failures another model might not have.
  Future<Object?> _ask(String model, Map<String, Object?> body) async {
    final ({int status, String body}) res;
    try {
      res = await _post(
        Uri.https(
          'generativelanguage.googleapis.com',
          '/v1beta/models/$model:generateContent',
        ),
        {'x-goog-api-key': apiKey},
        jsonEncode(body),
      ).timeout(timeout);
    } on TimeoutException {
      throw const _TryNext('timeout');
    } on SocketException {
      throw const _TryNext('network');
    }
    if (res.status == 429) throw const _TryNext('quota');
    if (res.status >= 500) throw _TryNext('http ${res.status}');
    if (res.status != 200) throw GenerationFailed('http ${res.status}');
    return replyJson(res.body);
  }

  /// The JSON inside a Gemini reply; throws if blocked or unusable.
  static Object? replyJson(String body) {
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      throw const GenerationFailed('reply is not JSON');
    }
    if (json is! Map) throw const GenerationFailed('unexpected reply');
    final blocked = (json['promptFeedback'] as Map?)?['blockReason'];
    if (blocked != null) throw GenerationRefused('$blocked');
    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GenerationFailed('no candidates');
    }
    final first = candidates.first as Map;
    final finish = first['finishReason'];
    if (finish == 'SAFETY' || finish == 'PROHIBITED_CONTENT') {
      throw GenerationRefused('$finish');
    }
    final parts = (first['content'] as Map?)?['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const GenerationFailed('empty reply');
    }
    final text = parts
        .whereType<Map>()
        .map((p) => p['text'])
        .whereType<String>()
        .join();
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const GenerationFailed('content is not JSON');
    }
  }
}

/// A failure worth trying the next model for.
class _TryNext implements Exception {
  final String reason;
  const _TryNext(this.reason);
}

/// Sends a JSON POST and returns the status and body; replaceable in tests.
typedef GeminiPost =
    Future<({int status, String body})> Function(
      Uri uri,
      Map<String, String> headers,
      String body,
    );

/// [GeminiPost] over dart:io.
Future<({int status, String body})> httpsPost(
  Uri uri,
  Map<String, String> headers,
  String body,
) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(uri);
    headers.forEach(req.headers.set);
    req.headers.contentType = ContentType.json;
    req.write(body);
    final res = await req.close();
    return (
      status: res.statusCode,
      body: await res.transform(utf8.decoder).join(),
    );
  } finally {
    client.close(force: true);
  }
}

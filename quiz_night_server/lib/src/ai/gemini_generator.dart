import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'question_generator.dart';
import 'question_prompt.dart';

/// [QuestionGenerator] on Google's Gemini API, with structured output so the
/// reply is always the JSON shape below. Plain HTTPS: no extra package.
class GeminiQuestionGenerator implements QuestionGenerator {
  final String apiKey;

  /// Tried in order: when one is busy (5xx), out of quota (429), slow or
  /// unreachable, the next one gets the request. Flash writes the best
  /// questions; Flash-Lite is the fast backup. Both run with thinking kept
  /// low; newer Flash models were too slow for a host waiting to start.
  final List<String> models;

  /// Per model, so the backup still has time.
  final Duration timeout;
  final GeminiPost _post;

  GeminiQuestionGenerator({
    required this.apiKey,
    this.models = const ['gemini-3.5-flash', 'gemini-3.1-flash-lite'],
    this.timeout = const Duration(seconds: 25),
    GeminiPost? post,
  }) : _post = post ?? httpsPost;

  static const _schema = {
    'type': 'OBJECT',
    'properties': {
      'questions': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'text': {'type': 'STRING'},
            'options': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
            'correctIndex': {'type': 'INTEGER'},
            'final': {'type': 'BOOLEAN'},
          },
          'required': ['text', 'options', 'correctIndex', 'final'],
        },
      },
    },
    'required': ['questions'],
  };

  /// The request body; for tests.
  static Map<String, Object?> requestBody(GenerationRequest request) => {
    'systemInstruction': {
      'parts': [
        {'text': questionWriterInstructions},
      ],
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': questionRequestText(request)},
        ],
      },
    ],
    'generationConfig': {
      'responseMimeType': 'application/json',
      'responseSchema': _schema,
      'thinkingConfig': {'thinkingLevel': 'low'},
    },
  };

  @override
  Future<List<DraftQuestion>> generate(GenerationRequest request) async {
    GenerationFailed? last;
    for (final model in models) {
      try {
        return await _ask(model, request);
      } on _TryNext catch (e) {
        last = GenerationFailed(e.reason);
      }
    }
    throw last ?? const GenerationFailed('no models');
  }

  /// One model, once. Throws [_TryNext] for failures another model might
  /// not have; anything else (a refusal, a bad request) ends the attempt.
  Future<List<DraftQuestion>> _ask(
    String model,
    GenerationRequest request,
  ) async {
    final ({int status, String body}) res;
    try {
      res = await _post(
        Uri.https(
          'generativelanguage.googleapis.com',
          '/v1beta/models/$model:generateContent',
        ),
        {'x-goog-api-key': apiKey},
        jsonEncode(requestBody(request)),
      ).timeout(timeout);
    } on TimeoutException {
      throw const _TryNext('timeout');
    } on SocketException {
      throw const _TryNext('network');
    }
    if (res.status == 429) throw const _TryNext('quota');
    if (res.status >= 500) throw _TryNext('http ${res.status}');
    if (res.status != 200) throw GenerationFailed('http ${res.status}');
    return parseResponse(res.body);
  }

  /// Reads a generateContent reply. Throws [GenerationRefused] when the
  /// topic was blocked, [GenerationFailed] when the reply is unusable.
  static List<DraftQuestion> parseResponse(String body) {
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
    final Object? data;
    try {
      data = jsonDecode(text);
    } on FormatException {
      throw const GenerationFailed('questions are not JSON');
    }
    final list = data is Map ? data['questions'] : null;
    if (list is! List) throw const GenerationFailed('no questions list');
    return [
      for (final q in list.whereType<Map>())
        if (q['text'] is String &&
            q['options'] is List &&
            q['correctIndex'] is int)
          DraftQuestion(
            text: q['text'] as String,
            options: (q['options'] as List).whereType<String>().toList(),
            correctIndex: q['correctIndex'] as int,
            isFinal: q['final'] == true,
          ),
    ];
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

import 'gemini_client.dart';
import 'question_generator.dart';
import 'question_prompt.dart';

export 'gemini_client.dart' show GeminiPost;

/// Gemini-backed [QuestionGenerator]: structured JSON output, plain HTTPS.
class GeminiQuestionGenerator implements QuestionGenerator {
  final GeminiClient _gemini;

  /// Flash-Lite is the fast backup; low thinking (newer Flash too slow).
  GeminiQuestionGenerator({
    required String apiKey,
    List<String> models = const ['gemini-3.5-flash', 'gemini-3.1-flash-lite'],
    Duration timeout = const Duration(seconds: 25),
    GeminiPost? post,
  }) : _gemini = GeminiClient(
         apiKey: apiKey,
         models: models,
         timeout: timeout,
         post: post,
       );

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
  static Map<String, Object?> requestBody(GenerationRequest request) =>
      GeminiClient.body(
        instructions: questionWriterInstructions,
        text: questionRequestText(request),
        schema: _schema,
      );

  @override
  Future<List<DraftQuestion>> generate(GenerationRequest request) async =>
      _questions(await _gemini.generateJson(requestBody(request)));

  /// Parses a reply; throws [GenerationRefused] or [GenerationFailed].
  static List<DraftQuestion> parseResponse(String body) =>
      _questions(GeminiClient.replyJson(body));

  static List<DraftQuestion> _questions(Object? data) {
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

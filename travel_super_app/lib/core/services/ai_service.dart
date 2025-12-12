import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  AIService() : _apiKey = dotenv.env['OPENAI_API_KEY'] {
    final key = _apiKey;
    if (key != null && key.isNotEmpty) {
      OpenAI.apiKey = key;
    }
  }

  final String? _apiKey;

  bool get _isConfigured => _apiKey?.isNotEmpty ?? false;

  Future<String> surpriseRouteSuggestion({required String context}) async {
    if (!_isConfigured) {
      return 'Add your OpenAI API key to .env to enable AI suggestions.';
    }

    final response = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'You are a helpful Iceland travel concierge focused on weather-aware, safe itineraries.',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(context),
          ],
        ),
      ],
      maxTokens: 300,
      temperature: 0.7,
    );

    return response.choices.first.message.content?.first.text?.trim() ??
        'No suggestion available yet.';
  }
}

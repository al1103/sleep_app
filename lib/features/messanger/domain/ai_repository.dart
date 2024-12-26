// ai_repository.dart
import 'package:sleep/features/messanger/domain/ai_response.dart';

abstract class AIRepository {
  Future<AIResponse> getChatSuggestions();

  Future<AIImageResponse> getImageAnalysis(String imageBase64, String prompt);

  Future<AIResponse> getPromptAnswer(String prompt);
}

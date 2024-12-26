// ai_repository_impl.dart
import 'package:deep_pick/deep_pick.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_service.dart';
import 'package:sleep/features/messanger/domain/ai_repository.dart';
import 'package:sleep/features/messanger/domain/ai_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_repository_impl.g.dart';

@Riverpod(keepAlive: true)
class AIRepositoryProvider extends _$AIRepositoryProvider {
  @override
  AIRepository build() {
    return AIRepositoryImpl(ref.watch(apiServiceProvider));
  }
}

class AIRepositoryImpl implements AIRepository {
  AIRepositoryImpl(this._apiService);
  final ApiService _apiService;

  @override
  Future<AIResponse> getChatSuggestions() async {
    try {
      final response = await _apiService.requestPost(
        '/ai/chat',
        {},
        responseFactory: (json) {
          final data = pick(json).asMapOrEmpty<String, dynamic>();
          return AIResponse.fromJson(data);
        },
      );
      return response;
    } on Exception catch (e) {
      throw Exception('Failed to get chat suggestions: $e');
    }
  }

  @override
  Future<AIImageResponse> getImageAnalysis(
      String imageBase64, String prompt,) async {
    try {
      final response = await _apiService.requestPost(
        '/ai/image-prompt',
        {
          'image': imageBase64,
          'prompt': prompt,
        },
        responseFactory: (json) {
          final data = pick(json).asMapOrEmpty<String, dynamic>();
          return AIImageResponse.fromJson(data);
        },
      );
      return response;
    } on Exception catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  @override
  Future<AIResponse> getPromptAnswer(String prompt) async {
    try {
      final response = await _apiService.requestPost(
        '/ai/promptAnswer',
        {'prompt': prompt},
        responseFactory: (json) {
          final data = pick(json).asMapOrEmpty<String, dynamic>();
          return AIResponse.fromJson(data);
        },
      );
      return response;
    } on Exception catch (e) {
      throw Exception('Failed to get prompt answer: $e');
    }
  }
}

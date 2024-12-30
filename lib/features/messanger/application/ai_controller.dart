// ai_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sleep/features/messanger/domain/ai_repository_impl.dart';
import 'package:sleep/features/messanger/domain/ai_response.dart';

part 'ai_controller.g.dart';

@riverpod
class AIController extends _$AIController {
  @override
  Future<AIResponse?> build() async => null;

  FutureOr<AIResponse?> getChatSuggestions() async {
    final response =
        ref.read(aIRepositoryProviderProvider).getChatSuggestions();
    return response;
  }

  // Future<String> analyzeImage(String imageBase64, String prompt) async {
  //   state = const AsyncValue.loading();

  //   state = await AsyncValue.guard(() async {
  //     final repository = ref.read(aIRepositoryProviderProvider);
  //     final response = await repository.getImageAnalysis(imageBase64, prompt);

  //     if (response.message?.isEmpty ?? true) {
  //       throw Exception('No analysis generated');
  //     }
  //   });

  //   return state.value?.message ?? '';
  // }

  Future<String> getPromptAnswer(String prompt) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(aIRepositoryProviderProvider);
      final response = await repository.getPromptAnswer(prompt);

      if (response.status != 200) {
        throw Exception(response.message ?? 'Failed to get answer');
      }

      return response;
    });

    return state.value?.answer ?? '';
  }
}

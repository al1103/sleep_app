import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'suggestions') List<String>? suggestions,
    @JsonKey(name: 'answer') String? answer,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'data') List<AIData>? data,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}

@freezed
class AIImageResponse with _$AIImageResponse {
  const factory AIImageResponse({
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'generatedText') String? generatedText,
  }) = _AIImageResponse;

  factory AIImageResponse.fromJson(Map<String, dynamic> json) =>
      _$AIImageResponseFromJson(json);
}

@freezed
class AIData with _$AIData {
  const factory AIData({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'text') String? text,
    @JsonKey(name: 'type') String? type,
  }) = _AIData;

  factory AIData.fromJson(Map<String, dynamic> json) => _$AIDataFromJson(json);
}

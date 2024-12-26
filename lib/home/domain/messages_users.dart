import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_users.freezed.dart';
part 'messages_users.g.dart';

@freezed
class GetMessages with _$GetMessages {
  const factory GetMessages({
    @JsonKey(name: 'UserID') String? userId,
    @JsonKey(name: 'Username') String? username,
    @JsonKey(name: 'Avatar') dynamic avatar,
    @JsonKey(name: 'LastMessage') String? lastMessage,
    @JsonKey(name: 'LastMessageTime') DateTime? lastMessageTime,
  }) = _GetMessages;

  factory GetMessages.fromJson(Map<String, dynamic> json) =>
      _$GetMessagesFromJson(json);
}

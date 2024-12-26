import 'package:sleep/home/domain/messages_users.dart';
import 'package:sleep/home/infrastructure/messages_users_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_users_controller.g.dart';

@riverpod
class MessagesUsersController extends _$MessagesUsersController {
  @override
  Future<List<GetMessages>> build(String id) async {
    final result =
        await ref.read(messagesUsersRepositoryProvider).getMessagesUsers(id);
    return result;
  }
}

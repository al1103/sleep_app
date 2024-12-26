import 'package:sleep/home/domain/messages_users.dart';

mixin MessagesUsersRepository {
  Future<List<GetMessages>> getMessagesUsers(String id);
}

import 'package:deep_pick/deep_pick.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_service.dart';
import 'package:sleep/home/application/messages_users_repository.dart';
import 'package:sleep/home/domain/messages_users.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_users_repository_impl.g.dart';

class MessagesUsersRepositoryImpl implements MessagesUsersRepository {
  MessagesUsersRepositoryImpl(this.apiService);

  final ApiService apiService;

  @override
  Future<List<GetMessages>> getMessagesUsers(String id) async {
    return apiService.requestGet(
      '/messages/user/$id',
      {},
      responseFactory: (json) {
        final listNewCourse = <GetMessages>[];
        final data = json['data'] as List<dynamic>;
        for (final e in data) {
          try {
            final message = GetMessages.fromJson(pick(e).asMapOrEmpty());
            listNewCourse.add(message);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }
        return listNewCourse;
      },
    );
  }
}

@Riverpod(keepAlive: true)
MessagesUsersRepository messagesUsersRepository(
  MessagesUsersRepositoryRef ref,
) =>
    MessagesUsersRepositoryImpl(ref.read(apiServiceProvider));

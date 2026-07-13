import '../models/user.dart';
import 'user_repository.dart';

class InMemoryUserRepository implements UserRepository {
  final List<UserModel> _users = <UserModel>[];

  Future<List<UserModel>> getAllUsers() async {
    return List<UserModel>.from(_users);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    return getAllUsers();
  }

  @override
  Future<void> addUser(UserModel user) async {
    final userToAdd =
        user.id <= 0 ? user.copyWith(id: _generateNextId()) : user;
    _users.add(userToAdd);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      return;
    }

    _users[index] = user;
  }

  @override
  Future<void> deleteUser(int id) async {
    _users.removeWhere((user) => user.id == id);
  }

  int _generateNextId() {
    if (_users.isEmpty) {
      return 1;
    }

    var maxId = _users.first.id;
    for (final user in _users.skip(1)) {
      if (user.id > maxId) {
        maxId = user.id;
      }
    }

    return maxId + 1;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../repositories/in_memory_user_repository.dart';
import '../repositories/user_repository.dart';

class UserState {
  final List<UserModel> items;
  final bool isLoading;

  const UserState({
    this.items = const <UserModel>[],
    this.isLoading = false,
  });

  UserState copyWith({
    List<UserModel>? items,
    bool? isLoading,
  }) {
    return UserState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserViewModel extends StateNotifier<UserState> {
  UserViewModel(this.repository) : super(const UserState(isLoading: true)) {
    loadUsers();
  }

  final UserRepository repository;
  int _loadVersion = 0;

  Future<void> loadUsers() async {
    final version = ++_loadVersion;
    state = state.copyWith(isLoading: true);
    final users = await repository.getUsers();
    if (version != _loadVersion) {
      return;
    }

    state = state.copyWith(
      items: users,
      isLoading: false,
    );
  }

  Future<void> addUser(UserModel user) async {
    final version = ++_loadVersion;
    await repository.addUser(user);
    final users = await repository.getUsers();
    if (version != _loadVersion) {
      return;
    }

    state = state.copyWith(
      items: users,
      isLoading: false,
    );
  }

  Future<void> updateUser(UserModel user) async {
    await repository.updateUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await repository.deleteUser(id);
    await loadUsers();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return InMemoryUserRepository();
});

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  return UserViewModel(ref.watch(userRepositoryProvider));
});

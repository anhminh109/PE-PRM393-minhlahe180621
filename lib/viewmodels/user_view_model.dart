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
    // TODO: Trả về UserState mới, field nào null thì giữ giá trị hiện tại.
    return this;
  }
}

class UserViewModel extends StateNotifier<UserState> {
  UserViewModel(this.repository) : super(const UserState(isLoading: true)) {
    loadUsers();
  }

  final UserRepository repository;

  Future<void> loadUsers() async {
    // TODO: Gọi repository.getUsers(), cập nhật state.items và isLoading=false.
    state = const UserState(isLoading: false);
  }

  Future<void> addUser({
    required String fullName,
    required String email,
    required String avatar,
  }) async {
    // TODO:
    // 1. Tính id mới = danh sách rỗng ? 1 : max(id hiện có) + 1.
    // 2. Tạo UserModel mới.
    // 3. Gọi repository.addUser.
    // 4. Cập nhật state để UI render lại.
  }

  Future<void> updateUser(UserModel user) async {
    // TODO: Gọi repository.updateUser và cập nhật đúng phần tử theo id trong state.
  }

  Future<void> deleteUser(int id) async {
    // TODO: Gọi repository.deleteUser và xoá đúng phần tử theo id trong state.
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return InMemoryUserRepository();
});

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  return UserViewModel(ref.watch(userRepositoryProvider));
});

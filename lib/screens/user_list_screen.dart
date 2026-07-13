import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../viewmodels/user_view_model.dart';
import '../widgets/avatar_image.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();

  UserModel? _editingUser;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);
    final users = state.items;

    return Scaffold(
      appBar: AppBar(title: const Text('User Manager')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              _buildForm(),
              const SizedBox(height: 12),
              Expanded(
                child: _buildUserList(users),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: const Key('input_fullname'),
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              hintText: 'Nhập họ và tên',
              border: OutlineInputBorder(),
            ),
            validator: _validateFullName,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('input_email'),
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'example@gmail.com',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('input_avatar'),
            controller: _avatarController,
            decoration: const InputDecoration(
              labelText: 'Avatar',
              hintText: defaultAvatarPath,
              border: OutlineInputBorder(),
            ),
            validator: _validateAvatar,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  key: const Key('btn_add_user'),
                  onPressed: _handleSubmit,
                  child:
                      Text(_editingUser == null ? 'ADD USER' : 'UPDATE USER'),
                ),
              ),
              if (_editingUser != null) ...<Widget>[
                const SizedBox(width: 8),
                OutlinedButton(
                  key: const Key('btn_cancel_edit'),
                  onPressed: _cancelEdit,
                  child: const Text('CANCEL'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        key: Key('user_list'),
        child: Text('Chưa có người dùng'),
      );
    }

    return ListView.builder(
      key: const Key('user_list'),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserItem(users[index]);
      },
    );
  }

  Widget _buildUserItem(UserModel user) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            AvatarImage(
              key: Key('user_item_avatar_${user.id}'),
              avatar: user.avatar,
              radius: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    user.fullName,
                    key: Key('user_item_fullname_${user.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    key: Key('user_item_email_${user.id}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('user_item_edit_${user.id}'),
              icon: const Icon(Icons.edit),
              onPressed: () => _startEdit(user),
              visualDensity: VisualDensity.compact,
              tooltip: 'Sửa',
            ),
            IconButton(
              key: Key('user_item_delete_${user.id}'),
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(user),
              visualDensity: VisualDensity.compact,
              tooltip: 'Xoá',
            ),
          ],
        ),
      ),
    );
  }

  String? _validateFullName(String? value) {
    final fullName = value?.trim() ?? '';
    if (fullName.isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (fullName.length < 2) {
      return 'Họ và tên tối thiểu 2 ký tự';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email không được để trống';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email không đúng định dạng';
    }

    return null;
  }

  String? _validateAvatar(String? value) {
    final avatar = value?.trim() ?? '';
    if (avatar.isEmpty) {
      return 'Avatar không được để trống';
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final editingUser = _editingUser;
    if (editingUser == null) {
      final user = UserModel(
        id: 0,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        avatar: _avatarController.text.trim(),
      );

      await ref.read(userViewModelProvider.notifier).addUser(user);
    } else {
      final user = editingUser.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        avatar: _avatarController.text.trim(),
      );

      await ref.read(userViewModelProvider.notifier).updateUser(user);
    }

    if (!mounted) {
      return;
    }

    _clearForm();
  }

  void _startEdit(UserModel user) {
    _formKey.currentState?.reset();
    setState(() {
      _editingUser = user;
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _avatarController.text = user.avatar;
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  Future<void> _confirmDelete(UserModel user) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('delete_confirm_dialog'),
          title: const Text('Delete User'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa người dùng này không?',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('btn_cancel_delete'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('btn_confirm_delete'),
              onPressed: () async {
                await ref
                    .read(userViewModelProvider.notifier)
                    .deleteUser(user.id);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _fullNameController.clear();
      _emailController.clear();
      _avatarController.clear();
      _editingUser = null;
    });
  }
}

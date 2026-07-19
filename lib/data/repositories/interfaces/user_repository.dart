import '../../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser();
  Future<UserModel> createDefaultUser({required String name});
}

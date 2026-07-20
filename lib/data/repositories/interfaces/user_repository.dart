import '../../models/user_model.dart';
import '../../../core/enums/stat_type.dart';

abstract class UserRepository {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser();
  Future<UserModel> createDefaultUser({
    required String name,
    int age = 18,
    double height = 170,
    double weight = 70,
    String fitnessLevel = 'Beginner',
    StatType? preferredFocus,
  });
}

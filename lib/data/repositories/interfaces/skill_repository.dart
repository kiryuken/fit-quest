import '../../models/skill_model.dart';

abstract class SkillRepository {
  Future<List<SkillModel>> getAllSkills();
  Future<SkillModel?> getSkill(String id);
  Future<List<SkillModel>> getSkillsByMartialArt(int martialArtIndex);
  Future<void> saveSkill(SkillModel skill);
  Future<void> seedDefaultSkills();
}

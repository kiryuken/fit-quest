import '../../datasources/hive_datasource.dart';
import '../../models/skill_model.dart';
import '../../skill_catalog.dart';
import '../interfaces/skill_repository.dart';

class SkillRepositoryImpl implements SkillRepository {
  final HiveDatasource _datasource;
  SkillRepositoryImpl(this._datasource);

  @override
  Future<List<SkillModel>> getAllSkills() async {
    final skills = _datasource.skillsBox.values.toList();
    if (skills.isEmpty) {
      await seedDefaultSkills();
      return _datasource.skillsBox.values.toList();
    }
    return skills;
  }

  @override
  Future<SkillModel?> getSkill(String id) async {
    return _datasource.skillsBox.get(id);
  }

  @override
  Future<List<SkillModel>> getSkillsByMartialArt(int martialArtIndex) async {
    final all = await getAllSkills();
    return all.where((s) => s.martialArtIndex == martialArtIndex).toList();
  }

  @override
  Future<void> saveSkill(SkillModel skill) async {
    await _datasource.skillsBox.put(skill.id, skill);
  }

  @override
  Future<void> seedDefaultSkills() async {
    if (_datasource.skillsBox.isNotEmpty) return;

    final catalog = SkillCatalog.allSkills();
    for (final skill in catalog) {
      await _datasource.skillsBox.put(skill.id, skill);
    }
  }
}

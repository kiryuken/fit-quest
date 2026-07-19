import '../../datasources/hive_datasource.dart';
import '../../models/boss_battle_model.dart';
import '../interfaces/boss_repository.dart';

class BossRepositoryImpl implements BossRepository {
  final HiveDatasource _datasource;
  BossRepositoryImpl(this._datasource);

  @override
  Future<List<BossBattleModel>> getAllBosses() async {
    return _datasource.bossesBox.values.toList();
  }

  @override
  Future<BossBattleModel?> getBoss(String id) async {
    return _datasource.bossesBox.get(id);
  }

  @override
  Future<void> saveBoss(BossBattleModel boss) async {
    await _datasource.bossesBox.put(boss.id, boss);
  }

  @override
  Future<void> seedDefaultBosses() async {
    if (_datasource.bossesBox.isNotEmpty) return;
    final defaultBosses = [
      BossBattleModel(
        id: 'boss_training_dummy',
        name: 'Training Dummy',
        description: 'A sturdy training dummy. Perfect for beginners to test their skills.',
        level: 1, hp: 50, xpReward: 50,
        requiredWorkouts: 0, tierIndex: 0, difficulty: 1,
        statThresholds: {0: 5}, // STR >= 5
      ),
      BossBattleModel(
        id: 'boss_shadow_fighter',
        name: 'Shadow Fighter',
        description: 'A mysterious fighter who moves like a shadow. Tests agility and speed.',
        level: 5, hp: 150, xpReward: 200,
        requiredWorkouts: 5, tierIndex: 1, difficulty: 2,
        statThresholds: {1: 8}, // AGI >= 8
      ),
      BossBattleModel(
        id: 'boss_iron_titan',
        name: 'Iron Titan',
        description: 'A massive golem made of iron. Brute force is needed to crack its armor.',
        level: 10, hp: 400, xpReward: 500,
        requiredWorkouts: 15, tierIndex: 2, difficulty: 3,
        statThresholds: {0: 15, 4: 12}, // STR >= 15, CON >= 12
      ),
      BossBattleModel(
        id: 'boss_storm_monk',
        name: 'Storm Monk',
        description: 'A legendary monk who fights with the speed of lightning.',
        level: 20, hp: 800, xpReward: 1200,
        requiredWorkouts: 35, tierIndex: 2, difficulty: 4,
        statThresholds: {0: 25, 1: 20, 3: 18},
      ),
      BossBattleModel(
        id: 'boss_dragon_spirit',
        name: 'Dragon Spirit',
        description: 'The ultimate challenge — a spiritual dragon manifesting pure power.',
        level: 30, hp: 2000, xpReward: 3000,
        requiredWorkouts: 60, tierIndex: 2, difficulty: 5,
        statThresholds: {0: 40, 1: 35, 2: 35, 3: 30, 4: 35},
      ),
    ];
    for (final boss in defaultBosses) {
      await _datasource.bossesBox.put(boss.id, boss);
    }
  }
}

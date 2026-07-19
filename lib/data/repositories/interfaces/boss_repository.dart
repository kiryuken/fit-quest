import '../../models/boss_battle_model.dart';

abstract class BossRepository {
  Future<List<BossBattleModel>> getAllBosses();
  Future<BossBattleModel?> getBoss(String id);
  Future<void> saveBoss(BossBattleModel boss);
  Future<void> seedDefaultBosses();
}

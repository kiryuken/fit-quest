import '../../data/models/achievement_state.dart';
import '../../data/models/user_model.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/workout_plan_model.dart';
import 'weekly_plan_service.dart';

class MilestoneEvaluation {
  final Set<String> eligibleAchievementIds;
  final Set<String> titles;
  final double adherence;
  final int elapsedDays;

  const MilestoneEvaluation({
    required this.eligibleAchievementIds,
    required this.titles,
    required this.adherence,
    required this.elapsedDays,
  });
}

class MilestoneService {
  MilestoneService._();

  static MilestoneEvaluation evaluate({
    required UserModel user,
    required WorkoutPlanModel plan,
    required Iterable<WorkoutModel> workouts,
    required DateTime now,
  }) {
    final committed = workouts
        .where((workout) => workout.isCommitted && workout.completed)
        .toList();
    final scheduledDates = committed
        .where((workout) => workout.countsForStreak)
        .map((workout) => workout.date);
    final elapsedDays = WeeklyPlanService.dateOnly(now)
            .difference(
              WeeklyPlanService.dateOnly(user.createdAt),
            )
            .inDays +
        1;
    final adherence = WeeklyPlanService.adherence(
      plan: plan,
      from: user.createdAt,
      through: now,
      completedDates: scheduledDates,
    );
    final improvedFamilies = {
      ...user.personalRecordMovementIds,
      ...committed.expand((workout) => workout.personalRecordMovementIds),
    }.length;
    final eligible = <String>{};

    if (committed.any((workout) => workout.validSetCount > 0)) {
      eligible.add(AchievementCatalog.awakening);
    }
    if (elapsedDays >= 28 && adherence >= 0.75) {
      eligible.add(AchievementCatalog.habitForged);
    }
    if (elapsedDays >= 84 && adherence >= 0.8 && improvedFamilies >= 2) {
      eligible.add(AchievementCatalog.foundationBuilt);
    }
    if (elapsedDays >= 168 && adherence >= 0.8 && improvedFamilies >= 3) {
      eligible.add(AchievementCatalog.bodyReforged);
    }
    if (elapsedDays >= 364 && adherence >= 0.8 && improvedFamilies >= 5) {
      eligible.add(AchievementCatalog.ironYear);
    }
    if (user.level >= 5) eligible.add(AchievementCatalog.level5);
    if (user.scheduledCompletions >= 7) {
      eligible.add(AchievementCatalog.sevenDayStreak);
    }

    final titles = eligible
        .map((id) => AchievementCatalog.milestoneTitles[id])
        .whereType<String>()
        .toSet();
    return MilestoneEvaluation(
      eligibleAchievementIds: eligible,
      titles: titles,
      adherence: adherence,
      elapsedDays: elapsedDays,
    );
  }
}

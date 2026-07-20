import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/theme/colors.dart';
import 'data/models/user_model.dart';
import 'data/models/workout_model.dart';
import 'data/models/skill_model.dart';
import 'data/models/boss_battle_model.dart';
import 'data/models/workout_plan_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WorkoutModelAdapter());
  Hive.registerAdapter(ExerciseRecordAdapter());
  Hive.registerAdapter(VariationRecordAdapter());
  Hive.registerAdapter(WorkoutSetRecordAdapter());
  Hive.registerAdapter(WorkoutPlanModelAdapter());
  Hive.registerAdapter(PlannedDayModelAdapter());
  Hive.registerAdapter(PlannedExerciseModelAdapter());
  Hive.registerAdapter(VariationPlanModelAdapter());
  Hive.registerAdapter(SkillModelAdapter());
  Hive.registerAdapter(SkillLevelDataAdapter());
  Hive.registerAdapter(ExerciseRequirementAdapter());
  Hive.registerAdapter(BossBattleModelAdapter());

  await Hive.openBox<UserModel>('user');
  await Hive.openBox<WorkoutModel>('workouts');
  await Hive.openBox<SkillModel>('skills');
  await Hive.openBox<BossBattleModel>('bosses');
  await Hive.openBox('game_state');

  runApp(
    const ProviderScope(child: FitQuestApp()),
  );
}

import 'models/skill_model.dart';
import '../core/enums/martial_art.dart';
import '../core/enums/skill_category.dart';
import '../core/enums/exercise_type.dart';

/// Complete skill catalog - all martial arts and their skills.
/// Each martial art is a separate tree with prerequisite DAG.
class SkillCatalog {
  SkillCatalog._();

  static List<SkillModel> allSkills() => [
        // ==========================================
        // AIKIDO - Throws, Joint Locks, Redirection
        // ==========================================
        SkillModel(
          id: 'aikido_kokyu_ho',
          name: 'Kokyu Ho (Breathing Power)',
          description:
              'Fundamental breathing technique that forms the basis of all Aikido movements. Generates power from the center (hara).',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.form.index,
          prerequisites: [],
          levels: [
            _level(1, 500, 1.0, 15, {
              'strength': 5,
              'endurance': 3
            }, [
              _req(ExerciseType.pushUp, totalRequired: 50),
              _req(ExerciseType.plank, totalRequired: 30),
            ]),
            _level(2, 1500, 1.3, 25, {
              'strength': 8,
              'endurance': 6,
              'constitution': 5
            }, [
              _req(ExerciseType.pushUp, totalRequired: 150),
              _req(ExerciseType.squat, totalRequired: 80),
            ]),
            _level(3, 4000, 1.8, 40, {
              'strength': 12,
              'endurance': 10,
              'constitution': 8
            }, [
              _req(ExerciseType.burpees, totalRequired: 200),
            ]),
            _level(4, 10000, 2.5, 65, {
              'strength': 18,
              'endurance': 16,
              'constitution': 12
            }, [
              _req(ExerciseType.deadlift, totalRequired: 300),
            ]),
            _level(5, 25000, 3.5, 100, {
              'strength': 28,
              'endurance': 24,
              'constitution': 18,
              'agility': 12
            }, [
              _req(ExerciseType.cleanAndPress, totalRequired: 400),
            ]),
          ],
        ),
        SkillModel(
          id: 'aikido_ikkyo',
          name: 'Ikkyo (First Control)',
          description:
              'The first and most fundamental Aikido control technique. Controls the opponent through the elbow and shoulder.',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.jointLock.index,
          prerequisites: ['aikido_kokyu_ho'],
          levels: [
            _level(1, 800, 1.0, 20, {
              'strength': 6,
              'dexterity': 5
            }, [
              _req(ExerciseType.pushUp, totalRequired: 80),
            ]),
            _level(2, 2000, 1.4, 32, {
              'strength': 10,
              'dexterity': 8
            }, [
              _req(ExerciseType.pushUp, totalRequired: 250),
            ]),
            _level(3, 5000, 2.0, 52, {
              'strength': 16,
              'dexterity': 12
            }, [
              _req(ExerciseType.pullUp, totalRequired: 150),
            ]),
            _level(4, 12000, 2.7, 80,
                {'strength': 24, 'dexterity': 18, 'agility': 14}, []),
            _level(5, 28000, 3.8, 130,
                {'strength': 35, 'dexterity': 26, 'agility': 20}, []),
          ],
        ),
        SkillModel(
          id: 'aikido_nikkyo',
          name: 'Nikkyo (Second Control)',
          description:
              'A wrist-lock technique that applies pressure to the opponent\'s wrist and forearm. More advanced than Ikkyo.',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.jointLock.index,
          prerequisites: ['aikido_ikkyo'],
          levels: [
            _level(1, 1000, 1.0, 22, {
              'strength': 7,
              'dexterity': 7
            }, [
              _req(ExerciseType.pushUp, totalRequired: 120),
            ]),
            _level(2, 2500, 1.5, 36, {
              'strength': 12,
              'dexterity': 10
            }, [
              _req(ExerciseType.pullUp, totalRequired: 100),
            ]),
            _level(3, 6000, 2.1, 56, {'strength': 18, 'dexterity': 15}, []),
            _level(4, 14000, 2.9, 88, {'strength': 26, 'dexterity': 22}, []),
            _level(5, 30000, 4.0, 145,
                {'strength': 38, 'dexterity': 30, 'agility': 22}, []),
          ],
        ),
        SkillModel(
          id: 'aikido_sankyo',
          name: 'Sankyo (Third Control)',
          description:
              'A controlling technique that twists the opponent\'s arm inward, targeting the wrist, elbow, and shoulder.',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.jointLock.index,
          prerequisites: ['aikido_ikkyo'],
          levels: [
            _level(1, 1000, 1.0, 20, {
              'strength': 7,
              'dexterity': 8
            }, [
              _req(ExerciseType.pushUp, totalRequired: 130),
            ]),
            _level(2, 2500, 1.5, 34, {'strength': 12, 'dexterity': 12}, []),
            _level(3, 6000, 2.1, 54, {'strength': 18, 'dexterity': 16}, []),
            _level(4, 14000, 2.9, 85, {'strength': 26, 'dexterity': 24}, []),
            _level(5, 30000, 4.0, 140, {'strength': 38, 'dexterity': 32}, []),
          ],
        ),
        SkillModel(
          id: 'aikido_irimi_nage',
          name: 'Irimi Nage (Entering Throw)',
          description:
              'A dynamic throw that enters deeply into the opponent\'s space. One of the most iconic Aikido techniques.',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.throwing.index,
          prerequisites: ['aikido_kokyu_ho'],
          levels: [
            _level(1, 800, 1.0, 25, {
              'strength': 8,
              'agility': 10,
              'dexterity': 6
            }, [
              _req(ExerciseType.pushUp, totalRequired: 100),
              _req(ExerciseType.squat, totalRequired: 50),
            ]),
            _level(2, 2000, 1.4, 40, {
              'strength': 12,
              'agility': 15,
              'dexterity': 10
            }, [
              _req(ExerciseType.pushUp, totalRequired: 300),
              _req(ExerciseType.squat, totalRequired: 150),
            ]),
            _level(3, 5000, 2.0, 65, {
              'strength': 18,
              'agility': 22,
              'dexterity': 14
            }, [
              _req(ExerciseType.burpees, totalRequired: 300),
              _req(ExerciseType.pullUp, totalRequired: 200),
            ]),
            _level(4, 12000, 2.8, 100, {
              'strength': 25,
              'agility': 30,
              'dexterity': 20,
              'constitution': 15
            }, [
              _req(ExerciseType.cleanAndPress, totalRequired: 500),
              _req(ExerciseType.running, totalRequired: 100000), // 100km
            ]),
            _level(5, 25000, 4.0, 175, {
              'strength': 35,
              'agility': 40,
              'dexterity': 28,
              'constitution': 22,
              'endurance': 20
            }, [
              _req(ExerciseType.deadlift, totalRequired: 1000),
              _req(ExerciseType.jumpRope, totalRequired: 50000),
            ]),
          ],
        ),
        SkillModel(
          id: 'aikido_shiho_nage',
          name: 'Shiho Nage (Four Directions Throw)',
          description:
              'A powerful throw executed in four directions. Symbolic of Aikido\'s principle of harmonious movement.',
          martialArtIndex: MartialArt.aikido.index,
          categoryIndex: SkillCategory.throwing.index,
          prerequisites: ['aikido_irimi_nage', 'aikido_nikkyo'],
          levels: [
            _level(1, 1500, 1.0, 35, {
              'strength': 12,
              'agility': 14,
              'dexterity': 10
            }, [
              _req(ExerciseType.pushUp, totalRequired: 400),
              _req(ExerciseType.squat, totalRequired: 250),
            ]),
            _level(2, 3500, 1.5, 55, {
              'strength': 16,
              'agility': 20,
              'dexterity': 14
            }, [
              _req(ExerciseType.deadlift, totalRequired: 200),
            ]),
            _level(3, 8000, 2.2, 85, {
              'strength': 22,
              'agility': 28,
              'dexterity': 20
            }, [
              _req(ExerciseType.cleanAndPress, totalRequired: 400),
            ]),
            _level(4, 18000, 3.0, 130, {
              'strength': 30,
              'agility': 36,
              'dexterity': 26,
              'constitution': 20
            }, []),
            _level(5, 40000, 4.5, 220, {
              'strength': 42,
              'agility': 48,
              'dexterity': 34,
              'constitution': 28
            }, []),
          ],
        ),

        // ==========================================
        // TAEKWONDO - Kicking, Striking, Speed
        // ==========================================
        SkillModel(
          id: 'tkd_basic_stance',
          name: 'Basic Stance & Movement',
          description:
              'Fundamental stances and footwork of Taekwondo. The foundation for all kicks and strikes.',
          martialArtIndex: MartialArt.taekwondo.index,
          categoryIndex: SkillCategory.form.index,
          prerequisites: [],
          levels: [
            _level(1, 400, 1.0, 12, {
              'agility': 5,
              'endurance': 3
            }, [
              _req(ExerciseType.squat, totalRequired: 50),
              _req(ExerciseType.jumpingJacks, totalRequired: 100),
            ]),
            _level(2, 1200, 1.3, 20, {
              'agility': 8,
              'endurance': 5
            }, [
              _req(ExerciseType.lunges, totalRequired: 100),
            ]),
            _level(3, 3000, 1.7, 32, {
              'agility': 12,
              'endurance': 8,
              'dexterity': 6
            }, [
              _req(ExerciseType.burpees, totalRequired: 200),
            ]),
            _level(4, 8000, 2.4, 55, {
              'agility': 18,
              'endurance': 14,
              'dexterity': 10
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 10000),
            ]),
            _level(5, 18000, 3.5, 90, {
              'agility': 26,
              'endurance': 20,
              'dexterity': 16
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 30000),
            ]),
          ],
        ),
        SkillModel(
          id: 'tkd_ap_chagi',
          name: 'Ap Chagi (Front Kick)',
          description:
              'The fundamental front kick in Taekwondo. A direct, linear kick that forms the basis for all other kicks.',
          martialArtIndex: MartialArt.taekwondo.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['tkd_basic_stance'],
          levels: [
            _level(1, 600, 1.0, 18, {
              'agility': 6,
              'dexterity': 5,
              'strength': 4
            }, [
              _req(ExerciseType.squat, totalRequired: 100),
            ]),
            _level(2, 1800, 1.4, 28, {
              'agility': 10,
              'dexterity': 8,
              'strength': 6
            }, [
              _req(ExerciseType.lunges, totalRequired: 200),
            ]),
            _level(3, 4500, 2.0, 45, {
              'agility': 15,
              'dexterity': 12,
              'strength': 10
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 5000),
            ]),
            _level(4, 11000, 2.7, 72, {
              'agility': 22,
              'dexterity': 18,
              'strength': 14
            }, [
              _req(ExerciseType.burpees, totalRequired: 400),
            ]),
            _level(5, 25000, 3.8, 120,
                {'agility': 32, 'dexterity': 26, 'strength': 20}, []),
          ],
        ),
        SkillModel(
          id: 'tkd_dollyo_chagi',
          name: 'Dollyo Chagi (Roundhouse Kick)',
          description:
              'The roundhouse kick - one of the most powerful and versatile kicks in Taekwondo. Strikes with the instep or ball of the foot.',
          martialArtIndex: MartialArt.taekwondo.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['tkd_ap_chagi'],
          levels: [
            _level(1, 800, 1.0, 24, {
              'agility': 8,
              'dexterity': 7,
              'strength': 6
            }, [
              _req(ExerciseType.lunges, totalRequired: 150),
            ]),
            _level(2, 2000, 1.5, 38, {
              'agility': 14,
              'dexterity': 10,
              'strength': 10
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 8000),
            ]),
            _level(3, 5000, 2.1, 60,
                {'agility': 20, 'dexterity': 16, 'strength': 14}, []),
            _level(4, 12000, 2.9, 95,
                {'agility': 28, 'dexterity': 22, 'strength': 20}, []),
            _level(5, 28000, 4.0, 155,
                {'agility': 38, 'dexterity': 32, 'strength': 28}, []),
          ],
        ),
        SkillModel(
          id: 'tkd_naeryo_chagi',
          name: 'Naeryo Chagi (Axe Kick)',
          description:
              'The devastating axe kick - raises the leg high and brings it down with tremendous force on the opponent\'s head or shoulder.',
          martialArtIndex: MartialArt.taekwondo.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['tkd_dollyo_chagi'],
          levels: [
            _level(1, 1200, 1.0, 30, {
              'agility': 12,
              'dexterity': 10,
              'strength': 10
            }, [
              _req(ExerciseType.lunges, totalRequired: 300),
              _req(ExerciseType.squat, totalRequired: 250),
            ]),
            _level(2, 3000, 1.6, 50, {
              'agility': 18,
              'dexterity': 15,
              'strength': 15
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 15000),
            ]),
            _level(3, 7000, 2.3, 80,
                {'agility': 26, 'dexterity': 22, 'strength': 20}, []),
            _level(4, 16000, 3.1, 125,
                {'agility': 35, 'dexterity': 30, 'strength': 28}, []),
            _level(5, 35000, 4.5, 200,
                {'agility': 48, 'dexterity': 40, 'strength': 36}, []),
          ],
        ),
        SkillModel(
          id: 'tkd_yeop_chagi',
          name: 'Yeop Chagi (Side Kick)',
          description:
              'The powerful side kick - generates tremendous force through the heel, effective for both offense and defense.',
          martialArtIndex: MartialArt.taekwondo.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['tkd_basic_stance'],
          levels: [
            _level(1, 700, 1.0, 22, {
              'agility': 7,
              'strength': 8,
              'dexterity': 5
            }, [
              _req(ExerciseType.squat, totalRequired: 120),
            ]),
            _level(2, 1800, 1.4, 35, {
              'agility': 12,
              'strength': 12,
              'dexterity': 8
            }, [
              _req(ExerciseType.lunges, totalRequired: 200),
            ]),
            _level(3, 4500, 2.0, 55,
                {'agility': 18, 'strength': 18, 'dexterity': 12}, []),
            _level(4, 11000, 2.7, 88,
                {'agility': 25, 'strength': 25, 'dexterity': 18}, []),
            _level(5, 26000, 3.8, 140,
                {'agility': 35, 'strength': 35, 'dexterity': 26}, []),
          ],
        ),

        // ==========================================
        // MUAY THAI - Striking, Clinch, Power
        // ==========================================
        SkillModel(
          id: 'mt_stance',
          name: 'Muay Thai Stance & Rhythm',
          description:
              'The fundamental Muay Thai stance with the characteristic rhythmic bounce. Foundation for all strikes and defense.',
          martialArtIndex: MartialArt.muayThai.index,
          categoryIndex: SkillCategory.form.index,
          prerequisites: [],
          levels: [
            _level(1, 400, 1.0, 12, {
              'strength': 5,
              'endurance': 3,
              'agility': 4
            }, [
              _req(ExerciseType.jumpingJacks, totalRequired: 100),
              _req(ExerciseType.squat, totalRequired: 50),
            ]),
            _level(2, 1200, 1.3, 20, {
              'strength': 8,
              'endurance': 6,
              'agility': 6
            }, [
              _req(ExerciseType.jumpRope, totalRequired: 3000),
            ]),
            _level(3, 3000, 1.7, 32, {
              'strength': 12,
              'endurance': 10,
              'agility': 10
            }, [
              _req(ExerciseType.burpees, totalRequired: 200),
            ]),
            _level(4, 8000, 2.4, 55,
                {'strength': 18, 'endurance': 15, 'agility': 15}, []),
            _level(5, 18000, 3.5, 90,
                {'strength': 26, 'endurance': 22, 'agility': 22}, []),
          ],
        ),
        SkillModel(
          id: 'mt_jab_cross',
          name: 'Jab & Cross',
          description:
              'The fundamental 1-2 punch combination. The jab sets up the cross, which delivers knockout power.',
          martialArtIndex: MartialArt.muayThai.index,
          categoryIndex: SkillCategory.striking.index,
          prerequisites: ['mt_stance'],
          levels: [
            _level(1, 600, 1.0, 20, {
              'strength': 8,
              'dexterity': 5,
              'endurance': 5
            }, [
              _req(ExerciseType.pushUp, totalRequired: 100),
            ]),
            _level(2, 1800, 1.4, 30, {
              'strength': 12,
              'dexterity': 8,
              'endurance': 8
            }, [
              _req(ExerciseType.pushUp, totalRequired: 300),
            ]),
            _level(3, 4500, 2.0, 48, {
              'strength': 18,
              'dexterity': 12,
              'endurance': 12
            }, [
              _req(ExerciseType.benchPress, totalRequired: 100),
            ]),
            _level(4, 11000, 2.7, 76,
                {'strength': 25, 'dexterity': 18, 'endurance': 16}, []),
            _level(5, 25000, 3.8, 125,
                {'strength': 35, 'dexterity': 26, 'endurance': 24}, []),
          ],
        ),
        SkillModel(
          id: 'mt_hooks_uppercuts',
          name: 'Hooks & Uppercuts',
          description:
              'Devastating close-range punches. Hooks target the side of the head and body; uppercuts come from below.',
          martialArtIndex: MartialArt.muayThai.index,
          categoryIndex: SkillCategory.striking.index,
          prerequisites: ['mt_jab_cross'],
          levels: [
            _level(1, 800, 1.0, 26, {
              'strength': 10,
              'dexterity': 8,
              'agility': 7
            }, [
              _req(ExerciseType.pushUp, totalRequired: 200),
              _req(ExerciseType.benchPress, totalRequired: 50),
            ]),
            _level(2, 2000, 1.5, 42,
                {'strength': 15, 'dexterity': 12, 'agility': 10}, []),
            _level(3, 5000, 2.1, 66, {
              'strength': 22,
              'dexterity': 18,
              'agility': 15
            }, [
              _req(ExerciseType.benchPress, totalRequired: 200),
            ]),
            _level(4, 12000, 2.9, 105,
                {'strength': 30, 'dexterity': 24, 'agility': 22}, []),
            _level(5, 28000, 4.0, 170,
                {'strength': 42, 'dexterity': 34, 'agility': 30}, []),
          ],
        ),
        SkillModel(
          id: 'mt_teep',
          name: 'Teep (Push Kick)',
          description:
              'The Muay Thai push kick - used to maintain distance, disrupt the opponent\'s rhythm, and set up combinations.',
          martialArtIndex: MartialArt.muayThai.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['mt_stance'],
          levels: [
            _level(1, 500, 1.0, 18, {
              'agility': 8,
              'strength': 6,
              'endurance': 5
            }, [
              _req(ExerciseType.squat, totalRequired: 100),
            ]),
            _level(2, 1500, 1.3, 28, {
              'agility': 12,
              'strength': 10,
              'endurance': 8
            }, [
              _req(ExerciseType.lunges, totalRequired: 200),
            ]),
            _level(3, 4000, 1.8, 44,
                {'agility': 18, 'strength': 15, 'endurance': 12}, []),
            _level(4, 10000, 2.5, 70,
                {'agility': 25, 'strength': 22, 'endurance': 18}, []),
            _level(5, 22000, 3.5, 115,
                {'agility': 35, 'strength': 30, 'endurance': 25}, []),
          ],
        ),
        SkillModel(
          id: 'mt_clinch_knees',
          name: 'Clinch & Knees',
          description:
              'The legendary Muay Thai clinch - controlling the opponent\'s neck while delivering devastating knee strikes.',
          martialArtIndex: MartialArt.muayThai.index,
          categoryIndex: SkillCategory.grappling.index,
          prerequisites: ['mt_teep', 'mt_hooks_uppercuts'],
          levels: [
            _level(1, 1500, 1.0, 32, {
              'strength': 14,
              'constitution': 12,
              'endurance': 10
            }, [
              _req(ExerciseType.squat, totalRequired: 300),
              _req(ExerciseType.deadlift, totalRequired: 150),
            ]),
            _level(2, 3500, 1.5, 52, {
              'strength': 20,
              'constitution': 16,
              'endurance': 14
            }, [
              _req(ExerciseType.deadlift, totalRequired: 400),
            ]),
            _level(3, 8000, 2.2, 82,
                {'strength': 28, 'constitution': 22, 'endurance': 20}, []),
            _level(4, 18000, 3.0, 130,
                {'strength': 38, 'constitution': 30, 'endurance': 26}, []),
            _level(5, 40000, 4.5, 210,
                {'strength': 50, 'constitution': 40, 'endurance': 34}, []),
          ],
        ),

        // ==========================================
        // CAPOEIRA - Acrobatics, Rhythm, Flow
        // ==========================================
        SkillModel(
          id: 'capoeira_ginga',
          name: 'Ginga (Basic Step)',
          description:
              'The fundamental swaying movement of Capoeira. It is the base for all attacks, dodges, and acrobatic movements.',
          martialArtIndex: MartialArt.capoeira.index,
          categoryIndex: SkillCategory.form.index,
          prerequisites: [],
          levels: [
            _level(1, 400, 1.0, 12, {
              'agility': 5,
              'dexterity': 4,
              'endurance': 3
            }, [
              _req(ExerciseType.lunges, totalRequired: 100),
              _req(ExerciseType.jumpingJacks, totalRequired: 150),
            ]),
            _level(2, 1200, 1.3, 20, {
              'agility': 8,
              'dexterity': 7,
              'endurance': 6
            }, [
              _req(ExerciseType.lunges, totalRequired: 250),
            ]),
            _level(3, 3000, 1.7, 32,
                {'agility': 12, 'dexterity': 10, 'endurance': 9}, []),
            _level(4, 8000, 2.4, 55,
                {'agility': 18, 'dexterity': 14, 'endurance': 14}, []),
            _level(5, 18000, 3.5, 90,
                {'agility': 26, 'dexterity': 22, 'endurance': 20}, []),
          ],
        ),
        SkillModel(
          id: 'capoeira_au',
          name: 'Au (Cartwheel)',
          description:
              'The cartwheel - a fluid acrobatic movement used for evasion, attack setup, and style in the roda.',
          martialArtIndex: MartialArt.capoeira.index,
          categoryIndex: SkillCategory.acrobatics.index,
          prerequisites: ['capoeira_ginga'],
          levels: [
            _level(1, 600, 1.0, 20, {
              'agility': 8,
              'dexterity': 6,
              'strength': 5
            }, [
              _req(ExerciseType.burpees, totalRequired: 100),
            ]),
            _level(2, 1800, 1.4, 32, {
              'agility': 12,
              'dexterity': 10,
              'strength': 8
            }, [
              _req(ExerciseType.burpees, totalRequired: 250),
            ]),
            _level(3, 4500, 2.0, 50,
                {'agility': 18, 'dexterity': 15, 'strength': 12}, []),
            _level(4, 11000, 2.7, 80,
                {'agility': 26, 'dexterity': 22, 'strength': 18}, []),
            _level(5, 25000, 3.8, 130,
                {'agility': 36, 'dexterity': 30, 'strength': 25}, []),
          ],
        ),
        SkillModel(
          id: 'capoeira_esquivas',
          name: 'Esquivas (Dodges)',
          description:
              'The evasive dodging movements of Capoeira. Fluid body movements that avoid attacks while maintaining flow.',
          martialArtIndex: MartialArt.capoeira.index,
          categoryIndex: SkillCategory.dodge.index,
          prerequisites: ['capoeira_ginga'],
          levels: [
            _level(1, 500, 1.0, 14, {
              'agility': 8,
              'dexterity': 5,
              'endurance': 4
            }, [
              _req(ExerciseType.lunges, totalRequired: 150),
              _req(ExerciseType.jumpingJacks, totalRequired: 200),
            ]),
            _level(2, 1500, 1.3, 24,
                {'agility': 12, 'dexterity': 8, 'endurance': 7}, []),
            _level(3, 4000, 1.8, 38,
                {'agility': 18, 'dexterity': 12, 'endurance': 10}, []),
            _level(4, 10000, 2.5, 62,
                {'agility': 26, 'dexterity': 18, 'endurance': 15}, []),
            _level(5, 22000, 3.5, 100,
                {'agility': 36, 'dexterity': 26, 'endurance': 22}, []),
          ],
        ),
        SkillModel(
          id: 'capoeira_martelo',
          name: 'Martelo (Hammer Kick)',
          description:
              'A powerful round kick performed with the instep. Combines acrobatic body mechanics with devastating force.',
          martialArtIndex: MartialArt.capoeira.index,
          categoryIndex: SkillCategory.kicking.index,
          prerequisites: ['capoeira_au', 'capoeira_esquivas'],
          levels: [
            _level(1, 1000, 1.0, 28, {
              'agility': 12,
              'strength': 10,
              'dexterity': 8
            }, [
              _req(ExerciseType.lunges, totalRequired: 300),
              _req(ExerciseType.squat, totalRequired: 200),
            ]),
            _level(2, 2500, 1.5, 45,
                {'agility': 18, 'strength': 15, 'dexterity': 12}, []),
            _level(3, 6000, 2.1, 70,
                {'agility': 26, 'strength': 22, 'dexterity': 18}, []),
            _level(4, 14000, 2.9, 110,
                {'agility': 35, 'strength': 30, 'dexterity': 25}, []),
            _level(5, 32000, 4.2, 180,
                {'agility': 48, 'strength': 40, 'dexterity': 35}, []),
          ],
        ),

        // ==========================================
        // KRAV MAGA - Self-Defense, Efficiency
        // ==========================================
        SkillModel(
          id: 'km_neutral_stance',
          name: 'Neutral Stance',
          description:
              'The passive-ready stance of Krav Maga. Non-aggressive appearance while maintaining readiness for any threat.',
          martialArtIndex: MartialArt.kravMaga.index,
          categoryIndex: SkillCategory.selfDefense.index,
          prerequisites: [],
          levels: [
            _level(1, 400, 1.0, 12, {
              'dexterity': 5,
              'constitution': 4,
              'agility': 4
            }, [
              _req(ExerciseType.pushUp, totalRequired: 50),
              _req(ExerciseType.squat, totalRequired: 50),
            ]),
            _level(2, 1200, 1.3, 20, {
              'dexterity': 8,
              'constitution': 7,
              'agility': 6
            }, [
              _req(ExerciseType.burpees, totalRequired: 100),
            ]),
            _level(3, 3000, 1.7, 32,
                {'dexterity': 12, 'constitution': 10, 'agility': 9}, []),
            _level(4, 8000, 2.4, 55,
                {'dexterity': 18, 'constitution': 15, 'agility': 14}, []),
            _level(5, 18000, 3.5, 90,
                {'dexterity': 26, 'constitution': 22, 'agility': 20}, []),
          ],
        ),
        SkillModel(
          id: 'km_straight_punches',
          name: 'Straight Punches',
          description:
              'Direct, efficient straight punches. Krav Maga emphasizes maximum damage with minimal movement.',
          martialArtIndex: MartialArt.kravMaga.index,
          categoryIndex: SkillCategory.striking.index,
          prerequisites: ['km_neutral_stance'],
          levels: [
            _level(1, 600, 1.0, 22, {
              'strength': 8,
              'dexterity': 7,
              'endurance': 5
            }, [
              _req(ExerciseType.pushUp, totalRequired: 150),
            ]),
            _level(2, 1800, 1.5, 35, {
              'strength': 12,
              'dexterity': 10,
              'endurance': 8
            }, [
              _req(ExerciseType.pushUp, totalRequired: 400),
              _req(ExerciseType.benchPress, totalRequired: 80),
            ]),
            _level(3, 4500, 2.1, 56,
                {'strength': 18, 'dexterity': 15, 'endurance': 12}, []),
            _level(4, 11000, 2.9, 88,
                {'strength': 26, 'dexterity': 22, 'endurance': 18}, []),
            _level(5, 26000, 4.0, 145,
                {'strength': 36, 'dexterity': 30, 'endurance': 25}, []),
          ],
        ),
        SkillModel(
          id: 'km_360_defense',
          name: '360 Defense + Counter',
          description:
              'Defense against attacks from any angle followed by an immediate counter-attack. Core Krav Maga principle.',
          martialArtIndex: MartialArt.kravMaga.index,
          categoryIndex: SkillCategory.selfDefense.index,
          prerequisites: ['km_straight_punches'],
          levels: [
            _level(1, 800, 1.0, 24, {
              'dexterity': 10,
              'agility': 8,
              'constitution': 8
            }, [
              _req(ExerciseType.burpees, totalRequired: 200),
            ]),
            _level(2, 2000, 1.4, 38, {
              'dexterity': 15,
              'agility': 12,
              'constitution': 12
            }, [
              _req(ExerciseType.pullUp, totalRequired: 150),
            ]),
            _level(3, 5000, 2.0, 60,
                {'dexterity': 22, 'agility': 18, 'constitution': 16}, []),
            _level(4, 12000, 2.8, 95,
                {'dexterity': 30, 'agility': 25, 'constitution': 24}, []),
            _level(5, 28000, 4.0, 155,
                {'dexterity': 40, 'agility': 35, 'constitution': 32}, []),
          ],
        ),
        SkillModel(
          id: 'km_knife_defense',
          name: 'Knife Defense',
          description:
              'Advanced Krav Maga techniques for defending against knife attacks. Redirect, control, and disarm.',
          martialArtIndex: MartialArt.kravMaga.index,
          categoryIndex: SkillCategory.selfDefense.index,
          prerequisites: ['km_360_defense'],
          levels: [
            _level(1, 1200, 1.0, 30, {
              'dexterity': 14,
              'agility': 12,
              'constitution': 10
            }, [
              _req(ExerciseType.pushUp, totalRequired: 500),
              _req(ExerciseType.pullUp, totalRequired: 200),
            ]),
            _level(2, 3000, 1.6, 48, {
              'dexterity': 20,
              'agility': 18,
              'constitution': 15
            }, [
              _req(ExerciseType.deadlift, totalRequired: 300),
            ]),
            _level(3, 7000, 2.3, 76,
                {'dexterity': 28, 'agility': 25, 'constitution': 22}, []),
            _level(4, 16000, 3.2, 120,
                {'dexterity': 38, 'agility': 35, 'constitution': 30}, []),
            _level(5, 36000, 4.5, 200,
                {'dexterity': 50, 'agility': 45, 'constitution': 40}, []),
          ],
        ),
      ];

  static SkillLevelData _level(
    int level,
    int xpRequired,
    double damageMultiplier,
    int baseDamage,
    Map<String, int> statRequirements,
    List<ExerciseRequirement> exerciseRequirements, {
    String? unlockEffect,
  }) {
    final statReqMap = <int, int>{};
    statRequirements.forEach((k, v) {
      final index = _statIndex(k);
      final existing = statReqMap[index] ?? 0;
      if (v > existing) statReqMap[index] = v;
    });
    return SkillLevelData(
      level: level,
      xpRequired: xpRequired,
      damageMultiplier: damageMultiplier,
      baseDamage: baseDamage,
      statRequirements: statReqMap,
      exerciseRequirements: exerciseRequirements,
      unlockEffect: unlockEffect,
    );
  }

  static ExerciseRequirement _req(
    ExerciseType type, {
    int totalRequired = 10,
    int minimumSets = 1,
    int minimumReps = 1,
    double minimumFormQuality = 0.6,
  }) {
    return ExerciseRequirement(
      exerciseTypeIndex: type.index,
      totalRequired: totalRequired,
      minimumSets: minimumSets,
      minimumReps: minimumReps,
      minimumFormQuality: minimumFormQuality,
    );
  }

  static int _statIndex(String name) {
    // The authored catalog predates schema v2. END and CON intentionally
    // converge on VIT, while DEX converges on SEN; _level keeps the stricter
    // value when both legacy aliases appear in one requirement map.
    return switch (name) {
      'strength' => 0,
      'agility' => 1,
      'endurance' => 2,
      'constitution' => 2,
      'dexterity' => 3,
      'intelligence' => 4,
      _ => 0,
    };
  }
}

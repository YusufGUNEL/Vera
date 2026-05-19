import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/state/auth_controller.dart';
import '../../features/home/state/goals_controller.dart';
import '../../features/home/state/home_controller.dart';
import '../firebase/firebase_bootstrap.dart';
import '../services/gemini_service.dart';
import '../services/voice_input_service.dart';

class UserReadiness {
  const UserReadiness({
    required this.isDemoSession,
    required this.localOnly,
    required this.firebaseReady,
    required this.geminiReady,
    required this.hasImportedData,
    required this.needsUserData,
    required this.voiceAvailable,
    required this.persona,
    required this.dataDepth,
    required this.sourceCoverage,
  });

  final bool isDemoSession;
  final bool localOnly;
  final bool firebaseReady;
  final bool geminiReady;
  final bool hasImportedData;
  final bool needsUserData;
  final bool voiceAvailable;
  final String persona;
  final double dataDepth;
  final double sourceCoverage;

  bool get aiReady => geminiReady;
}

final userReadinessProvider = Provider<UserReadiness>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider);
  final auth = ref.watch(authControllerProvider);
  final home = ref.watch(homeControllerProvider);
  final goal = ref.watch(goalsControllerProvider);
  final voice = ref.watch(voiceInputControllerProvider);
  final gemini = ref.watch(geminiServiceProvider);

  final hasImportedData =
      home.transactions.isNotEmpty || home.banks.isNotEmpty || goal.target > 0;
  final sourceCount = [
    if (home.transactions.isNotEmpty) 1,
    if (home.banks.isNotEmpty) 1,
    if (goal.target > 0) 1,
  ].length;
  final dataDepth = (home.transactions.length / 12).clamp(0, 1).toDouble();

  return UserReadiness(
    isDemoSession:
        auth.userId == 'demo-user' || auth.authMethod == 'demo vault',
    localOnly: !bootstrap.ready,
    firebaseReady: bootstrap.ready,
    geminiReady: gemini.isAvailable,
    hasImportedData: hasImportedData,
    needsUserData: !hasImportedData,
    voiceAvailable: voice.status != VoiceStatus.unavailable,
    persona: auth.status.name,
    dataDepth: hasImportedData ? dataDepth : 0,
    sourceCoverage: sourceCount / 3,
  );
});

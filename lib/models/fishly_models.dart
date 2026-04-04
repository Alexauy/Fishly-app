enum ShopRewardCategory { accessory, tankDecoration }

const int maxFocusMinutes = 1440;
const int maxRewardBenchmarkMinutes = 150;
const int aboveBenchmarkCoins = 40;
const List<({int minutes, int coins})> focusTimeBenchmarks = [
  (minutes: 5, coins: 2),
  (minutes: 15, coins: 5),
  (minutes: 30, coins: 10),
  (minutes: 45, coins: 15),
  (minutes: 60, coins: 20),
  (minutes: 90, coins: 25),
  (minutes: 120, coins: 30),
  (minutes: 150, coins: 35),
];

int coinsForFocusMinutes(int minutes) {
  if (minutes > maxRewardBenchmarkMinutes) {
    return aboveBenchmarkCoins;
  }

  var closest = focusTimeBenchmarks.first;
  var closestDistance = (minutes - closest.minutes).abs();

  for (final benchmark in focusTimeBenchmarks.skip(1)) {
    final distance = (minutes - benchmark.minutes).abs();
    if (distance < closestDistance ||
        (distance == closestDistance && benchmark.minutes < closest.minutes)) {
      closest = benchmark;
      closestDistance = distance;
    }
  }

  return closest.coins;
}

String formatFocusTimeLabel(int minutes) {
  return minutes == 1 ? '1 min' : '$minutes mins';
}

int? parseFocusTimeLabel(String? label) {
  if (label == null || label.trim().isEmpty) {
    return null;
  }
  return int.tryParse(label.trim().split(' ').first);
}

class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.title,
    this.details = '',
    this.subtitle = '',
    this.tag,
    this.reward,
    this.completed = false,
    this.isBigGoal = false,
    this.isSubgoal = false,
    this.isLeftover = false,
    this.rewardClaimed = false,
    this.parentGoalId,
    this.durationLabel,
    this.coins,
    this.createdDateKey,
  });

  final String id;
  final String title;
  final String details;
  final String subtitle;
  final String? tag;
  final String? reward;
  final bool completed;
  final bool isBigGoal;
  final bool isSubgoal;
  final bool isLeftover;
  final bool rewardClaimed;
  final String? parentGoalId;
  final String? durationLabel;
  final int? coins;
  final String? createdDateKey;

  PlannerTask copyWith({
    String? id,
    String? title,
    String? details,
    String? subtitle,
    String? tag,
    String? reward,
    bool? completed,
    bool? isBigGoal,
    bool? isSubgoal,
    bool? isLeftover,
    bool? rewardClaimed,
    String? parentGoalId,
    String? durationLabel,
    int? coins,
    String? createdDateKey,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      subtitle: subtitle ?? this.subtitle,
      tag: tag ?? this.tag,
      reward: reward ?? this.reward,
      completed: completed ?? this.completed,
      isBigGoal: isBigGoal ?? this.isBigGoal,
      isSubgoal: isSubgoal ?? this.isSubgoal,
      isLeftover: isLeftover ?? this.isLeftover,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      durationLabel: durationLabel ?? this.durationLabel,
      coins: coins ?? this.coins,
      createdDateKey: createdDateKey ?? this.createdDateKey,
    );
  }
}

class FishlyUserProfile {
  const FishlyUserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.coins = 0,
    this.ownedRewardTitles = const <String>[],
    this.completionHistory = const <String, int>{},
    this.equippedAvatarAsset,
    this.equippedTankAsset,
  });

  final String uid;
  final String displayName;
  final String email;
  final int coins;
  final List<String> ownedRewardTitles;
  final Map<String, int> completionHistory;
  final String? equippedAvatarAsset;
  final String? equippedTankAsset;

  FishlyUserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    int? coins,
    List<String>? ownedRewardTitles,
    Map<String, int>? completionHistory,
    String? equippedAvatarAsset,
    String? equippedTankAsset,
  }) {
    return FishlyUserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      coins: coins ?? this.coins,
      ownedRewardTitles: ownedRewardTitles ?? this.ownedRewardTitles,
      completionHistory: completionHistory ?? this.completionHistory,
      equippedAvatarAsset: equippedAvatarAsset ?? this.equippedAvatarAsset,
      equippedTankAsset: equippedTankAsset ?? this.equippedTankAsset,
    );
  }
}

class FishlyAccountBundle {
  const FishlyAccountBundle({required this.profile, required this.tasks});

  final FishlyUserProfile profile;
  final List<PlannerTask> tasks;
}

class ShopReward {
  const ShopReward({
    required this.title,
    required this.price,
    required this.assetPath,
    required this.category,
  });

  final String title;
  final int price;
  final String assetPath;
  final ShopRewardCategory category;
}

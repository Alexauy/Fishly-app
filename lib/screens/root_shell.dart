import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/fishly_firestore_repository.dart';
import '../data/mock_data.dart';
import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import 'goal_detail_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final FishlyFirestoreRepository _repository = FishlyFirestoreRepository();

  int _index = 0;
  String? _selectedGoalId;
  int _coins = 0;
  final Set<String> _ownedRewardTitles = <String>{};
  String _equippedAvatarAsset = defaultGubbyAsset;
  String _equippedTankAsset = defaultTankPanelAsset;
  Map<String, int> _completionHistory = <String, int>{};
  late String _currentDateKey;
  late List<PlannerTask> _tasks;
  StreamSubscription<User?>? _authSubscription;
  Timer? _persistDebounce;
  Timer? _dayRolloverTimer;
  FishlyUserProfile? _profile;
  bool _authBusy = false;
  String? _authError;
  String? _pendingDisplayName;
  String? _gubbyMessageOverride;
  int _gubbyMessageRevision = 0;

  @override
  void initState() {
    super.initState();
    _currentDateKey = _todayKey();
    _tasks = List<PlannerTask>.from(dailyTasks);
    _syncBigGoalState();
    _scheduleDayRollover();
    _authSubscription = _repository.authStateChanges().listen(
      _handleAuthChanged,
    );
  }

  @override
  void dispose() {
    _dayRolloverTimer?.cancel();
    _persistDebounce?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = null;
        _authBusy = false;
        _authError = null;
        _coins = 0;
        _ownedRewardTitles.clear();
        _equippedAvatarAsset = defaultGubbyAsset;
        _equippedTankAsset = defaultTankPanelAsset;
        _completionHistory = <String, int>{};
        _pendingDisplayName = null;
        _currentDateKey = _todayKey();
        _tasks = List<PlannerTask>.from(dailyTasks);
        _syncBigGoalState();
      });
      return;
    }

    setState(() {
      _authBusy = true;
      _authError = null;
    });

    try {
      final bundle = await _repository.loadAccountBundle(user.uid);
      if (!mounted) {
        return;
      }

      setState(() {
        _profile =
            bundle?.profile ??
            FishlyUserProfile(
              uid: user.uid,
              displayName:
                  _pendingDisplayName ?? user.displayName ?? 'Fishly User',
              email: user.email ?? '',
              coins: 0,
              ownedRewardTitles: const <String>[],
              equippedAvatarAsset: defaultGubbyAsset,
              equippedTankAsset: defaultTankPanelAsset,
            );
        _pendingDisplayName = null;
        _coins = _profile!.coins;
        _ownedRewardTitles
          ..clear()
          ..addAll(_profile!.ownedRewardTitles);
        _completionHistory = Map<String, int>.from(_profile!.completionHistory);
        _equippedAvatarAsset =
            _profile!.equippedAvatarAsset ?? defaultGubbyAsset;
        _equippedTankAsset =
            _profile!.equippedTankAsset ?? defaultTankPanelAsset;
        _tasks = bundle?.tasks ?? List<PlannerTask>.from(dailyTasks);
        _applyDayRolloverIfNeeded();
        _syncBigGoalState();
        _authBusy = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authBusy = false;
        _authError = error.toString();
      });
    }
  }

  Future<void> _createAccount({
    required String displayName,
    required String email,
    required String password,
  }) async {
    setState(() {
      _authBusy = true;
      _authError = null;
      _pendingDisplayName = displayName;
    });

    try {
      await _repository.createAccount(
        displayName: displayName,
        email: email,
        password: password,
        coins: _coins,
        ownedRewardTitles: _ownedRewardTitles,
        equippedAvatarAsset: _equippedAvatarAsset,
        equippedTankAsset: _equippedTankAsset,
        tasks: _tasks,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authBusy = false;
        _authError = error.message ?? error.code;
        _pendingDisplayName = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authBusy = false;
        _authError = error.toString();
        _pendingDisplayName = null;
      });
    }
  }

  Future<void> _signIn({
    required String email,
    required String password,
  }) async {
    setState(() {
      _authBusy = true;
      _authError = null;
    });

    try {
      await _repository.signIn(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authBusy = false;
        _authError = error.message ?? error.code;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authBusy = false;
        _authError = error.toString();
      });
    }
  }

  Future<void> _signOut() async {
    await _repository.signOut();
  }

  Future<String?> _deleteAccount({required String password}) async {
    setState(() {
      _authBusy = true;
      _authError = null;
    });

    try {
      await _repository.deleteCurrentAccount(password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return error.message ?? error.code;
      }
      setState(() {
        _authBusy = false;
        _authError = error.message ?? error.code;
      });
      return error.message ?? error.code;
    } catch (error) {
      if (!mounted) {
        return error.toString();
      }
      setState(() {
        _authBusy = false;
        _authError = error.toString();
      });
      return error.toString();
    }
  }

  void _schedulePersist() {
    if (_profile == null) {
      return;
    }

    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_persistAccountState());
    });
  }

  Future<void> _persistAccountState() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    final updatedProfile = profile.copyWith(
      coins: _coins,
      ownedRewardTitles: _ownedRewardTitles.toList(),
      completionHistory: Map<String, int>.from(_completionHistory),
      equippedAvatarAsset: _equippedAvatarAsset,
      equippedTankAsset: _equippedTankAsset,
    );

    try {
      await _repository.saveAccountBundle(
        uid: profile.uid,
        profile: updatedProfile,
        tasks: _tasks,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = updatedProfile;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _authError = error.toString();
      });
    }
  }

  void _openGoalDetail(String goalId) =>
      setState(() => _selectedGoalId = goalId);
  void _closeGoalDetail() => setState(() => _selectedGoalId = null);

  String _detailPreview(String details) {
    final words = details
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '';
    }
    if (words.length <= 10) {
      return words.join(' ');
    }
    return '${words.take(10).join(' ')}...';
  }

  PlannerTask _normalizedTask(PlannerTask task) {
    return task.copyWith(
      subtitle: _detailPreview(task.details),
      tag: task.isBigGoal
          ? 'Big goal'
          : task.isSubgoal
          ? 'Subgoal'
          : null,
      reward: task.durationLabel,
    );
  }

  String _todayKey() {
    return _formatDateKey(DateTime.now());
  }

  String _formatDateKey(DateTime date) {
    final now = date;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  void _scheduleDayRollover() {
    _dayRolloverTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _dayRolloverTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _applyDayRolloverIfNeeded(force: true);
      });
      _schedulePersist();
      _scheduleDayRollover();
    });
  }

  void _applyDayRolloverIfNeeded({bool force = false}) {
    final todayKey = _todayKey();
    if (!force && todayKey == _currentDateKey) {
      return;
    }
    _rolloverToDate(todayKey);
  }

  void _rolloverToDate(String nextDateKey) {
    final previousDateKey = _currentDateKey;
    final currentTasks = _tasks.where((task) => !task.isLeftover).toList();
    final newLeftovers = currentTasks
        .where((task) => !task.completed)
        .map(
          (task) => task.copyWith(
            isLeftover: true,
            completed: false,
            createdDateKey: previousDateKey,
          ),
        )
        .toList();

    _tasks = newLeftovers;
    _currentDateKey = nextDateKey;
  }

  void _applyCompletionHistoryDelta(Map<String, bool> previousCompleted) {
    final todayKey = _currentDateKey;
    var delta = 0;

    for (final task in _tasks.where((task) => !task.isBigGoal)) {
      final before = previousCompleted[task.id] ?? false;
      if (before == task.completed) {
        continue;
      }
      delta += task.completed ? 1 : -1;
    }

    if (delta == 0) {
      return;
    }

    final updated = (_completionHistory[todayKey] ?? 0) + delta;
    if (updated <= 0) {
      _completionHistory.remove(todayKey);
    } else {
      _completionHistory[todayKey] = updated;
    }
  }

  void _toggleTask(String id) {
    final tappedTaskBefore = _tasks.firstWhere((task) => task.id == id);
    final previousTasks = {for (final task in _tasks) task.id: task};

    setState(() {
      if (tappedTaskBefore.isBigGoal) {
        final childTasks = _tasks
            .where((task) => task.parentGoalId == tappedTaskBefore.id)
            .toList();
        final shouldComplete = !childTasks.every((task) => task.completed);
        _tasks = _tasks.map((task) {
          if (task.id == tappedTaskBefore.id ||
              task.parentGoalId == tappedTaskBefore.id) {
            final shouldClaimReward =
                !task.isBigGoal && shouldComplete && !task.rewardClaimed;
            return task.copyWith(
              completed: shouldComplete,
              rewardClaimed: task.rewardClaimed || shouldClaimReward,
            );
          }
          return task;
        }).toList();
      } else {
        _tasks = _tasks
            .map(
              (task) => task.id == id
                  ? task.copyWith(
                      completed: !task.completed,
                      rewardClaimed: task.rewardClaimed || !task.completed,
                    )
                  : task,
            )
            .toList();
      }

      _syncBigGoalState();
      _coins = (_coins + _completionCoinDelta(previousTasks)).clamp(0, 1 << 30);
      _applyCompletionHistoryDelta({
        for (final entry in previousTasks.entries)
          entry.key: entry.value.completed,
      });
      final tappedTaskAfter = _tasks.firstWhere((task) => task.id == id);
      if (tappedTaskBefore.isLeftover &&
          !tappedTaskBefore.completed &&
          tappedTaskAfter.completed) {
        _gubbyMessageOverride = 'Great work friend!';
        _gubbyMessageRevision++;
      }
    });
    _schedulePersist();
  }

  int _completionCoinDelta(Map<String, PlannerTask> previousTasks) {
    var delta = 0;
    for (final task in _tasks) {
      final before = previousTasks[task.id];
      if (before == null || before.completed == task.completed) {
        continue;
      }
      final coins = task.coins ?? 0;
      final justEarned =
          task.completed && !(before.rewardClaimed) && task.rewardClaimed;
      if (justEarned) {
        delta += coins;
      }
    }
    return delta;
  }

  void _syncBigGoalState() {
    _tasks = _tasks.map((task) {
      if (!task.isBigGoal) {
        return _normalizedTask(task);
      }

      final children = _tasks
          .where((child) => child.parentGoalId == task.id)
          .toList();
      return _normalizedTask(
        task.copyWith(
          completed:
              children.isNotEmpty && children.every((child) => child.completed),
        ),
      );
    }).toList();
  }

  void _deleteTask(String id) {
    final target = _tasks.firstWhere((task) => task.id == id);
    final idsToRemove = <String>{
      id,
      if (target.isBigGoal)
        ..._tasks
            .where((task) => task.parentGoalId == id)
            .map((task) => task.id),
    };
    if (target.isSubgoal && target.parentGoalId != null) {
      final siblingSubgoals = _tasks
          .where((task) => task.parentGoalId == target.parentGoalId)
          .toList();
      if (siblingSubgoals.length == 1) {
        idsToRemove.add(target.parentGoalId!);
      }
    }

    setState(() {
      _tasks = _tasks.where((task) => !idsToRemove.contains(task.id)).toList();
      if (_selectedGoalId != null && idsToRemove.contains(_selectedGoalId)) {
        _selectedGoalId = null;
      }
      _syncBigGoalState();
    });
    _schedulePersist();
  }

  void _purchaseReward(ShopReward reward) {
    if (_ownedRewardTitles.contains(reward.title) || _coins < reward.price) {
      return;
    }
    setState(() {
      _coins -= reward.price;
      _ownedRewardTitles.add(reward.title);
    });
    _schedulePersist();
  }

  void _equipReward(ShopReward reward) {
    if (!_ownedRewardTitles.contains(reward.title)) {
      return;
    }
    setState(() {
      if (reward.category == ShopRewardCategory.tankDecoration) {
        _equippedTankAsset = _equippedTankAsset == reward.assetPath
            ? defaultTankPanelAsset
            : reward.assetPath;
      } else {
        _equippedAvatarAsset = _equippedAvatarAsset == reward.assetPath
            ? defaultGubbyAsset
            : reward.assetPath;
      }
    });
    _schedulePersist();
  }

  void _saveGoalDetail(
    PlannerTask updatedGoal,
    List<PlannerTask> updatedSubgoals,
  ) {
    setState(() {
      final preservedOrder = <PlannerTask>[];
      for (final task in _tasks) {
        if (task.id == updatedGoal.id || task.parentGoalId == updatedGoal.id) {
          continue;
        }
        preservedOrder.add(task);
      }

      final insertIndex = _tasks.indexWhere(
        (task) =>
            task.id == updatedGoal.id || task.parentGoalId == updatedGoal.id,
      );
      final normalizedGoal = _normalizedTask(updatedGoal);
      final normalizedSubgoals = updatedSubgoals.map(_normalizedTask).toList();
      final rebuilt = [...preservedOrder];
      final safeIndex = insertIndex == -1 ? rebuilt.length : insertIndex;
      rebuilt.insert(safeIndex, normalizedGoal);
      rebuilt.insertAll(safeIndex + 1, normalizedSubgoals);
      _tasks = rebuilt;
      _syncBigGoalState();
    });
    _schedulePersist();
  }

  Future<void> _openAddGoalComposer() async {
    final result = await showModalBottomSheet<_GoalComposerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GoalComposerSheet(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final mainGoalId = 'task-$timestamp';
      final newTasks = <PlannerTask>[
        _normalizedTask(
          PlannerTask(
            id: mainGoalId,
            title: result.title,
            details: result.details,
            tag: result.bigGoal ? 'Big goal' : null,
            reward: result.bigGoal ? null : result.durationLabel,
            isBigGoal: result.bigGoal,
            durationLabel: result.bigGoal ? null : result.durationLabel,
            coins: result.bigGoal ? null : result.coins,
            createdDateKey: _currentDateKey,
          ),
        ),
      ];

      if (result.bigGoal) {
        for (var i = 0; i < result.subgoals.length; i++) {
          final subgoal = result.subgoals[i];
          newTasks.add(
            _normalizedTask(
              PlannerTask(
                id: 'subgoal-$timestamp-$i',
                title: subgoal.title,
                details: subgoal.details,
                tag: 'Subgoal',
                reward: subgoal.durationLabel,
                isSubgoal: true,
                parentGoalId: mainGoalId,
                durationLabel: subgoal.durationLabel,
                coins: subgoal.coins,
                createdDateKey: _currentDateKey,
              ),
            ),
          );
        }
      }

      _tasks = [..._tasks, ...newTasks];
      _syncBigGoalState();
    });
    _schedulePersist();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGoal = _selectedGoalId == null
        ? null
        : _tasks.cast<PlannerTask?>().firstWhere(
            (task) => task?.id == _selectedGoalId,
            orElse: () => null,
          );
    final selectedSubgoals = selectedGoal == null
        ? const <PlannerTask>[]
        : _tasks.where((task) => task.parentGoalId == selectedGoal.id).toList();
    final progressTasks = _tasks.where((task) => !task.isBigGoal).toList();
    final mainPlannerTasks = _tasks.where((task) => !task.isLeftover).toList();
    final leftoverTasks = _tasks.where((task) => task.isLeftover).toList();
    final completedGoals = progressTasks.where((task) => task.completed).length;
    final totalGoals = progressTasks.length;
    final progressPercent = totalGoals == 0 ? 0.0 : completedGoals / totalGoals;
    final screens = [
      HomeScreen(
        tasks: mainPlannerTasks,
        leftoverTasks: leftoverTasks,
        equippedAvatarAsset: _equippedAvatarAsset,
        equippedTankAsset: _equippedTankAsset,
        gubbyMessageOverride: _gubbyMessageOverride,
        gubbyMessageRevision: _gubbyMessageRevision,
        progressPercent: progressPercent,
        completedGoals: completedGoals,
        totalGoals: totalGoals,
        onOpenGoalDetail: _openGoalDetail,
        onToggleTask: _toggleTask,
        onDeleteTask: _deleteTask,
        onAddGoal: _openAddGoalComposer,
      ),
      ShopScreen(
        coins: _coins,
        equippedAvatarAsset: _equippedAvatarAsset,
        equippedTankAsset: _equippedTankAsset,
        ownedRewardTitles: _ownedRewardTitles,
        onPurchase: _purchaseReward,
        onEquip: _equipReward,
      ),
      ProfileScreen(
        profile: _profile,
        completionHistory: _completionHistory,
        authBusy: _authBusy,
        authError: _authError,
        onCreateAccount: _createAccount,
        onSignIn: _signIn,
        onSignOut: _signOut,
        onDeleteAccount: _deleteAccount,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: Color(0xFFF1FAFF))),
          SafeArea(
            child: IndexedStack(index: _index, children: screens),
          ),
          if (selectedGoal != null)
            Positioned.fill(
              child: Material(
                color: Colors.black.withValues(alpha: 0.22),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GoalDetailScreen(
                      goal: selectedGoal,
                      subgoals: selectedSubgoals,
                      benchmarks: focusTimeBenchmarks,
                      onToggleTask: _toggleTask,
                      onDeleteTask: _deleteTask,
                      onSaveGoal: _saveGoalDetail,
                      onClose: _closeGoalDetail,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF9FEFF), Color(0xFFDDF4FF), Color(0xFFC7E8FF)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15304D).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.65),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: _index == 0,
                      onTap: () => setState(() => _index = 0),
                    ),
                    _NavItem(
                      icon: Icons.storefront_rounded,
                      label: 'Shop',
                      selected: _index == 1,
                      onTap: () => setState(() => _index = 1),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      selected: _index == 2,
                      onTap: () => setState(() => _index = 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 86,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? const [
                          Color(0xFFF9FEFF),
                          Color(0xFFBFE9FF),
                          Color(0xFF59B8EE),
                        ]
                      : const [
                          Color(0xFFFFFFFF),
                          Color(0xFFEAF7FF),
                          Color(0xFFD4EEFF),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: selected ? 0.98 : 0.92),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF15304D).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 9,
                    child: Container(
                      width: 28,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 10,
                    child: Container(
                      width: 16,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icon,
                      size: 26,
                      color: selected
                          ? FishlyTheme.skyDeep
                          : const Color(0xFF5E8BA8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 11,
                color: selected ? FishlyTheme.navy : const Color(0xFF5E8BA8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalComposerResult {
  const _GoalComposerResult({
    required this.title,
    required this.details,
    required this.bigGoal,
    required this.durationLabel,
    required this.coins,
    required this.subgoals,
  });

  final String title;
  final String details;
  final bool bigGoal;
  final String? durationLabel;
  final int? coins;
  final List<_GoalComposerSubgoal> subgoals;
}

class _GoalComposerSubgoal {
  const _GoalComposerSubgoal({
    required this.title,
    required this.details,
    required this.durationLabel,
    required this.coins,
  });

  final String title;
  final String details;
  final String durationLabel;
  final int coins;
}

class _GoalComposerSheet extends StatefulWidget {
  const _GoalComposerSheet();

  @override
  State<_GoalComposerSheet> createState() => _GoalComposerSheetState();
}

class _GoalComposerSheetState extends State<_GoalComposerSheet> {
  final _goalController = TextEditingController();
  final _detailsController = TextEditingController();
  final _subgoals = <_SubgoalDraft>[_SubgoalDraft()];
  final _focusMinutesController = TextEditingController();
  int activeSubgoalIndex = 0;
  bool bigGoal = false;

  @override
  void dispose() {
    _goalController.dispose();
    _detailsController.dispose();
    _focusMinutesController.dispose();
    for (final subgoal in _subgoals) {
      subgoal.controller.dispose();
      subgoal.detailsController.dispose();
      subgoal.focusMinutesController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FDFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E6F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add a goal',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(
                  hintText: 'Goal title',
                  hintStyle: TextStyle(color: Color(0x7A35506A)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Goal details',
                  hintStyle: TextStyle(color: Color(0x7A35506A)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE1EEF6)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Big goal?',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Turn this on if this goal should hold timed subgoals.',
                            style: TextStyle(
                              color: FishlyTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: bigGoal,
                      activeThumbColor: FishlyTheme.skyDeep,
                      onChanged: (value) => setState(() => bigGoal = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!bigGoal) ...[
                Text(
                  'Choose focus time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _focusMinutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Focus time in minutes',
                    hintStyle: TextStyle(color: Color(0x7A35506A)),
                  ),
                ),
              ],
              if (bigGoal) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subgoals',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => setState(() {
                        _subgoals.add(_SubgoalDraft());
                        activeSubgoalIndex = _subgoals.length - 1;
                      }),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F7FF),
                        foregroundColor: FishlyTheme.skyDeep,
                      ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _subgoals.length; i++) ...[
                  _SubgoalEditor(
                    index: i,
                    draft: _subgoals[i],
                    expanded: i == activeSubgoalIndex,
                    onTapHeader: () => setState(() => activeSubgoalIndex = i),
                  ),
                  if (i != _subgoals.length - 1) const SizedBox(height: 16),
                ],
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: FishlyTheme.skyDeep,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('Add Goal to Home List'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please give your goal a title');
      return;
    }

    if (bigGoal) {
      final hasUntitledSubgoal = _subgoals.any(
        (draft) => draft.controller.text.trim().isEmpty,
      );
      if (hasUntitledSubgoal) {
        _showMessage('Please give each subgoal a title');
        return;
      }

      final invalidSubgoalMinutes = _subgoals
          .map(
            (draft) => int.tryParse(draft.focusMinutesController.text.trim()),
          )
          .any((minutes) => minutes == null || minutes <= 0);
      if (invalidSubgoalMinutes) {
        _showMessage(
          'Please enter a valid focus time in minutes for each subgoal',
        );
        return;
      }

      final tooLargeSubgoalMinutes = _subgoals
          .map(
            (draft) =>
                int.tryParse(draft.focusMinutesController.text.trim()) ?? 0,
          )
          .any((minutes) => minutes > maxFocusMinutes);
      if (tooLargeSubgoalMinutes) {
        _showMessage(
          "Oops! You've entered a time value that is too large. The focus time must be less than 1440 minutes (24 hours)",
        );
        return;
      }

      final subgoals = _subgoals
          .map((draft) {
            final minutes = int.parse(draft.focusMinutesController.text.trim());
            return _GoalComposerSubgoal(
              title: draft.controller.text.trim(),
              details: draft.detailsController.text.trim(),
              durationLabel: formatFocusTimeLabel(minutes),
              coins: coinsForFocusMinutes(minutes),
            );
          })
          .where((subgoal) => subgoal.title.isNotEmpty)
          .toList();
      if (subgoals.isEmpty) {
        _showMessage('Please add at least one subgoal title');
        return;
      }
      Navigator.of(context).pop(
        _GoalComposerResult(
          title: title,
          details: _detailsController.text.trim(),
          bigGoal: true,
          durationLabel: null,
          coins: null,
          subgoals: subgoals,
        ),
      );
      return;
    }

    final minutes = int.tryParse(_focusMinutesController.text.trim());
    if (minutes == null || minutes <= 0) {
      _showMessage('Please enter a valid focus time in minutes');
      return;
    }
    if (minutes > maxFocusMinutes) {
      _showMessage(
        "Oops! You've entered a time value that is too large. The focus time must be less than 1440 minutes (24 hours)",
      );
      return;
    }

    Navigator.of(context).pop(
      _GoalComposerResult(
        title: title,
        details: _detailsController.text.trim(),
        bigGoal: false,
        durationLabel: formatFocusTimeLabel(minutes),
        coins: coinsForFocusMinutes(minutes),
        subgoals: const [],
      ),
    );
  }

  Future<void> _showMessage(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Just one thing'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }
}

class _SubgoalDraft {
  _SubgoalDraft()
    : controller = TextEditingController(),
      detailsController = TextEditingController(),
      focusMinutesController = TextEditingController();

  final TextEditingController controller;
  final TextEditingController detailsController;
  final TextEditingController focusMinutesController;
}

class _SubgoalEditor extends StatelessWidget {
  const _SubgoalEditor({
    required this.index,
    required this.draft,
    required this.expanded,
    required this.onTapHeader,
  });

  final int index;
  final _SubgoalDraft draft;
  final bool expanded;
  final VoidCallback onTapHeader;

  @override
  Widget build(BuildContext context) {
    final title = draft.controller.text.trim();
    final summary = title.isEmpty ? 'Subgoal ${index + 1}' : title;
    final minutes = int.tryParse(draft.focusMinutesController.text.trim());
    final summaryReward = minutes == null || minutes <= 0
        ? null
        : coinsForFocusMinutes(minutes);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (!expanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            minutes == null || minutes <= 0
                                ? 'Add focus time'
                                : '${formatFocusTimeLabel(minutes)} | $summaryReward coins',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: FishlyTheme.skyDeep,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            TextField(
              controller: draft.controller,
              decoration: InputDecoration(
                hintText: 'Subgoal ${index + 1} title',
                hintStyle: const TextStyle(color: Color(0x7A35506A)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: draft.detailsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Subgoal details',
                hintStyle: TextStyle(color: Color(0x7A35506A)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: draft.focusMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Focus time in minutes',
                hintStyle: TextStyle(color: Color(0x7A35506A)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

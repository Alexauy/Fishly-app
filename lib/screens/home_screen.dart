import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import '../widgets/app_sections.dart';
import '../widgets/fish_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.leftoverTasks,
    required this.equippedAvatarAsset,
    required this.equippedTankAsset,
    required this.gubbyMessageOverride,
    required this.gubbyMessageRevision,
    required this.progressPercent,
    required this.completedGoals,
    required this.totalGoals,
    required this.onOpenGoalDetail,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onAddGoal,
  });

  final List<PlannerTask> tasks;
  final List<PlannerTask> leftoverTasks;
  final String equippedAvatarAsset;
  final String equippedTankAsset;
  final String? gubbyMessageOverride;
  final int gubbyMessageRevision;
  final double progressPercent;
  final int completedGoals;
  final int totalGoals;
  final ValueChanged<String> onOpenGoalDetail;
  final ValueChanged<String> onToggleTask;
  final ValueChanged<String> onDeleteTask;
  final VoidCallback onAddGoal;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  Timer? _speechTimer;
  String? _activeQuote;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showRandomQuote();
      }
    });
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gubbyMessageOverride != null &&
        widget.gubbyMessageRevision != oldWidget.gubbyMessageRevision) {
      _showQuote(widget.gubbyMessageOverride!);
    }
  }

  void _showQuote(String quote) {
    _speechTimer?.cancel();
    setState(() {
      _activeQuote = quote;
      _showBubble = true;
    });

    _speechTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showBubble = false;
      });
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted || _showBubble) {
          return;
        }
        setState(() {
          _activeQuote = null;
        });
      });
    });
  }

  void _showRandomQuote() {
    final quote = bubbleQuotes[_random.nextInt(bubbleQuotes.length)];
    _showQuote(quote);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Home',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 12),
          _AquariumHeader(
            equippedAvatarAsset: widget.equippedAvatarAsset,
            equippedTankAsset: widget.equippedTankAsset,
            activeQuote: _activeQuote,
            showBubble: _showBubble,
            onTapGubby: _showRandomQuote,
          ),
          const SizedBox(height: 18),
          _ProgressStrip(
            progressPercent: widget.progressPercent,
            completedGoals: widget.completedGoals,
            totalGoals: widget.totalGoals,
          ),
          const SizedBox(height: 18),
          _PlannerPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  context,
                  title: 'Planner',
                  subtitle: widget.tasks.isEmpty
                      ? 'Add your first goal to start filling the planner.'
                      : "Tap the circle to mark a goal complete or tap on the goal's title to inspect it",
                ),
                const SizedBox(height: 10),
                if (widget.tasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No goals yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use the add button below to create a goal or a big goal with subgoals.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                if (widget.tasks.isNotEmpty)
                  ..._buildPlannerGroups(widget.tasks),
                _AddGoalRow(onTap: widget.onAddGoal),
              ],
            ),
          ),
          if (widget.leftoverTasks.isNotEmpty) ...[
            const SizedBox(height: 18),
            _PlannerPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    context,
                    title: "Yesterday's Leftovers",
                    subtitle:
                        "Looks like these tasks weren't completed yesterday, let's do what we can to work on them today!",
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < widget.leftoverTasks.length; i++) ...[
                    PlannerTaskTile(
                      task: widget.leftoverTasks[i],
                      onToggle: () =>
                          widget.onToggleTask(widget.leftoverTasks[i].id),
                      onDelete: () =>
                          widget.onDeleteTask(widget.leftoverTasks[i].id),
                      indent: widget.leftoverTasks[i].isSubgoal ? 22 : 0,
                    ),
                    if (i != widget.leftoverTasks.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          const DebrisBorder(),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  List<Widget> _buildPlannerGroups(List<PlannerTask> tasks) {
    final widgets = <Widget>[];
    final standaloneTasks = tasks
        .where((task) => !task.isBigGoal && !task.isSubgoal)
        .toList();
    final bigGoals = tasks.where((task) => task.isBigGoal).toList();

    for (final bigGoal in bigGoals) {
      final groupedTasks = [
        bigGoal,
        ...tasks.where((task) => task.parentGoalId == bigGoal.id),
      ];
      widgets.add(
        Column(
          children: [
            for (var i = 0; i < groupedTasks.length; i++) ...[
              PlannerTaskTile(
                task: groupedTasks[i],
                onToggle: () => widget.onToggleTask(groupedTasks[i].id),
                onTap: () => widget.onOpenGoalDetail(groupedTasks[i].id),
                onDelete: () => widget.onDeleteTask(groupedTasks[i].id),
                indent: groupedTasks[i].isSubgoal ? 22 : 0,
              ),
              if (i != groupedTasks.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 14),
            const _GoalDivider(),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 14));
    }

    if (standaloneTasks.isNotEmpty) {
      for (var i = 0; i < standaloneTasks.length; i++) {
        widgets.add(
          PlannerTaskTile(
            task: standaloneTasks[i],
            onToggle: () => widget.onToggleTask(standaloneTasks[i].id),
            onTap: () => widget.onOpenGoalDetail(standaloneTasks[i].id),
            onDelete: () => widget.onDeleteTask(standaloneTasks[i].id),
          ),
        );
        if (i != standaloneTasks.length - 1) {
          widgets.add(const SizedBox(height: 14));
          widgets.add(const _GoalDivider());
          widgets.add(const SizedBox(height: 14));
        }
      }
    }

    return widgets;
  }
}

class _PlannerPanel extends StatelessWidget {
  const _PlannerPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDF5FF), Color(0xFFB7E5FF), Color(0xFFD4F0FF)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: FishlyTheme.skyDeep.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GoalDivider extends StatelessWidget {
  const _GoalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2A86BE), Color(0xFF165F93)],
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    required this.progressPercent,
    required this.completedGoals,
    required this.totalGoals,
  });

  final double progressPercent;
  final int completedGoals;
  final int totalGoals;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(progressPercent * 100).round()}%';

    return GlassSection(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progressPercent,
                  strokeWidth: 7,
                  backgroundColor: FishlyTheme.sky.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation(FishlyTheme.skyDeep),
                ),
                Center(
                  child: Text(
                    percentText,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: FishlyTheme.skyDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  totalGoals == 0
                      ? 'Your planner is empty right now.'
                      : '$completedGoals of $totalGoals goals completed today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AquariumHeader extends StatelessWidget {
  const _AquariumHeader({
    required this.equippedAvatarAsset,
    required this.equippedTankAsset,
    required this.activeQuote,
    required this.showBubble,
    required this.onTapGubby,
  });

  final String equippedAvatarAsset;
  final String equippedTankAsset;
  final String? activeQuote;
  final bool showBubble;
  final VoidCallback onTapGubby;

  @override
  Widget build(BuildContext context) {
    return HeroSection(
      backgroundAssetPath: equippedTankAsset,
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            if (activeQuote != null)
              Positioned(
                left: 14,
                top: 18,
                right: 112,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 700),
                  opacity: showBubble ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Gubby says: "$activeQuote"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 18,
              bottom: 22,
              child: GestureDetector(
                onTap: onTapGubby,
                child: FishAvatar(
                  size: 148,
                  gold: true,
                  assetPath: equippedAvatarAsset,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGoalRow extends StatelessWidget {
  const _AddGoalRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: FishlyTheme.skyDeep.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_rounded, color: FishlyTheme.skyDeep),
            SizedBox(width: 12),
            Text(
              'Add a new goal to the list',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

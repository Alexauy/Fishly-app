import 'package:flutter/material.dart';

import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import '../widgets/app_sections.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.subgoals,
    required this.benchmarks,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onSaveGoal,
    required this.onClose,
  });

  final PlannerTask goal;
  final List<PlannerTask> subgoals;
  final List<({int minutes, int coins})> benchmarks;
  final ValueChanged<String> onToggleTask;
  final ValueChanged<String> onDeleteTask;
  final void Function(
    PlannerTask updatedGoal,
    List<PlannerTask> updatedSubgoals,
  )
  onSaveGoal;
  final VoidCallback onClose;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _focusMinutesController;
  late List<_EditableSubgoal> _subgoals;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _detailsController = TextEditingController(text: widget.goal.details);
    _focusMinutesController = TextEditingController(
      text: parseFocusTimeLabel(widget.goal.durationLabel)?.toString() ?? '',
    );
    _subgoals = widget.subgoals
        .map((task) => _EditableSubgoal.fromTask(task))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _focusMinutesController.dispose();
    for (final subgoal in _subgoals) {
      subgoal.dispose();
    }
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please give your goal a title');
      return;
    }

    int? goalMinutes;
    if (!widget.goal.isBigGoal) {
      goalMinutes = int.tryParse(_focusMinutesController.text.trim());
      if (goalMinutes == null || goalMinutes <= 0) {
        _showMessage('Please enter a valid focus time in minutes');
        return;
      }
      if (goalMinutes > maxFocusMinutes) {
        _showMessage(
          "Oops! You've entered a time value that is too large. The focus time must be less than 1440 minutes (24 hours)",
        );
        return;
      }
    }

    if (widget.goal.isBigGoal &&
        _subgoals.any(
          (subgoal) => subgoal.titleController.text.trim().isEmpty,
        )) {
      _showMessage('Please give each subgoal a title');
      return;
    }

    if (widget.goal.isBigGoal) {
      final invalidSubgoalMinutes = _subgoals
          .map(
            (subgoal) =>
                int.tryParse(subgoal.focusMinutesController.text.trim()),
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
            (subgoal) =>
                int.tryParse(subgoal.focusMinutesController.text.trim()) ?? 0,
          )
          .any((minutes) => minutes > maxFocusMinutes);
      if (tooLargeSubgoalMinutes) {
        _showMessage(
          "Oops! You've entered a time value that is too large. The focus time must be less than 1440 minutes (24 hours)",
        );
        return;
      }
    }

    final updatedGoal = widget.goal.copyWith(
      title: title,
      details: _detailsController.text.trim(),
      durationLabel: widget.goal.isBigGoal
          ? null
          : formatFocusTimeLabel(goalMinutes!),
      coins: widget.goal.isBigGoal ? null : coinsForFocusMinutes(goalMinutes!),
    );

    final updatedSubgoals = widget.goal.isBigGoal
        ? _subgoals
              .where(
                (subgoal) => subgoal.titleController.text.trim().isNotEmpty,
              )
              .map((subgoal) {
                final minutes = int.parse(
                  subgoal.focusMinutesController.text.trim(),
                );
                return PlannerTask(
                  id: subgoal.id,
                  title: subgoal.titleController.text.trim(),
                  details: subgoal.detailsController.text.trim(),
                  completed: subgoal.completed,
                  isSubgoal: true,
                  isLeftover: subgoal.isLeftover,
                  rewardClaimed: subgoal.rewardClaimed,
                  parentGoalId: widget.goal.id,
                  durationLabel: formatFocusTimeLabel(minutes),
                  coins: coinsForFocusMinutes(minutes),
                  createdDateKey: subgoal.createdDateKey,
                );
              })
              .toList()
        : const <PlannerTask>[];

    widget.onSaveGoal(updatedGoal, updatedSubgoals);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.subgoals
        .where((task) => task.completed)
        .length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FDFF), Color(0xFFECF8FF)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AeroDeleteButton(
                      onPressed: () {
                        widget.onDeleteTask(widget.goal.id);
                        widget.onClose();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                HeroSection(
                  gradientColors: const [Color(0xFF8FD1F3), Color(0xFFBEE9FF)],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: const Color(0xFF163F5B),
                              fontSize: 30,
                            ),
                        decoration: InputDecoration(
                          hintText: 'Goal title',
                          hintStyle: const TextStyle(color: Color(0x82163F5B)),
                          border: _heroBorder(),
                          enabledBorder: _heroBorder(),
                          focusedBorder: _heroBorder(),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.38),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _detailsController,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF163F5B),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Goal details',
                          hintStyle: const TextStyle(color: Color(0x82163F5B)),
                          border: _heroBorder(),
                          enabledBorder: _heroBorder(),
                          focusedBorder: _heroBorder(),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.goal.isBigGoal
                            ? 'Edit this big goal and manage its subgoals here.'
                            : 'Edit the goal details and focus time here.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      if (!widget.goal.isBigGoal) ...[
                        Text(
                          'Time',
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
                      if (widget.goal.isBigGoal)
                        MiniStatCard(
                          label: 'Progress',
                          value: '$completedCount/${widget.subgoals.length}',
                          caption: 'subgoals done',
                        ),
                    ],
                  ),
                ),
                if (widget.goal.isBigGoal) ...[
                  const SizedBox(height: 18),
                  GlassSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subgoals',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () {
                                setState(() {
                                  _subgoals.add(_EditableSubgoal.newSubgoal());
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < _subgoals.length; i++) ...[
                          _EditableSubgoalCard(
                            draft: _subgoals[i],
                            onToggle:
                                _subgoals[i].id.isNotEmpty &&
                                    !_subgoals[i].id.startsWith('draft-')
                                ? () {
                                    widget.onToggleTask(_subgoals[i].id);
                                    setState(() {
                                      _subgoals[i].completed =
                                          !_subgoals[i].completed;
                                    });
                                  }
                                : null,
                            onDelete: () {
                              setState(() {
                                final removed = _subgoals.removeAt(i);
                                if (!removed.id.startsWith('draft-')) {
                                  widget.onDeleteTask(removed.id);
                                }
                                removed.dispose();
                              });
                            },
                          ),
                          if (i != _subgoals.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: FishlyTheme.skyDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _heroBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0x99DDF4FF), width: 1.1),
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

class _EditableSubgoal {
  _EditableSubgoal({
    required this.id,
    required this.titleController,
    required this.detailsController,
    required this.focusMinutesController,
    required this.completed,
    required this.isLeftover,
    required this.rewardClaimed,
    required this.createdDateKey,
  });

  factory _EditableSubgoal.fromTask(PlannerTask task) => _EditableSubgoal(
    id: task.id,
    titleController: TextEditingController(text: task.title),
    detailsController: TextEditingController(text: task.details),
    focusMinutesController: TextEditingController(
      text: parseFocusTimeLabel(task.durationLabel)?.toString() ?? '',
    ),
    completed: task.completed,
    isLeftover: task.isLeftover,
    rewardClaimed: task.rewardClaimed,
    createdDateKey: task.createdDateKey,
  );

  factory _EditableSubgoal.newSubgoal() => _EditableSubgoal(
    id: 'draft-${DateTime.now().microsecondsSinceEpoch}',
    titleController: TextEditingController(),
    detailsController: TextEditingController(),
    focusMinutesController: TextEditingController(),
    completed: false,
    isLeftover: false,
    rewardClaimed: false,
    createdDateKey: null,
  );

  final String id;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  final TextEditingController focusMinutesController;
  bool completed;
  final bool isLeftover;
  final bool rewardClaimed;
  final String? createdDateKey;

  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    focusMinutesController.dispose();
  }
}

class _EditableSubgoalCard extends StatelessWidget {
  const _EditableSubgoalCard({
    required this.draft,
    required this.onToggle,
    required this.onDelete,
  });

  final _EditableSubgoal draft;
  final VoidCallback? onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final minutes = int.tryParse(draft.focusMinutesController.text.trim());
    final summaryReward = minutes == null || minutes <= 0
        ? null
        : coinsForFocusMinutes(minutes);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.75),
                    border: Border.all(
                      color: FishlyTheme.skyDeep.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: draft.completed
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: FishlyTheme.skyDeep,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: draft.titleController,
                      decoration: const InputDecoration(
                        hintText: 'Subgoal title',
                        hintStyle: TextStyle(color: Color(0x7A35506A)),
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AeroDeleteButton(onPressed: onDelete),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: draft.focusMinutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Focus time in minutes',
              hintStyle: const TextStyle(color: Color(0x7A35506A)),
              helperText: summaryReward == null
                  ? null
                  : '${formatFocusTimeLabel(minutes!)} earns $summaryReward coins',
            ),
          ),
        ],
      ),
    );
  }
}

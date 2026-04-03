import 'package:flutter/material.dart';

import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import '../widgets/app_sections.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.subgoals,
    required this.durations,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onSaveGoal,
    required this.onClose,
  });

  final PlannerTask goal;
  final List<PlannerTask> subgoals;
  final List<(String, int)> durations;
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
  late int _selectedDuration;
  late List<_EditableSubgoal> _subgoals;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _detailsController = TextEditingController(text: widget.goal.details);
    _selectedDuration = _durationIndexFor(widget.goal.durationLabel);
    _subgoals = widget.subgoals
        .map(
          (task) => _EditableSubgoal.fromTask(
            task,
            _durationIndexFor(task.durationLabel),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    for (final subgoal in _subgoals) {
      subgoal.dispose();
    }
    super.dispose();
  }

  int _durationIndexFor(String? label) {
    final index = widget.durations.indexWhere(
      (duration) => duration.$1 == label,
    );
    return index == -1 ? 0 : index;
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('Please give your goal a title');
      return;
    }

    if (widget.goal.isBigGoal &&
        _subgoals.any(
          (subgoal) => subgoal.titleController.text.trim().isEmpty,
        )) {
      _showMessage('Please give each subgoal a title');
      return;
    }

    final updatedGoal = widget.goal.copyWith(
      title: title,
      details: _detailsController.text.trim(),
      durationLabel: widget.goal.isBigGoal
          ? null
          : widget.durations[_selectedDuration].$1,
      coins: widget.goal.isBigGoal
          ? null
          : widget.durations[_selectedDuration].$2,
    );

    final updatedSubgoals = widget.goal.isBigGoal
        ? _subgoals
              .where(
                (subgoal) => subgoal.titleController.text.trim().isNotEmpty,
              )
              .map(
                (subgoal) => PlannerTask(
                  id: subgoal.id,
                  title: subgoal.titleController.text.trim(),
                  details: subgoal.detailsController.text.trim(),
                  completed: subgoal.completed,
                  isSubgoal: true,
                  isLeftover: subgoal.isLeftover,
                  rewardClaimed: subgoal.rewardClaimed,
                  parentGoalId: widget.goal.id,
                  durationLabel: widget.durations[subgoal.selectedDuration].$1,
                  coins: widget.durations[subgoal.selectedDuration].$2,
                  createdDateKey: subgoal.createdDateKey,
                ),
              )
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
                        _durationWrap(),
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
                                  _subgoals.add(
                                    _EditableSubgoal.newSubgoal(
                                      widget.durations,
                                    ),
                                  );
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
                            durations: widget.durations,
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
                            onDurationChanged: (value) {
                              setState(
                                () => _subgoals[i].selectedDuration = value,
                              );
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

  Widget _durationWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(widget.durations.length, (index) {
        final duration = widget.durations[index];
        final selected = _selectedDuration == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedDuration = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEDF8FF) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? FishlyTheme.skyDeep.withValues(alpha: 0.24)
                    : FishlyTheme.navy.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              '${duration.$1} | ${duration.$2}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF0E5F8D)
                    : const Color(0xFF35506A),
              ),
            ),
          ),
        );
      }),
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
    required this.selectedDuration,
    required this.completed,
    required this.isLeftover,
    required this.rewardClaimed,
    required this.createdDateKey,
  });

  factory _EditableSubgoal.fromTask(PlannerTask task, int selectedDuration) =>
      _EditableSubgoal(
        id: task.id,
        titleController: TextEditingController(text: task.title),
        detailsController: TextEditingController(text: task.details),
        selectedDuration: selectedDuration,
        completed: task.completed,
        isLeftover: task.isLeftover,
        rewardClaimed: task.rewardClaimed,
        createdDateKey: task.createdDateKey,
      );

  factory _EditableSubgoal.newSubgoal(List<(String, int)> durations) =>
      _EditableSubgoal(
        id: 'draft-${DateTime.now().microsecondsSinceEpoch}',
        titleController: TextEditingController(),
        detailsController: TextEditingController(),
        selectedDuration: 0,
        completed: false,
        isLeftover: false,
        rewardClaimed: false,
        createdDateKey: null,
      );

  final String id;
  final TextEditingController titleController;
  final TextEditingController detailsController;
  int selectedDuration;
  bool completed;
  final bool isLeftover;
  final bool rewardClaimed;
  final String? createdDateKey;

  void dispose() {
    titleController.dispose();
    detailsController.dispose();
  }
}

class _EditableSubgoalCard extends StatelessWidget {
  const _EditableSubgoalCard({
    required this.draft,
    required this.durations,
    required this.onToggle,
    required this.onDelete,
    required this.onDurationChanged,
  });

  final _EditableSubgoal draft;
  final List<(String, int)> durations;
  final VoidCallback? onToggle;
  final VoidCallback onDelete;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(durations.length, (index) {
              final duration = durations[index];
              final selected = draft.selectedDuration == index;
              return GestureDetector(
                onTap: () => onDurationChanged(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFEDF8FF) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? FishlyTheme.skyDeep.withValues(alpha: 0.24)
                          : FishlyTheme.navy.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    '${duration.$1} | ${duration.$2}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF0E5F8D)
                          : const Color(0xFF35506A),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

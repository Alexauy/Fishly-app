import 'package:flutter/material.dart';

import '../widgets/app_sections.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key, required this.onOpenGoalDetail});

  final VoidCallback onOpenGoalDetail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 180),
      child: GlassSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planner moved home',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'The main goal list, check-off actions, and add-goal flow now live on Home so everything important is in one place.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onOpenGoalDetail,
              child: const Text('Open example goal detail'),
            ),
          ],
        ),
      ),
    );
  }
}

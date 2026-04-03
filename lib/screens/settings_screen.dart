import 'package:flutter/material.dart';

import '../widgets/app_sections.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SETTINGS',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: const Color(0xFF2387C9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Layout and visual refinements can live here later.',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 28),
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
                  'Accessibility',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Readable, calm presentation for students who are already carrying enough.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const _SettingTile(
                  icon: Icons.text_fields_rounded,
                  title: 'Readable sizing',
                  subtitle: 'Large labels and high-contrast action buttons',
                  trailing: 'AA',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0x592387C9), width: 2),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF2387C9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x1A2387C9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF205D84),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

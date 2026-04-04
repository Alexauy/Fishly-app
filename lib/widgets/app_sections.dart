import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';

const _debrisAsset = 'assets/hand_drawn/debris.png';

class GlassSection extends StatelessWidget {
  const GlassSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundAssetPath,
    this.backgroundFit = BoxFit.cover,
    this.overlayColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final String? backgroundAssetPath;
  final BoxFit backgroundFit;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: backgroundAssetPath == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF7FEFF),
                      Color(0xFFDFF5FF),
                      Color(0xFFC8EBFF),
                    ],
                  )
                : null,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15304D).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.55),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (backgroundAssetPath != null)
                Positioned.fill(
                  child: Image.asset(backgroundAssetPath!, fit: backgroundFit),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        overlayColor ??
                        Colors.white.withValues(
                          alpha: backgroundAssetPath == null ? 0.18 : 0.34,
                        ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.child,
    this.backgroundAssetPath,
    this.backgroundFit = BoxFit.cover,
    this.gradientColors,
  });

  final Widget child;
  final String? backgroundAssetPath;
  final BoxFit backgroundFit;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: FishlyTheme.skyDeep.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.45),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: backgroundAssetPath == null
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              gradientColors ??
                              const [
                                Color(0xFF9DE2FF),
                                Color(0xFF5ABCF1),
                                Color(0xFF2B95D7),
                              ],
                        ),
                      ),
                    )
                  : Image.asset(backgroundAssetPath!, fit: backgroundFit),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.62),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: child),
          ],
        ),
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7FEFF), Color(0xFFD8F1FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15304D).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class DebrisBorder extends StatelessWidget {
  const DebrisBorder({super.key});

  @override
  Widget build(BuildContext context) {
    const widths = [32.0, 29.0, 34.0, 31.0, 32.0, 27.0];
    const averageSlotWidth = 30.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 280.0;
        final itemCount = (availableWidth / averageSlotWidth).ceil().clamp(
          8,
          18,
        );

        return IgnorePointer(
          child: Opacity(
            opacity: 0.5,
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < itemCount; i++)
                    Expanded(
                      child: Align(
                        alignment: i == 0
                            ? Alignment.bottomLeft
                            : i == itemCount - 1
                            ? Alignment.bottomRight
                            : Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Image.asset(
                            _debrisAsset,
                            width: widths[i % widths.length],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlannerTaskTile extends StatelessWidget {
  const PlannerTaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
    this.indent = 0,
  });

  final PlannerTask task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      decoration: task.completed ? TextDecoration.lineThrough : null,
      color: task.completed
          ? FishlyTheme.navy.withValues(alpha: 0.45)
          : FishlyTheme.navy,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      decoration: task.completed ? TextDecoration.lineThrough : null,
      color: task.completed
          ? FishlyTheme.muted.withValues(alpha: 0.8)
          : FishlyTheme.muted,
    );

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: task.completed ? 0.62 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF9FEFF), Color(0xFFDBF2FF)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF15304D).withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFDFEFF), Color(0xFFDDF2FF)],
                    ),
                    border: Border.all(
                      color: FishlyTheme.skyDeep.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: task.completed
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
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(task.title, style: titleStyle),
                            if (task.tag != null) _Pill(text: task.tag!),
                            if (task.reward != null) _Pill(text: task.reward!),
                            if (task.coins != null)
                              _Pill(
                                text:
                                    '${task.coins} ${task.coins == 1 ? 'coin' : 'coins'}',
                              ),
                          ],
                        ),
                        if (task.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(task.subtitle, style: subtitleStyle),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                AeroDeleteButton(
                  onPressed: onDelete!,
                  size: 34,
                  borderRadius: 14,
                  iconSize: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AeroDeleteButton extends StatelessWidget {
  const AeroDeleteButton({
    super.key,
    required this.onPressed,
    this.size = 38,
    this.borderRadius = 16,
    this.iconSize = 20,
  });

  final VoidCallback onPressed;
  final double size;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5FCFF), Color(0xFFD9F0FF), Color(0xFFAFDEFA)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.88),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: FishlyTheme.skyDeep.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.45),
              blurRadius: 0,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 4,
              left: 6,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.74),
                        Colors.white.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D7BBA).withValues(alpha: 0.12),
                      blurRadius: 0,
                      offset: const Offset(0, -1),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: iconSize,
                  color: const Color(0xFF0A78B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            FishlyTheme.sky.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 11,
          color: const Color(0xFF205D84),
        ),
      ),
    );
  }
}

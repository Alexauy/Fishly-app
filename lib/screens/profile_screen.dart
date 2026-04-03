import 'package:flutter/material.dart';

import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import '../widgets/app_sections.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.completionHistory,
    required this.authBusy,
    required this.authError,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onSignOut,
  });

  final FishlyUserProfile? profile;
  final Map<String, int> completionHistory;
  final bool authBusy;
  final String? authError;
  final Future<void> Function({
    required String displayName,
    required String email,
    required String password,
  })
  onCreateAccount;
  final Future<void> Function({required String email, required String password})
  onSignIn;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthEntries = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final month = now.month.toString().padLeft(2, '0');
      final dateDay = day.toString().padLeft(2, '0');
      final key = '${now.year}-$month-$dateDay';
      final daysAhead = day - now.day;
      final opacity = daysAhead <= 0
          ? 1.0
          : (1.0 - (daysAhead * 0.06)).clamp(0.35, 0.9);
      return (day: day, count: completionHistory[key] ?? 0, opacity: opacity);
    });

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
                  'PROFILE',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: const Color(0xFF2387C9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile == null ? 'Create Account' : 'Account',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                if (profile == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Save your planner, shop customizations, and completion history in one place.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 18),
                _AccountCreationPanel(
                  profile: profile,
                  authBusy: authBusy,
                  authError: authError,
                  onCreateAccount: onCreateAccount,
                  onSignIn: onSignIn,
                  onSignOut: onSignOut,
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
                  'Monthly History',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  'The number of goals completed is displayed in the lower left corner of the day',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthEntries.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 74,
                  ),
                  itemBuilder: (context, index) {
                    final item = monthEntries[index];
                    return _DayTile(
                      day: item.day,
                      count: item.count,
                      opacity: item.opacity,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const DebrisBorder(),
        ],
      ),
    );
  }
}

class _AccountCreationPanel extends StatefulWidget {
  const _AccountCreationPanel({
    required this.profile,
    required this.authBusy,
    required this.authError,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onSignOut,
  });

  final FishlyUserProfile? profile;
  final bool authBusy;
  final String? authError;
  final Future<void> Function({
    required String displayName,
    required String email,
    required String password,
  })
  onCreateAccount;
  final Future<void> Function({required String email, required String password})
  onSignIn;
  final Future<void> Function() onSignOut;

  @override
  State<_AccountCreationPanel> createState() => _AccountCreationPanelState();
}

class _AccountCreationPanelState extends State<_AccountCreationPanel> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String? _lastShownAuthError;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AccountCreationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authError != null && widget.authError != _lastShownAuthError) {
      _lastShownAuthError = widget.authError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showMessage(widget.authError!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile != null) {
      return _SignedInPanel(
        profile: widget.profile!,
        onSignOut: widget.onSignOut,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FEFF), Color(0xFFDDF3FF), Color(0xFFC7E8FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15304D).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 12,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF8FDFF), Color(0xFFCBEAFF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: FishlyTheme.skyDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New to Fishly?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create an account to keep your progress and Gubby customizations.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display name',
                  hintText: 'Choose a name for your profile',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a password',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.authBusy
                      ? null
                      : () async {
                          if (_displayNameController.text.trim().isEmpty) {
                            await _showMessage(
                              'Please choose a display name before creating your account.',
                            );
                            return;
                          }
                          if (_emailController.text.trim().isEmpty ||
                              _passwordController.text.isEmpty) {
                            await _showMessage(
                              'Please enter both an email and password.',
                            );
                            return;
                          }
                          await widget.onCreateAccount(
                            displayName: _displayNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: FishlyTheme.skyDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    widget.authBusy ? 'Working...' : 'Create Account',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.authBusy
                      ? null
                      : () async {
                          if (_emailController.text.trim().isEmpty ||
                              _passwordController.text.isEmpty) {
                            await _showMessage(
                              'Please enter both an email and password.',
                            );
                            return;
                          }
                          await widget.onSignIn(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: FishlyTheme.skyDeep,
                    side: BorderSide(
                      color: FishlyTheme.skyDeep.withValues(alpha: 0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMessage(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something went wrong'),
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

class _SignedInPanel extends StatelessWidget {
  const _SignedInPanel({required this.profile, required this.onSignOut});

  final FishlyUserProfile profile;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FEFF), Color(0xFFDDF3FF), Color(0xFFC7E8FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.displayName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(profile.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          MiniStatCard(
            label: 'Coins',
            value: '${profile.coins}',
            caption: 'current balance',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onSignOut(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: FishlyTheme.skyDeep,
                side: BorderSide(
                  color: FishlyTheme.skyDeep.withValues(alpha: 0.28),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.count,
    required this.opacity,
  });

  final int day;
  final int count;
  final double opacity;

  Color _tileColor() {
    switch (count) {
      case 0:
        return const Color(0xFFE7F3FB);
      case 1:
        return const Color(0xFFC8E8FA);
      case 2:
        return const Color(0xFF9FD8F6);
      case 3:
        return const Color(0xFF69BCEB);
      case 4:
        return const Color(0xFF2C95D3);
      default:
        return const Color(0xFF0D6391);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkTile = count >= 4;
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
        decoration: BoxDecoration(
          color: _tileColor(),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                color: darkTile ? Colors.white : const Color(0xFF12496B),
              ),
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                color: darkTile ? Colors.white : const Color(0xFF12496B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

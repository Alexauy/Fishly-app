import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/fishly_models.dart';
import '../theme/fishly_theme.dart';
import '../widgets/app_sections.dart';
import '../widgets/fish_avatar.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({
    super.key,
    required this.coins,
    required this.equippedAvatarAsset,
    required this.equippedTankAsset,
    required this.ownedRewardTitles,
    required this.onPurchase,
    required this.onEquip,
  });

  final int coins;
  final String equippedAvatarAsset;
  final String equippedTankAsset;
  final Set<String> ownedRewardTitles;
  final ValueChanged<ShopReward> onPurchase;
  final ValueChanged<ShopReward> onEquip;

  @override
  Widget build(BuildContext context) {
    final availableRewards = shopRewards
        .where((reward) => !ownedRewardTitles.contains(reward.title))
        .toList();
    final ownedRewards = shopRewards
        .where((reward) => ownedRewardTitles.contains(reward.title))
        .toList();
    final availableTanks = availableRewards
        .where((reward) => reward.category == ShopRewardCategory.tankDecoration)
        .toList();
    final availableAccessories = availableRewards
        .where((reward) => reward.category == ShopRewardCategory.accessory)
        .toList();
    final ownedTanks = ownedRewards
        .where((reward) => reward.category == ShopRewardCategory.tankDecoration)
        .toList();
    final ownedAccessories = ownedRewards
        .where((reward) => reward.category == ShopRewardCategory.accessory)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassSection(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PERSONALIZE',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: FishlyTheme.skyDeep,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reward shop',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            size: 18,
                            color: FishlyTheme.skyDeep,
                          ),
                          const SizedBox(width: 8),
                          Text('$coins'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            equippedTankAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 18,
                          bottom: 10,
                          child: FishAvatar(
                            size: 116,
                            assetPath: equippedAvatarAsset,
                          ),
                        ),
                      ],
                    ),
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
                  'Tank decorations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (availableTanks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    child: Text(
                      'All tank decorations are owned.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (var i = 0; i < availableTanks.length; i++) ...[
                  _ShopTile(
                    reward: availableTanks[i],
                    canPurchase: coins >= availableTanks[i].price,
                    onPurchase: () => onPurchase(availableTanks[i]),
                  ),
                  if (i != availableTanks.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accessories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (availableAccessories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    child: Text(
                      'All accessories are owned.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (var i = 0; i < availableAccessories.length; i++) ...[
                  _ShopTile(
                    reward: availableAccessories[i],
                    canPurchase: coins >= availableAccessories[i].price,
                    onPurchase: () => onPurchase(availableAccessories[i]),
                  ),
                  if (i != availableAccessories.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owned items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tank decorations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2387C9),
                  ),
                ),
                const SizedBox(height: 10),
                if (ownedTanks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    child: Text(
                      'No owned tank decorations yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (var i = 0; i < ownedTanks.length; i++) ...[
                  _OwnedTile(
                    reward: ownedTanks[i],
                    equipped: equippedTankAsset == ownedTanks[i].assetPath,
                    onEquip: () => onEquip(ownedTanks[i]),
                  ),
                  if (i != ownedTanks.length - 1) const SizedBox(height: 12),
                ],
                const SizedBox(height: 18),
                Text(
                  'Accessories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2387C9),
                  ),
                ),
                const SizedBox(height: 10),
                if (ownedAccessories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    child: Text(
                      'No owned accessories yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (var i = 0; i < ownedAccessories.length; i++) ...[
                  _OwnedTile(
                    reward: ownedAccessories[i],
                    equipped:
                        equippedAvatarAsset == ownedAccessories[i].assetPath,
                    onEquip: () => onEquip(ownedAccessories[i]),
                  ),
                  if (i != ownedAccessories.length - 1)
                    const SizedBox(height: 12),
                ],
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

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.reward,
    required this.canPurchase,
    required this.onPurchase,
  });

  final ShopReward reward;
  final bool canPurchase;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final previewWidth = reward.category == ShopRewardCategory.tankDecoration
        ? 96.0
        : 64.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              reward.assetPath,
              width: previewWidth,
              height: 64,
              fit: reward.category == ShopRewardCategory.tankDecoration
                  ? BoxFit.cover
                  : BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reward.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: FishlyTheme.sky.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${reward.price} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D6391),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonal(
                onPressed: canPurchase ? onPurchase : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE1F5FF),
                  foregroundColor: FishlyTheme.skyDeep,
                ),
                child: const Text('Buy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OwnedTile extends StatelessWidget {
  const _OwnedTile({
    required this.reward,
    required this.equipped,
    required this.onEquip,
  });

  final ShopReward reward;
  final bool equipped;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final previewWidth = reward.category == ShopRewardCategory.tankDecoration
        ? 96.0
        : 64.0;

    return InkWell(
      onTap: onEquip,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: equipped
              ? const Color(0xFFDFF3FF)
              : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: equipped
                ? FishlyTheme.skyDeep.withValues(alpha: 0.34)
                : Colors.white.withValues(alpha: 0.88),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                reward.assetPath,
                width: previewWidth,
                height: 64,
                fit: reward.category == ShopRewardCategory.tankDecoration
                    ? BoxFit.cover
                    : BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reward.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: equipped
                    ? const Color(0xFFBFE7FF)
                    : const Color(0xFFE1F5FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                equipped ? 'Unequip' : 'Equip',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D6391),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

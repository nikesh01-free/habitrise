import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/constants/app_assets.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/features/rewards/data/models/reward_model.dart';
import 'providers/rewards_providers.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(allRewardsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gold = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: isDark ? Colors.white : AppNeutral.n900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Trophy Room', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: rewardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: AppEmptyState(
            icon: AppIcons.error,
            title: 'Error',
            description: err.toString(),
          ),
        ),
        data: (rewards) {
          if (rewards.isEmpty) {
            return Center(
              child: AppEmptyState(
                assetPath: AppAssets.emptyRewards,
                icon: AppIcons.trophy,
                title: 'Start Earning',
                description:
                    'Complete habits and build streaks to unlock badges.',
                buttonLabel: 'Return',
                onPressed: () => Navigator.pop(context),
              ),
            ).animate().fadeIn();
          }

          final unlocked = rewards.where((r) => r.isUnlocked).length;
          final total = rewards.length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(unlocked, total, gold, isDark),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'ALL BADGES',
                    style: AppTextStyles.bodyS.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppNeutral.n500,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate((ctx, index) {
                    final r = rewards[index];
                    return _buildRewardCard(r, gold, isDark)
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .scale(begin: const Offset(0.9, 0.9));
                  }, childCount: rewards.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int unlocked, int total, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFD97706), const Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.trophy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trophy Room',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Your achievements',
                      style: AppTextStyles.bodyS.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerStat('$unlocked', 'Unlocked', Icons.emoji_events),
              Container(width: 1, height: 40, color: Colors.white24),
              _headerStat('$total', 'Total', Icons.collections_bookmark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _headerStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(RewardModel r, Color color, bool isDark) {
    final unlocked = r.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? color.withAlpha(60)
              : (isDark ? AppNeutral.n700 : AppNeutral.n200),
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: color.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: unlocked
                      ? color.withAlpha(20)
                      : (isDark ? AppNeutral.n700 : AppNeutral.n100),
                  shape: BoxShape.circle,
                  border: unlocked
                      ? Border.all(color: color.withAlpha(80), width: 2)
                      : null,
                ),
                child: Icon(
                  unlocked ? AppIcons.medal : AppIcons.lock,
                  color: unlocked ? color : AppNeutral.n400,
                  size: 28,
                ),
              )
              .animate(target: unlocked ? 1 : 0)
              .shimmer(
                duration: 2000.ms,
                delay: 1000.ms,
                color: Colors.white30,
              ),
          const SizedBox(height: 12),
          Text(
            r.title,
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? (isDark ? Colors.white : AppNeutral.n900)
                  : AppNeutral.n500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withAlpha(20)
                  : (isDark ? AppNeutral.n700 : AppNeutral.n100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.rewardType.toUpperCase(),
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 9,
                color: unlocked ? color : AppNeutral.n400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

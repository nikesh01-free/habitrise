import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/constants/app_assets.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/core/widgets/app_modal.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/core/utils/app_date_utils.dart';
import 'package:habitrise/features/water/presentation/providers/water_providers.dart';
import 'package:habitrise/features/water/data/models/water_log_model.dart';

class WaterHistoryScreen extends ConsumerWidget {
  const WaterHistoryScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AppModal(
        title: 'Delete Log',
        description: 'Remove this water entry from today?',
        isDangerPrimary: true,
        icon: AppIcons.delete,
        primaryLabel: 'Delete',
        secondaryLabel: 'Cancel',
        onPrimary: () async {
          Navigator.pop(ctx);
          try {
            await ref.read(waterControllerProvider).deleteLogEntry(id);
            if (context.mounted) {
              AppToast.show(context, 'Entry removed', type: AppToastType.success);
            }
          } catch (e) {
            if (context.mounted) {
              AppToast.show(context, 'Failed', type: AppToastType.error);
            }
          }
        },
        onSecondary: () => Navigator.pop(ctx),
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayWaterLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const waterBlue = Color(0xFF0EA5E9);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: isDark ? Colors.white : AppNeutral.n900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hydration', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: AppIcons.error,
            title: 'Error',
            description: e.toString(),
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: AppEmptyState(
                assetPath: AppAssets.emptyWater,
                icon: AppIcons.water,
                title: 'No Hydration Yet',
                description: 'Log your water intake to stay hydrated.',
                buttonLabel: 'Log 250 ml',
                onPressed: () => ref.read(waterControllerProvider).logWater(250),
              ),
            ).animate().fadeIn();
          }

          final sorted = [...logs]..sort((a, b) => b.entryTime.compareTo(a.entryTime));
          final total = sorted.fold<int>(0, (int sum, item) => sum + item.amountMl);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(total, sorted.length, waterBlue, isDark),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final e = sorted[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Slidable(
                        key: ValueKey(e.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          children: [
                            GestureDetector(
                              onTap: () => _confirmDelete(context, ref, e.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppSemantic.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(AppIcons.delete, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: _buildWaterCard(e, waterBlue, isDark),
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                  },
                  childCount: sorted.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int total, int count, Color color, bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0C4A6E), const Color(0xFF082F49)]
              : [color, color.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withAlpha(50), blurRadius: 16, offset: const Offset(0, 6)),
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
                child: const Icon(AppIcons.water, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration Log',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    Text(
                      'Your water intake history',
                      style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
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
              _headerStat('$total', 'ml Total', Icons.water_drop),
              Container(width: 1, height: 40, color: Colors.white24),
              _headerStat('$count', 'Entries', Icons.format_list_numbered),
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
          style: AppTextStyles.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWaterCard(WaterLogModel e, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.water, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.amountMl} ml',
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppNeutral.n900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppDateUtils.formatTime(e.entryTime),
                  style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'LOGGED',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
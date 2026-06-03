import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_radius.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/constants/app_assets.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/core/widgets/app_modal.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/core/widgets/app_input.dart';
import 'package:habitrise/core/widgets/app_button.dart';
import 'package:habitrise/core/widgets/app_loading_state.dart';
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

  void _showAddWaterSheet(BuildContext context) {
    AppModal.showSheet(
      context: context,
      child: const _HistoryAddWaterSheet(),
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
        loading: () => const AppLoadingState(),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: AppIcons.error,
            title: 'Failed to load water logs',
            description: e.toString(),
            buttonLabel: 'Retry',
            onPressed: () => ref.refresh(todayWaterLogsProvider),
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
      floatingActionButton: logsAsync.maybeWhen(
        data: (logs) => FloatingActionButton(
          onPressed: () => _showAddWaterSheet(context),
          backgroundColor: waterBlue,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
        orElse: () => null,
      ),
    );
  }

  Widget _buildHeader(int total, int count, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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

class _HistoryAddWaterSheet extends ConsumerStatefulWidget {
  const _HistoryAddWaterSheet();

  @override
  ConsumerState<_HistoryAddWaterSheet> createState() => _HistoryAddWaterSheetState();
}

class _HistoryAddWaterSheetState extends ConsumerState<_HistoryAddWaterSheet> {
  late final TextEditingController _customCtrl;

  @override
  void initState() {
    super.initState();
    _customCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add Water Intake', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _waterPreset(150, 'Glass'),
              _waterPreset(250, 'Normal'),
              _waterPreset(500, 'Bottle'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppInput(
                  label: 'Custom Amount',
                  hint: 'Amount in ml',
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: 'Add',
                size: AppButtonSize.md,
                onPressed: () async {
                  final text = _customCtrl.text.trim();
                  if (text.isNotEmpty) {
                    final amount = int.tryParse(text);
                    if (amount != null && amount > 0) {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      try {
                        await ref.read(waterControllerProvider).logWater(amount);
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            'Added ${amount}ml water!',
                            type: AppToastType.success,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            e.toString().replaceAll('Exception: ', ''),
                            type: AppToastType.error,
                          );
                        }
                      }
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _waterPreset(int amount, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        Navigator.pop(context); // close amount picker
        try {
          await ref.read(waterControllerProvider).logWater(amount);
          if (context.mounted) {
            AppToast.show(
              context,
              'Added ${amount}ml water!',
              type: AppToastType.success,
            );
          }
        } catch (e) {
          if (context.mounted) {
            AppToast.show(
              context,
              e.toString().replaceAll('Exception: ', ''),
              type: AppToastType.error,
            );
          }
        }
      },
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppNeutral.n800 : AppNeutral.n50,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: isDark ? AppNeutral.n700 : AppNeutral.n200),
        ),
        child: Column(
          children: [
            const Icon(
              AppIcons.water,
              color: AppFeatureColors.waterIcon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '${amount}ml',
              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: AppTextStyles.bodyS),
          ],
        ),
      ),
    );
  }
}
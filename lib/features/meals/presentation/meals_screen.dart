import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:habitrise/core/theme/app_colors.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_icons.dart';
import 'package:habitrise/core/constants/app_assets.dart';
import 'package:habitrise/core/widgets/app_toast.dart';
import 'package:habitrise/core/widgets/app_modal.dart';
import 'package:habitrise/core/widgets/app_empty_state.dart';
import 'package:habitrise/features/meals/presentation/providers/meal_providers.dart';
import 'package:habitrise/features/meals/data/models/meal_log_model.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  void _openMealDialog(BuildContext context, WidgetRef ref, [MealLogModel? meal]) {
    AppModal.showSheet(context: context, child: _MealEditorSheet(meal: meal, ref: ref));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AppModal(
        title: 'Delete Entry',
        description: 'Remove this meal from your log?',
        isDangerPrimary: true,
        icon: AppIcons.delete,
        primaryLabel: 'Delete',
        secondaryLabel: 'Cancel',
        onPrimary: () async {
          Navigator.pop(ctx);
          await ref.read(todayMealsProvider.notifier).deleteMeal(id);
          if (context.mounted) {
            AppToast.show(context, 'Entry removed', type: AppToastType.success);
          }
        },
        onSecondary: () => Navigator.pop(ctx),
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todayMealsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const mealGreen = Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: isDark ? AppNeutral.n900 : AppNeutral.n50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: isDark ? Colors.white : AppNeutral.n900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Meals', style: AppTextStyles.h4.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
        centerTitle: true,
      ),
      body: meals.isEmpty
          ? Center(
              child: AppEmptyState(
                assetPath: AppAssets.emptyMeals,
                icon: AppIcons.meals,
                title: 'No Meals Logged',
                description: 'Track your nutrition by logging meals.',
                buttonLabel: 'Log Meal',
                onPressed: () => _openMealDialog(context, ref),
              ),
            ).animate().fadeIn()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(meals.length, mealGreen, isDark),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final m = meals[index];
                      final statusColor = m.status == 'skipped'
                          ? AppSemantic.error
                          : m.status == 'delayed'
                              ? Colors.amber[700]!
                              : mealGreen;
                      final statusIcon = m.status == 'skipped'
                          ? AppIcons.cancel
                          : m.status == 'delayed'
                              ? AppIcons.clock
                              : AppIcons.success;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Slidable(
                          key: ValueKey(m.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.2,
                            children: [
                              GestureDetector(
                                onTap: () => _confirmDelete(context, ref, m.id),
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
                          child: _buildMealCard(m, statusColor, statusIcon, isDark),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                    },
                    childCount: meals.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: meals.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(bottom: 20 + MediaQuery.of(context).padding.bottom),
              child: FloatingActionButton.extended(
                onPressed: () => _openMealDialog(context, ref),
                backgroundColor: AppColors.primary600,
                icon: const Icon(AppIcons.add, color: Colors.white),
                label: Text(
                  'Log Meal',
                  style: AppTextStyles.bodyM.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(int count, Color color, bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [const Color(0xFF14532D), const Color(0xFF052E16)] : [color, color.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withAlpha(50), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
            child: const Icon(AppIcons.meals, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nutrition Tracker', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                Text('$count meal${count != 1 ? 's' : ''} logged today', style: AppTextStyles.bodyS.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildMealCard(MealLogModel m, Color statusColor, IconData statusIcon, bool isDark) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withAlpha(20), shape: BoxShape.circle),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.mealName, style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppNeutral.n900)),
                const SizedBox(height: 4),
                Text(m.mealType.toUpperCase(), style: AppTextStyles.bodyS.copyWith(color: AppNeutral.n500, fontWeight: FontWeight.w600, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.edit, color: AppNeutral.n400, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _MealEditorSheet extends StatefulWidget {
  final MealLogModel? meal;
  final WidgetRef ref;
  const _MealEditorSheet({this.meal, required this.ref});

  @override
  State<_MealEditorSheet> createState() => _MealEditorSheetState();
}

class _MealEditorSheetState extends State<_MealEditorSheet> {
  late final TextEditingController _nameCtrl;
  late String _selectedType;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.meal?.mealName ?? '');
    _selectedType = widget.meal?.mealType ?? 'breakfast';
    _selectedStatus = widget.meal?.status ?? 'completed';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trimmed = _nameCtrl.text.trim();
    if (trimmed.isEmpty) {
      AppToast.show(context, 'Enter meal name', type: AppToastType.warning);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (widget.meal == null) {
        await widget.ref.read(todayMealsProvider.notifier).logMeal(name: trimmed, type: _selectedType, status: _selectedStatus);
      } else {
        await widget.ref.read(todayMealsProvider.notifier).updateMealDetails(id: widget.meal!.id, name: trimmed, type: _selectedType, status: _selectedStatus);
      }
      if (mounted) {
        Navigator.pop(context);
        AppToast.show(context, 'Saved', type: AppToastType.success);
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Failed', type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppNeutral.n800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppNeutral.n300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(widget.meal == null ? 'Log Meal' : 'Edit Meal', style: AppTextStyles.h3.copyWith(color: isDark ? Colors.white : AppNeutral.n900)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: AppTextStyles.bodyM.copyWith(color: isDark ? Colors.white : AppNeutral.n900),
              decoration: InputDecoration(
                labelText: 'Meal Name',
                hintText: 'e.g. Breakfast',
                filled: true,
                fillColor: isDark ? AppNeutral.n700 : AppNeutral.n50,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(35)],
            ),
            const SizedBox(height: 20),
            Text('Type', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w700, color: AppNeutral.n500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['breakfast', 'lunch', 'dinner', 'snack'].map((t) {
                final sel = _selectedType == t;
                return ChoiceChip(
                  label: Text(t.toUpperCase()),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedType = t),
                  selectedColor: AppColors.primary500,
                  labelStyle: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w700, color: sel ? Colors.white : AppNeutral.n500),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Status', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w700, color: AppNeutral.n500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['completed', 'skipped', 'delayed'].map((s) {
                final sel = _selectedStatus == s;
                final color = s == 'skipped' ? AppSemantic.error : s == 'delayed' ? Colors.amber[700]! : AppSemantic.success;
                return ChoiceChip(
                  label: Text(s.toUpperCase()),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedStatus = s),
                  selectedColor: color,
                  labelStyle: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w700, color: sel ? Colors.white : AppNeutral.n500),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.meal == null ? 'Log Meal' : 'Save', style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
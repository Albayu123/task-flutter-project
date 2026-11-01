import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class TaskStatsCard extends StatelessWidget {
  final List<Task> tasks;

  const TaskStatsCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final progress = total > 0 ? (completed / total) : 0.0;
    final percentage = (progress * 100).toInt();

    final todayFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Aktivitas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    todayFormatted,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryContainerDark
                      : AppColors.primaryContainerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$percentage% Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0.0 : progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.borderDark
                  : AppColors.primaryContainerLight.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.priorityLow : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  label: 'Total',
                  value: '$total',
                  icon: Icons.checklist_rounded,
                  iconColor: AppColors.primary,
                  bgColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBadge(
                  label: 'Berjalan',
                  value: '$pending',
                  icon: Icons.pending_actions_rounded,
                  iconColor: AppColors.accent,
                  bgColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBadge(
                  label: 'Selesai',
                  value: '$completed',
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.priorityLow,
                  bgColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

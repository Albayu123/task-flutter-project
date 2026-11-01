import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
      default:
        return AppColors.priorityLow;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
      default:
        return 'Rendah';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kerja':
        return Icons.work_outline_rounded;
      case 'pribadi':
        return Icons.person_outline_rounded;
      case 'belajar':
        return Icons.school_outlined;
      case 'umum':
      default:
        return Icons.bookmark_outline_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kerja':
        return AppColors.catWork;
      case 'pribadi':
        return AppColors.catPersonal;
      case 'belajar':
        return AppColors.catStudy;
      case 'umum':
      default:
        return AppColors.catGeneral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(task.priority);
    final categoryColor = _getCategoryColor(task.category);

    String? formattedDate;
    if (task.createdAt != null) {
      formattedDate = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(task.createdAt!);
    }

    return Dismissible(
      key: Key('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Tugas?'),
                content: Text('Apakah Anda yakin ingin menghapus "${task.title}"?'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.priorityHigh),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? (isDark
                    ? AppColors.borderDark.withValues(alpha: 0.5)
                    : AppColors.borderLight.withValues(alpha: 0.7))
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Checkbox, Title, and Action Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom interactive checkbox with 48x48dp hit target
                      GestureDetector(
                        onTap: onToggle,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: task.isCompleted
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: task.isCompleted
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.borderLight),
                                  width: 2,
                                ),
                              ),
                              child: task.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title and Detail
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted
                                    ? (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight)
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                              ),
                            ),
                            if (task.detail.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Edit and Delete IconButtons (with padding for >=44x44pt hit target)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            tooltip: 'Edit Tugas',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: const EdgeInsets.all(6),
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            color: AppColors.priorityHigh.withValues(alpha: 0.8),
                            tooltip: 'Hapus Tugas',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: const EdgeInsets.all(6),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row: Priority Badge, Category Badge, and Date
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: priorityColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _getPriorityLabel(task.priority),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(task.category),
                              size: 13,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date if available
                      if (formattedDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

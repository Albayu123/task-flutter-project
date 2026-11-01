import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';

class TaskDetailSheet extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String? formattedDate;
    if (task.createdAt != null) {
      formattedDate = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID').format(task.createdAt!);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Status and Category row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.priorityLow.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      task.isCompleted ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: task.isCompleted ? AppColors.priorityLow : AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.isCompleted ? 'Selesai' : 'Sedang Berjalan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted ? AppColors.priorityLow : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            task.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 12),
          // Metadata badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.bookmark_outline_rounded, size: 16),
                label: Text(task.category),
                backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
              Chip(
                avatar: const Icon(Icons.flag_outlined, size: 16),
                label: Text('Prioritas: ${task.priority.toUpperCase()}'),
                backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (formattedDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Description section
          Text(
            'Deskripsi Tugas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            task.detail.isEmpty ? '(Tidak ada deskripsi tambahan)' : task.detail,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              color: task.detail.isEmpty
                  ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onToggle();
                  },
                  icon: Icon(
                    task.isCompleted ? Icons.restart_alt_rounded : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    task.isCompleted ? 'Batal Selesai' : 'Tandai Selesai',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task;

  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailController;

  late String _selectedPriority;
  late String _selectedCategory;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Rendah', 'color': AppColors.priorityLow},
    {'value': 'medium', 'label': 'Sedang', 'color': AppColors.priorityMedium},
    {'value': 'high', 'label': 'Tinggi', 'color': AppColors.priorityHigh},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Umum', 'icon': Icons.bookmark_outline_rounded},
    {'name': 'Kerja', 'icon': Icons.work_outline_rounded},
    {'name': 'Pribadi', 'icon': Icons.person_outline_rounded},
    {'name': 'Belajar', 'icon': Icons.school_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _detailController = TextEditingController(text: widget.task?.detail ?? '');
    _selectedPriority = widget.task?.priority ?? 'medium';
    _selectedCategory = widget.task?.category ?? 'Umum';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final detail = _detailController.text.trim();
    final viewModel = context.read<TaskViewModel>();

    try {
      if (widget.task == null) {
        await viewModel.addTask(
          title: title,
          detail: detail,
          priority: _selectedPriority,
          category: _selectedCategory,
        );
      } else {
        await viewModel.updateTask(
          id: widget.task!.id,
          title: title,
          detail: detail,
          priority: _selectedPriority,
          category: _selectedCategory,
          isCompleted: widget.task!.isCompleted,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task == null
                  ? 'Tugas berhasil ditambahkan'
                  : 'Tugas berhasil diperbarui',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan tugas: $e'),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.task != null;

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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator handle
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
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryContainerDark
                              : AppColors.primaryContainerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.add_task_rounded,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Tugas' : 'Tugas Baru',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title Field
              Text(
                'Judul Tugas *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Misal: Selesaikan laporan mingguan...',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Detail Field
              Text(
                'Deskripsi / Catatan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _detailController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan detail atau instruksi tugas...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Priority Selection
              Text(
                'Tingkat Prioritas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _priorities.map((p) {
                  final isSelected = _selectedPriority == p['value'];
                  final Color pColor = p['color'] as Color;

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: pColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(p['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPriority = p['value'] as String);
                      }
                    },
                    selectedColor: pColor.withValues(alpha: 0.15),
                    backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                    side: BorderSide(
                      color: isSelected
                          ? pColor
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Category Selection
              Text(
                'Kategori',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c['name'];
                  final IconData icon = c['icon'] as IconData;

                  return ChoiceChip(
                    avatar: Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    label: Text(c['name'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = c['name'] as String);
                      }
                    },
                    selectedColor: isDark
                        ? AppColors.primaryContainerDark
                        : AppColors.primaryContainerLight,
                    backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isSelected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditing ? Icons.check_circle_outline : Icons.add_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Perbarui Tugas' : 'Simpan Tugas',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

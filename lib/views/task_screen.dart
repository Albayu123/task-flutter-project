import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/task_viewmodel.dart';
import 'widgets/empty_state.dart';
import 'widgets/task_card.dart';
import 'widgets/task_detail_sheet.dart';
import 'widgets/task_form_sheet.dart';
import 'widgets/task_stats_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFormSheet(BuildContext context, [Task? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  void _showDetailSheet(BuildContext context, Task task, TaskViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(
        task: task,
        onToggle: () => viewModel.toggleTaskCompletion(task),
        onEdit: () => _showFormSheet(context, task),
        onDelete: () => _handleDelete(context, task, viewModel),
      ),
    );
  }

  void _handleDelete(BuildContext context, Task task, TaskViewModel viewModel) {
    viewModel.deleteTask(task);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tugas "${task.title}" dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: AppColors.accentLight,
          onPressed: () {
            viewModel.undoDelete();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TaskViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
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
                Icons.check_box_rounded,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskFlow',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Kelola tugas & produktivitasmu',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Toggle Theme Action Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 22,
            ),
            tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
            onPressed: () => viewModel.toggleThemeMode(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: viewModel.tasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.priorityHigh),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi kesalahan saat memuat data',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${snapshot.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final allTasks = snapshot.data ?? [];
          final filteredTasks = viewModel.filterTasks(allTasks);
          final hasFiltersApplied = viewModel.searchQuery.isNotEmpty ||
              viewModel.statusFilter != 'all' ||
              viewModel.categoryFilter != 'all';

          return CustomScrollView(
            slivers: [
              // Summary Stats Card
              SliverToBoxAdapter(
                child: TaskStatsCard(tasks: allTasks),
              ),

              // Search and Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => viewModel.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Cari tugas...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.setSearchQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter Chips Row (All, Pending, Completed)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusFilterChip(
                              label: 'Semua (${allTasks.length})',
                              statusKey: 'all',
                              currentStatus: viewModel.statusFilter,
                              onSelected: () => viewModel.setStatusFilter('all'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip(
                              label:
                                  'Berjalan (${allTasks.where((t) => !t.isCompleted).length})',
                              statusKey: 'pending',
                              currentStatus: viewModel.statusFilter,
                              onSelected: () => viewModel.setStatusFilter('pending'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip(
                              label:
                                  'Selesai (${allTasks.where((t) => t.isCompleted).length})',
                              statusKey: 'completed',
                              currentStatus: viewModel.statusFilter,
                              onSelected: () => viewModel.setStatusFilter('completed'),
                              isDark: isDark,
                            ),
                            if (hasFiltersApplied) ...[
                              const SizedBox(width: 8),
                              ActionChip(
                                avatar: const Icon(Icons.filter_alt_off_rounded, size: 16),
                                label: const Text('Reset'),
                                onPressed: () {
                                  _searchController.clear();
                                  viewModel.resetFilters();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // Task List or Empty State
              if (allTasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    isFiltered: false,
                    onAction: () => _showFormSheet(context),
                  ),
                )
              else if (filteredTasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    isFiltered: true,
                    onAction: () {
                      _searchController.clear();
                      viewModel.resetFilters();
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () => viewModel.toggleTaskCompletion(task),
                          onEdit: () => _showFormSheet(context, task),
                          onDelete: () => _handleDelete(context, task, viewModel),
                          onTap: () => _showDetailSheet(context, task, viewModel),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormSheet(context),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Tugas Baru',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required String statusKey,
    required String currentStatus,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    final isSelected = currentStatus == statusKey;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      selectedColor: isDark
          ? AppColors.primaryContainerDark
          : AppColors.primaryContainerLight,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onAction;

  const EmptyStateWidget({
    super.key,
    required this.isFiltered,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isFiltered
                    ? (isDark
                        ? AppColors.borderDark.withValues(alpha: 0.5)
                        : AppColors.borderLight.withValues(alpha: 0.5))
                    : (isDark
                        ? AppColors.primaryContainerDark.withValues(alpha: 0.4)
                        : AppColors.primaryContainerLight),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.task_alt_rounded,
                size: 48,
                color: isFiltered
                    ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                    : (isDark ? AppColors.primaryLight : AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'Tugas Tidak Ditemukan' : 'Belum Ada Tugas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Coba ganti kata kunci pencarian atau ubah filter status yang dipilih.'
                  : 'Rencanakan harimu dengan rapi. Tambahkan tugas pertama untuk memulai!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                isFiltered ? Icons.refresh_rounded : Icons.add_rounded,
                size: 20,
              ),
              label: Text(
                isFiltered ? 'Reset Filter' : 'Tambah Tugas Baru',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

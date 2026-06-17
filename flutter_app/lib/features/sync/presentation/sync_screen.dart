import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/presentation/transactions_provider.dart';
import '../../../core/constants/app_colors.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sinkronisasi Gmail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'BudgetMate akan membaca email notifikasi dari BCA, Mandiri, GoPay, OVO, dan lainnya untuk mengambil data transaksi.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Supported providers
            const Text(
              'Provider yang didukung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'BCA', 'Mandiri', 'BNI', 'BRI',
                'GoPay', 'OVO', 'DANA', 'ShopeePay',
                'Tokopedia', 'PayPal',
              ].asMap().entries.map(
                (e) => Chip(
                  label: Text(e.value),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: (e.key * 50).ms),
              ).toList(),
            ),

            const Spacer(),

            // Sync button
            syncState.when(
              data: (_) => FilledButton.icon(
                onPressed: () =>
                    ref.read(syncNotifierProvider.notifier).syncFromGmail(),
                icon: const Icon(Icons.sync),
                label: const Text('Sync Sekarang'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              loading: () => FilledButton.icon(
                onPressed: null,
                icon: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                label: const Text('Menyinkronkan...'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              error: (e, _) => Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sync gagal: $e',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(syncNotifierProvider.notifier).syncFromGmail(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Sinkronisasi otomatis berjalan setiap 15 menit',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

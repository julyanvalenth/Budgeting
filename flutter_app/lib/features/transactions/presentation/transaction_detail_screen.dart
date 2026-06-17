import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'transactions_provider.dart';
import '../../../core/constants/app_colors.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: const BackButton(),
      ),
      body: transactionAsync.when(
        data: (transaction) {
          final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
          final currencyFormatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          final isDebit = transaction.type.name == 'debit';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Amount card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDebit
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isDebit ? Icons.trending_down : Icons.trending_up,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(transaction.amount),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Detail info card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Tanggal',
                        value: formatter.format(transaction.transactionDate),
                      ),
                      _DetailRow(
                        label: 'Merchant',
                        value: transaction.merchant ?? '-',
                      ),
                      _DetailRow(
                        label: 'Sumber',
                        value: transaction.source,
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sourceColor(transaction.source)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.source,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.sourceColor(transaction.source),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (transaction.referenceNumber != null)
                        _DetailRow(
                          label: 'No. Referensi',
                          value: transaction.referenceNumber!,
                        ),
                      if (transaction.balance != null)
                        _DetailRow(
                          label: 'Saldo',
                          value: currencyFormatter.format(transaction.balance),
                        ),
                      _DetailRow(
                        label: 'Kategori',
                        value: transaction.category?.name ?? 'Belum dikategorikan',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          valueWidget ??
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
        ],
      ),
    );
  }
}

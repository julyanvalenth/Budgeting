import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/transaction_model.dart';
import 'transactions_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/transaction_card.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () =>
                ref.read(syncNotifierProvider.notifier).syncFromGmail(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransaction(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return TransactionCard(
                transaction: t,
                onTap: () => context.go('/transactions/${t.id}'),
              )
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                  .slideX(begin: 0.05, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FilterSheet(ref: ref),
    );
  }

  void _showAddTransaction(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add transaction form — coming soon')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sync Gmail untuk mengambil transaksi\ndari email bank & e-wallet kamu',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final WidgetRef ref;
  const _FilterSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: ref.watch(transactionFilterProvider).type == null,
                onSelected: (_) => ref
                    .read(transactionFilterProvider.notifier)
                    .state = const TransactionFilter(),
              ),
              FilterChip(
                label: const Text('Pengeluaran'),
                selected: ref.watch(transactionFilterProvider).type ==
                    TransactionType.debit,
                onSelected: (_) => ref
                    .read(transactionFilterProvider.notifier)
                    .state = const TransactionFilter(type: TransactionType.debit),
              ),
              FilterChip(
                label: const Text('Pemasukan'),
                selected: ref.watch(transactionFilterProvider).type ==
                    TransactionType.credit,
                onSelected: (_) => ref
                    .read(transactionFilterProvider.notifier)
                    .state =
                    const TransactionFilter(type: TransactionType.credit),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}

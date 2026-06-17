import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/presentation/transactions_provider.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_model.dart';

final dashboardMonthProvider = StateProvider<DateTime>((_) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final currentMonthSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final monthStart = ref.watch(dashboardMonthProvider);
  final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);
  return ref.watch(dashboardSummaryProvider((monthStart, monthEnd)).future);
});

/// Daily spending for the past 7 days (index 0 = 6 days ago, index 6 = today)
final weeklySpendProvider =
    FutureProvider.autoDispose<List<double>>((ref) async {
  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 6));
  final repo = ref.watch(transactionRepositoryProvider);

  final transactions = await repo.getTransactions(
    startDate: weekStart,
    endDate: now,
    limit: 100, // backend caps at 100 per Zod schema
  );

  final Map<int, double> daily = {};
  for (final t in transactions) {
    if (t.type == TransactionType.debit) {
      final d = t.transactionDate.difference(weekStart).inDays.clamp(0, 6);
      daily[d] = (daily[d] ?? 0) + t.amount;
    }
  }

  return List.generate(7, (i) => daily[i] ?? 0);
});

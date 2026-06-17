import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

// Filter state
class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final TransactionType? type;

  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
  }) {
    return TransactionFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
    );
  }
}

final transactionFilterProvider =
    StateProvider<TransactionFilter>((_) => const TransactionFilter());

// Transactions list provider
final transactionsListProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final filter = ref.watch(transactionFilterProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions(
    startDate: filter.startDate,
    endDate: filter.endDate,
    categoryId: filter.categoryId,
    type: filter.type,
  );
});

// Dashboard summary provider
final dashboardSummaryProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, (DateTime, DateTime)>(
  (ref, dates) async {
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.getSummary(startDate: dates.$1, endDate: dates.$2);
  },
);

// Transaction detail provider
final transactionDetailProvider =
    FutureProvider.autoDispose.family<Transaction, String>((ref, id) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getById(id);
});

// Sync notifier
class SyncNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> syncFromGmail() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.triggerGmailSync();
      state = const AsyncData(null);
      // Refresh transactions
      ref.invalidate(transactionsListProvider);
      ref.invalidate(dashboardSummaryProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final syncNotifierProvider =
    AsyncNotifierProvider<SyncNotifier, void>(SyncNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_api.dart';
import '../domain/transaction_model.dart';

class TransactionRepository {
  final TransactionApi _api;
  TransactionRepository(this._api);

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getTransactions(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
      page: page,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _api.getSummary(startDate: startDate, endDate: endDate);
  }

  Future<void> triggerGmailSync() => _api.triggerGmailSync();

  Future<Transaction> getById(String id) => _api.getById(id);

  Future<Transaction> create(Map<String, dynamic> data) => _api.create(data);

  Future<Transaction> update(String id, Map<String, dynamic> data) =>
      _api.update(id, data);

  Future<void> delete(String id) => _api.delete(id);
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(transactionApiProvider)),
);

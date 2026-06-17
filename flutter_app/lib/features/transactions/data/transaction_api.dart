import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/transaction_model.dart';

class TransactionApi {
  final Dio _dio;
  TransactionApi(this._dio);

  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.transactions,
      queryParameters: {
        // Must use UTC (Z suffix) — Zod .datetime() rejects local-time strings
        if (startDate != null) 'startDate': startDate.toUtc().toIso8601String(),
        if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        if (categoryId != null) 'categoryId': categoryId,
        if (type != null) 'type': type.name.toUpperCase(),
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data['data'] as List;
    return data
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.transactionsSummary,
      queryParameters: {
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> triggerGmailSync() async {
    await _dio.post(ApiConstants.gmailSync);
  }

  Future<Transaction> getById(String id) async {
    final response = await _dio.get('${ApiConstants.transactions}/$id');
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Transaction> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.transactions, data: data);
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Transaction> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '${ApiConstants.transactions}/$id',
      data: data,
    );
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('${ApiConstants.transactions}/$id');
  }
}

final transactionApiProvider = Provider<TransactionApi>(
  (ref) => TransactionApi(ref.watch(dioProvider)),
);

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

// Prisma Decimal serializes to JSON as a String; handle both types.
double _amountFromJson(dynamic v) =>
    v is String ? double.parse(v) : (v as num).toDouble();
double? _nullableAmountFromJson(dynamic v) =>
    v == null ? null : _amountFromJson(v);

enum TransactionType {
  @JsonValue('DEBIT')
  debit,
  @JsonValue('CREDIT')
  credit,
}

@freezed
class TransactionCategory with _$TransactionCategory {
  const factory TransactionCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) = _TransactionCategory;

  factory TransactionCategory.fromJson(Map<String, dynamic> json) =>
      _$TransactionCategoryFromJson(json);
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(fromJson: _amountFromJson) required double amount,
    required String currency,
    required TransactionType type,
    required String description,
    String? merchant,
    String? categoryId,
    TransactionCategory? category,
    required String source,
    required DateTime transactionDate,
    String? referenceNumber,
    @JsonKey(fromJson: _nullableAmountFromJson) double? balance,
    required bool isManual,
    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionCategoryImpl _$$TransactionCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$$TransactionCategoryImplToJson(
        _$TransactionCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      amount: _amountFromJson(json['amount']),
      currency: json['currency'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      description: json['description'] as String,
      merchant: json['merchant'] as String?,
      categoryId: json['categoryId'] as String?,
      category: json['category'] == null
          ? null
          : TransactionCategory.fromJson(
              json['category'] as Map<String, dynamic>),
      source: json['source'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      balance: _nullableAmountFromJson(json['balance']),
      isManual: json['isManual'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'currency': instance.currency,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'merchant': instance.merchant,
      'categoryId': instance.categoryId,
      'category': instance.category,
      'source': instance.source,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'referenceNumber': instance.referenceNumber,
      'balance': instance.balance,
      'isManual': instance.isManual,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.debit: 'DEBIT',
  TransactionType.credit: 'CREDIT',
};

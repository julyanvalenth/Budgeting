// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionCategory _$TransactionCategoryFromJson(Map<String, dynamic> json) {
  return _TransactionCategory.fromJson(json);
}

/// @nodoc
mixin _$TransactionCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;

  /// Serializes this TransactionCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCategoryCopyWith<TransactionCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCategoryCopyWith<$Res> {
  factory $TransactionCategoryCopyWith(
          TransactionCategory value, $Res Function(TransactionCategory) then) =
      _$TransactionCategoryCopyWithImpl<$Res, TransactionCategory>;
  @useResult
  $Res call({String id, String name, String icon, String color});
}

/// @nodoc
class _$TransactionCategoryCopyWithImpl<$Res, $Val extends TransactionCategory>
    implements $TransactionCategoryCopyWith<$Res> {
  _$TransactionCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionCategoryImplCopyWith<$Res>
    implements $TransactionCategoryCopyWith<$Res> {
  factory _$$TransactionCategoryImplCopyWith(_$TransactionCategoryImpl value,
          $Res Function(_$TransactionCategoryImpl) then) =
      __$$TransactionCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String icon, String color});
}

/// @nodoc
class __$$TransactionCategoryImplCopyWithImpl<$Res>
    extends _$TransactionCategoryCopyWithImpl<$Res, _$TransactionCategoryImpl>
    implements _$$TransactionCategoryImplCopyWith<$Res> {
  __$$TransactionCategoryImplCopyWithImpl(_$TransactionCategoryImpl _value,
      $Res Function(_$TransactionCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_$TransactionCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionCategoryImpl implements _TransactionCategory {
  const _$TransactionCategoryImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color});

  factory _$TransactionCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  @override
  final String color;

  @override
  String toString() {
    return 'TransactionCategory(id: $id, name: $name, icon: $icon, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, color);

  /// Create a copy of TransactionCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionCategoryImplCopyWith<_$TransactionCategoryImpl> get copyWith =>
      __$$TransactionCategoryImplCopyWithImpl<_$TransactionCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionCategoryImplToJson(
      this,
    );
  }
}

abstract class _TransactionCategory implements TransactionCategory {
  const factory _TransactionCategory(
      {required final String id,
      required final String name,
      required final String icon,
      required final String color}) = _$TransactionCategoryImpl;

  factory _TransactionCategory.fromJson(Map<String, dynamic> json) =
      _$TransactionCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  String get color;

  /// Create a copy of TransactionCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionCategoryImplCopyWith<_$TransactionCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get merchant => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  TransactionCategory? get category => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  DateTime get transactionDate => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableAmountFromJson)
  double? get balance => throw _privateConstructorUsedError;
  bool get isManual => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: _amountFromJson) double amount,
      String currency,
      TransactionType type,
      String description,
      String? merchant,
      String? categoryId,
      TransactionCategory? category,
      String source,
      DateTime transactionDate,
      String? referenceNumber,
      @JsonKey(fromJson: _nullableAmountFromJson) double? balance,
      bool isManual,
      DateTime createdAt});

  $TransactionCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? currency = null,
    Object? type = null,
    Object? description = null,
    Object? merchant = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? source = null,
    Object? transactionDate = null,
    Object? referenceNumber = freezed,
    Object? balance = freezed,
    Object? isManual = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      merchant: freezed == merchant
          ? _value.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TransactionCategory?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      isManual: null == isManual
          ? _value.isManual
          : isManual // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransactionCategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $TransactionCategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(fromJson: _amountFromJson) double amount,
      String currency,
      TransactionType type,
      String description,
      String? merchant,
      String? categoryId,
      TransactionCategory? category,
      String source,
      DateTime transactionDate,
      String? referenceNumber,
      @JsonKey(fromJson: _nullableAmountFromJson) double? balance,
      bool isManual,
      DateTime createdAt});

  @override
  $TransactionCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? currency = null,
    Object? type = null,
    Object? description = null,
    Object? merchant = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? source = null,
    Object? transactionDate = null,
    Object? referenceNumber = freezed,
    Object? balance = freezed,
    Object? isManual = null,
    Object? createdAt = null,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      merchant: freezed == merchant
          ? _value.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TransactionCategory?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      isManual: null == isManual
          ? _value.isManual
          : isManual // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      @JsonKey(fromJson: _amountFromJson) required this.amount,
      required this.currency,
      required this.type,
      required this.description,
      this.merchant,
      this.categoryId,
      this.category,
      required this.source,
      required this.transactionDate,
      this.referenceNumber,
      @JsonKey(fromJson: _nullableAmountFromJson) this.balance,
      required this.isManual,
      required this.createdAt});

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final double amount;
  @override
  final String currency;
  @override
  final TransactionType type;
  @override
  final String description;
  @override
  final String? merchant;
  @override
  final String? categoryId;
  @override
  final TransactionCategory? category;
  @override
  final String source;
  @override
  final DateTime transactionDate;
  @override
  final String? referenceNumber;
  @override
  @JsonKey(fromJson: _nullableAmountFromJson)
  final double? balance;
  @override
  final bool isManual;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, currency: $currency, type: $type, description: $description, merchant: $merchant, categoryId: $categoryId, category: $category, source: $source, transactionDate: $transactionDate, referenceNumber: $referenceNumber, balance: $balance, isManual: $isManual, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.isManual, isManual) ||
                other.isManual == isManual) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      currency,
      type,
      description,
      merchant,
      categoryId,
      category,
      source,
      transactionDate,
      referenceNumber,
      balance,
      isManual,
      createdAt);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      @JsonKey(fromJson: _amountFromJson) required final double amount,
      required final String currency,
      required final TransactionType type,
      required final String description,
      final String? merchant,
      final String? categoryId,
      final TransactionCategory? category,
      required final String source,
      required final DateTime transactionDate,
      final String? referenceNumber,
      @JsonKey(fromJson: _nullableAmountFromJson) final double? balance,
      required final bool isManual,
      required final DateTime createdAt}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: _amountFromJson)
  double get amount;
  @override
  String get currency;
  @override
  TransactionType get type;
  @override
  String get description;
  @override
  String? get merchant;
  @override
  String? get categoryId;
  @override
  TransactionCategory? get category;
  @override
  String get source;
  @override
  DateTime get transactionDate;
  @override
  String? get referenceNumber;
  @override
  @JsonKey(fromJson: _nullableAmountFromJson)
  double? get balance;
  @override
  bool get isManual;
  @override
  DateTime get createdAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

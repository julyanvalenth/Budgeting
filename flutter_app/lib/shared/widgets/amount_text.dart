import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/transactions/domain/transaction_model.dart';
import '../../core/constants/app_colors.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showSign;

  const AmountText({
    super.key,
    required this.amount,
    required this.type,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = type == TransactionType.debit;
    final color = isDebit ? AppColors.expense : AppColors.income;
    final sign = showSign ? (isDebit ? '- ' : '+ ') : '';

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Text(
      '$sign${formatter.format(amount)}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

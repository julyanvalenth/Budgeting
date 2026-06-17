import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/transactions/domain/transaction_model.dart';
import '../../core/constants/app_colors.dart';
import 'amount_text.dart';
import 'category_chip.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool compact;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = compact
        ? DateFormat('dd MMM', 'id_ID')
        : DateFormat('dd MMM · HH:mm', 'id_ID');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Source icon bubble
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.sourceColor(transaction.source)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _sourceEmoji(transaction.source),
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant ?? transaction.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        dateFormatter.format(transaction.transactionDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMute,
                        ),
                      ),
                      if (transaction.category != null) ...[
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(color: AppColors.textMute, fontSize: 11)),
                        const SizedBox(width: 6),
                        CategoryChip(
                          icon: transaction.category!.icon,
                          name: transaction.category!.name,
                          color: transaction.category!.color,
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            AmountText(
              amount: transaction.amount,
              type: transaction.type,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }

  String _sourceEmoji(String source) {
    switch (source.toUpperCase()) {
      case 'BCA':       return '🏦';
      case 'MANDIRI':   return '🏛️';
      case 'BNI':       return '🏗️';
      case 'BRI':       return '🏢';
      case 'GOPAY':     return '💚';
      case 'OVO':       return '💜';
      case 'DANA':      return '🔵';
      case 'SHOPEE':
      case 'SHOPEEPAY': return '🧡';
      case 'TOKOPEDIA': return '💚';
      case 'PAYPAL':    return '🔷';
      case 'CASH':      return '💵';
      case 'MANUAL':    return '✏️';
      default:          return '💳';
    }
  }
}

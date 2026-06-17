import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String? icon;
  final String name;
  final String? color;
  final bool compact;

  const CategoryChip({
    super.key,
    this.icon,
    required this.name,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color != null
        ? _hexToColor(color!)
        : AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: TextStyle(fontSize: compact ? 11 : 13)),
            const SizedBox(width: 4),
          ],
          Text(
            name,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

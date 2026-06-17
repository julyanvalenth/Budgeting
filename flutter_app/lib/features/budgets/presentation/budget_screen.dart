import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../transactions/presentation/transactions_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  // Hardcoded budget limits per category (can be made editable later)
  static const Map<String, double> _budgetLimits = {
    'food': 1500000,
    'transport': 600000,
    'shopping': 1000000,
    'bills': 800000,
    'entertainment': 500000,
    'health': 300000,
  };

  static const Map<String, _CatMeta> _catMeta = {
    'food':          _CatMeta('Makanan & Minuman', '🍔', AppColors.orange),
    'transport':     _CatMeta('Transportasi',       '🚗', AppColors.cyan),
    'shopping':      _CatMeta('Belanja',             '🛍️', AppColors.pink),
    'bills':         _CatMeta('Tagihan',             '⚡', AppColors.violetSoft),
    'entertainment': _CatMeta('Hiburan',             '🎬', AppColors.violet),
    'health':        _CatMeta('Kesehatan',           '❤️', AppColors.mint),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    // Use a stable end-of-day so the family key doesn't change on every rebuild
    // (changing key = autoDispose disposes old + creates new = infinite loop)
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final summaryAsync = ref.watch(
      dashboardSummaryProvider((monthStart, endOfToday)),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) {
            final cats = _buildCatSpend(summary);
            final totalLimit = _budgetLimits.values.fold(0.0, (a, b) => a + b);
            final totalSpent = cats.values.fold(0.0, (a, b) => a + b);
            final overallPct = (totalSpent / totalLimit).clamp(0.0, 1.0);

            return CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          _monthLabel(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textDim,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Overall progress card
                        _OverallCard(
                          spent: totalSpent,
                          limit: totalLimit,
                          percent: overallPct,
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Per Kategori',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // ── Category rows ────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _budgetLimits.entries.indexed.map((entry) {
                        final i = entry.$1;
                        final key = entry.$2.key;
                        final limit = entry.$2.value;
                        final spent = cats[key] ?? 0;
                        final meta = _catMeta[key]!;
                        return _BudgetRow(
                          meta: meta,
                          spent: spent,
                          limit: limit,
                        )
                            .animate()
                            .fadeIn(
                                delay: (i * 60).ms, duration: 300.ms)
                            .slideX(begin: 0.03, end: 0);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.violet,
              strokeWidth: 2,
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.red)),
          ),
        ),
      ),
    );
  }

  Map<String, double> _buildCatSpend(Map<String, dynamic> summary) {
    final topCats = summary['topCategories'] as List? ?? [];
    final Map<String, double> result = {};
    for (final item in topCats) {
      final m = item as Map<String, dynamic>;
      final catName = (m['category'] as String? ?? '').toLowerCase();
      final total = (m['total'] as num?)?.toDouble() ?? 0;
      // Map backend category names to our keys
      final key = _resolveKey(catName);
      if (key != null) result[key] = total;
    }
    return result;
  }

  String? _resolveKey(String name) {
    if (name.contains('makan') || name.contains('food')) return 'food';
    if (name.contains('transport') || name.contains('ojek')) return 'transport';
    if (name.contains('belanja') || name.contains('shopping')) return 'shopping';
    if (name.contains('tagih') || name.contains('bill')) return 'bills';
    if (name.contains('hibur') || name.contains('entert')) return 'entertainment';
    if (name.contains('keseh') || name.contains('health')) return 'health';
    return null;
  }

  String _monthLabel() {
    return DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
  }
}

class _CatMeta {
  final String name;
  final String emoji;
  final Color color;
  const _CatMeta(this.name, this.emoji, this.color);
}

// ── Overall Card ──────────────────────────────────────────────────────────────

class _OverallCard extends StatelessWidget {
  final double spent;
  final double limit;
  final double percent;

  const _OverallCard({
    required this.spent,
    required this.limit,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = percent >= 1.0;
    final color = isOver ? AppColors.red : AppColors.violet;
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isOver
            ? LinearGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.2),
                  AppColors.red.withValues(alpha: 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isOver ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver
              ? AppColors.red.withValues(alpha: 0.4)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Budget Bulan Ini',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textDim),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(spent),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      'dari ${fmt.format(limit)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚠ Over budget',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOver
                          ? [AppColors.red, AppColors.pink]
                          : [AppColors.violet, AppColors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${(percent * 100).toStringAsFixed(0)}% terpakai',
            style: TextStyle(
                fontSize: 11,
                color: isOver ? AppColors.red : AppColors.textDim),
          ),
        ],
      ),
    );
  }
}

// ── Budget Row ────────────────────────────────────────────────────────────────

class _BudgetRow extends StatelessWidget {
  final _CatMeta meta;
  final double spent;
  final double limit;

  const _BudgetRow({
    required this.meta,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (spent / limit).clamp(0.0, 1.0);
    final isOver = spent > limit;
    final barColor = isOver ? AppColors.red : meta.color;
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOver
              ? AppColors.red.withValues(alpha: 0.3)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(meta.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${fmt.format(spent)} / ${fmt.format(limit)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHi,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOver
                          ? [AppColors.red, AppColors.pink]
                          : [barColor, barColor.withValues(alpha: 0.6)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.red, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Melebihi budget ${fmt.format(spent - limit)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

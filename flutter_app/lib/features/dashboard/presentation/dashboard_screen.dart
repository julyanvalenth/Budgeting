import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../transactions/presentation/transactions_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/transaction_card.dart';
import 'dashboard_provider.dart';
import '../../add_transaction/presentation/add_transaction_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    // Stable end-of-day key prevents autoDispose.family rebuild loop
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final summaryAsync = ref.watch(dashboardSummaryProvider((monthStart, endOfToday)));
    final transactionsAsync = ref.watch(transactionsListProvider);
    final userAsync = ref.watch(authNotifierProvider);
    final weekAsync = ref.watch(weeklySpendProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaction(context),
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _DashboardHeader(
              userAsync: userAsync,
              summaryAsync: summaryAsync,
              balanceHidden: _balanceHidden,
              onToggleBalance: () =>
                  setState(() => _balanceHidden = !_balanceHidden),
            ),
          ),

          // ── Body ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // Summary row
                summaryAsync.when(
                  data: (s) => _SummaryRow(summary: s)
                      .animate()
                      .fadeIn(duration: 350.ms),
                  loading: () => const _SummaryRowSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Spending chart
                weekAsync.when(
                  data: (data) => _SpendingChart(weekData: data)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 350.ms),
                  loading: () => const _ChartSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Top categories
                summaryAsync.when(
                  data: (s) {
                    final cats = s['topCategories'] as List? ?? [];
                    if (cats.isEmpty) return const SizedBox.shrink();
                    return _TopCategories(categories: cats)
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 350.ms);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // Recent transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: AppColors.violet,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                transactionsAsync.when(
                  data: (txs) => Column(
                    children: txs
                        .take(5)
                        .map((t) => TransactionCard(
                              transaction: t,
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.04, end: 0))
                        .toList(),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.violet,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  error: (e, _) => _ErrorTile(message: e.toString()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    ).then((_) {
      ref.invalidate(transactionsListProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(weeklySpendProvider);
    });
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final AsyncValue userAsync;
  final AsyncValue<Map<String, dynamic>> summaryAsync;
  final bool balanceHidden;
  final VoidCallback onToggleBalance;

  const _DashboardHeader({
    required this.userAsync,
    required this.summaryAsync,
    required this.balanceHidden,
    required this.onToggleBalance,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = userAsync.valueOrNull?.name?.split(' ').first ?? 'User';
    final avatar = userAsync.valueOrNull?.avatarUrl;

    final totalBalance = summaryAsync.whenOrNull(
          data: (s) {
            final credit = (s['totalCredit'] as num?)?.toDouble() ?? 0;
            final debit = (s['totalDebit'] as num?)?.toDouble() ?? 0;
            return credit - debit;
          },
        ) ??
        0.0;

    return Container(
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $firstName! 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.violetSoft.withValues(alpha: 0.2),
                    backgroundImage:
                        avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null
                        ? Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.violetSoft,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Balance hero card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onToggleBalance,
                        child: Icon(
                          balanceHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    balanceHidden
                        ? '••••••••'
                        : _fmtShort(totalBalance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _fmtShort(double v) {
    if (v.abs() >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v.abs() >= 1000) {
      return 'Rp ${(v / 1000).round()}k';
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(v);
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final income = (summary['totalCredit'] as num?)?.toDouble() ?? 0;
    final expense = (summary['totalDebit'] as num?)?.toDouble() ?? 0;
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Pemasukan',
            amount: fmt.format(income),
            icon: Icons.arrow_downward_rounded,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            label: 'Pengeluaran',
            amount: fmt.format(expense),
            icon: Icons.arrow_upward_rounded,
            color: AppColors.red,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDim,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRowSkeleton extends StatelessWidget {
  const _SummaryRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Spending Chart ────────────────────────────────────────────────────────────

class _SpendingChart extends StatelessWidget {
  final List<double> weekData;
  const _SpendingChart({required this.weekData});

  @override
  Widget build(BuildContext context) {
    final maxY = weekData.isEmpty
        ? 100000.0
        : weekData.reduce((a, b) => a > b ? a : b) * 1.3;
    final now = DateTime.now();
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Day labels for last 7 days
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran 7 Hari',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY == 0 ? 100000 : maxY,
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weekData[i],
                        gradient: LinearGradient(
                          colors: [
                            AppColors.violet.withValues(alpha: 0.7),
                            AppColors.cyan,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dayLabels[idx],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMute,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ── Top Categories ────────────────────────────────────────────────────────────

class _TopCategories extends StatelessWidget {
  final List categories;
  const _TopCategories({required this.categories});

  static const _catColors = [
    AppColors.orange,
    AppColors.cyan,
    AppColors.pink,
    AppColors.violetSoft,
    AppColors.mint,
    AppColors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Kategori',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length.clamp(0, 6),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = categories[i] as Map<String, dynamic>;
              final name = item['category'] as String? ?? '—';
              final total = (item['total'] as num?)?.toDouble() ?? 0;
              final color = _catColors[i % _catColors.length];

              return Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: color.withValues(alpha: 0.25), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.circle, color: color, size: 12),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textDim,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _fmtShort(total),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _fmtShort(double v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'Rp ${(v / 1000).round()}k';
    return 'Rp ${v.round()}';
  }
}

// ── Error Tile ────────────────────────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Error: $message',
          style: const TextStyle(color: AppColors.red, fontSize: 12)),
    );
  }
}

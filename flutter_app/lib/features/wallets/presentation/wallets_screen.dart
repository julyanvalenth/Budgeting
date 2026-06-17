import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../transactions/presentation/transactions_provider.dart';
import '../../transactions/domain/transaction_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Wallet metadata
// ─────────────────────────────────────────────────────────────────────────────

class _WalletDef {
  final String source;
  final String name;
  final String emoji;
  final String sub;
  final LinearGradient gradient;

  const _WalletDef({
    required this.source,
    required this.name,
    required this.emoji,
    required this.sub,
    required this.gradient,
  });
}

const _walletDefs = [
  _WalletDef(
    source: 'BCA',
    name: 'BCA Debit',
    emoji: '🏦',
    sub: 'Bank account',
    gradient: AppColors.bcaGradient,
  ),
  _WalletDef(
    source: 'GOPAY',
    name: 'GoPay',
    emoji: '💚',
    sub: 'E-wallet',
    gradient: AppColors.gopayGradient,
  ),
  _WalletDef(
    source: 'CASH',
    name: 'Cash',
    emoji: '💵',
    sub: 'Physical wallet',
    gradient: AppColors.cashGradient,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  Provider — derive wallet balances from transactions
// ─────────────────────────────────────────────────────────────────────────────

final walletsDataProvider =
    FutureProvider.autoDispose<Map<String, _WalletData>>((ref) async {
  final txs = await ref.watch(transactionsListProvider.future);

  // Group by source; pick balance from latest transaction per source,
  // or compute net if balance field is null.
  final Map<String, List<Transaction>> bySource = {};
  for (final t in txs) {
    bySource.putIfAbsent(t.source.toUpperCase(), () => []).add(t);
  }

  final Map<String, _WalletData> result = {};
  for (final entry in bySource.entries) {
    final sorted = [...entry.value]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    // Use latest balance field if available
    double? latestBalance = sorted.firstOrNull?.balance;

    double net = 0;
    if (latestBalance == null) {
      for (final t in sorted) {
        if (t.type == TransactionType.credit) {
          net += t.amount;
        } else {
          net -= t.amount;
        }
      }
    }

    result[entry.key] = _WalletData(
      balance: latestBalance ?? net,
      recentTxs: sorted.take(4).toList(),
      txCount: sorted.length,
    );
  }

  return result;
});

class _WalletData {
  final double balance;
  final List<Transaction> recentTxs;
  final int txCount;
  const _WalletData({
    required this.balance,
    required this.recentTxs,
    required this.txCount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dompet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  walletsAsync.when(
                    data: (data) {
                      final total = _walletDefs.fold(0.0, (sum, def) {
                        return sum + (data[def.source]?.balance ?? 0);
                      });
                      return Text(
                        'Total: ${_fmtRupiah(total)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDim,
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ───────────────────────────────────────
            Expanded(
              child: walletsAsync.when(
                data: (data) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _walletDefs.length,
                  itemBuilder: (context, i) {
                    final def = _walletDefs[i];
                    final walletData = data[def.source];
                    return _WalletCard(
                      def: def,
                      data: walletData,
                    )
                        .animate()
                        .fadeIn(delay: (i * 80).ms, duration: 350.ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                ),
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Wallet Card
// ─────────────────────────────────────────────────────────────────────────────

class _WalletCard extends StatefulWidget {
  final _WalletDef def;
  final _WalletData? data;

  const _WalletCard({required this.def, required this.data});

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _expanded = false;
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    final data = widget.data;
    final balance = data?.balance ?? 0;
    final txCount = data?.txCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // ── Gradient header ──────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: def.gradient,
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(def.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              def.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              def.sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Eye toggle
                      GestureDetector(
                        onTap: () => setState(() => _hidden = !_hidden),
                        child: Icon(
                          _hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Expand chevron
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _hidden ? '••••••' : _fmtRupiah(balance),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$txCount transaksi bulan ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable recent transactions ───────────────────
          AnimatedSize(
            duration: 250.ms,
            curve: Curves.easeInOut,
            child: _expanded && (data?.recentTxs.isNotEmpty ?? false)
                ? Column(
                    children: [
                      Divider(height: 1, color: AppColors.border),
                      ...data!.recentTxs.map((t) => _TxRow(tx: t)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Transaction row inside wallet
// ─────────────────────────────────────────────────────────────────────────────

class _TxRow extends StatelessWidget {
  final Transaction tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isDebit = tx.type == TransactionType.debit;
    final amountColor = isDebit ? AppColors.red : AppColors.mint;
    final sign = isDebit ? '- ' : '+ ';
    final fmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.merchant ?? tx.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('d MMM', 'id_ID').format(tx.transactionDate),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMute),
                ),
              ],
            ),
          ),
          Text(
            '$sign${fmt.format(tx.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtRupiah(double v) {
  if (v.abs() >= 1000000) {
    return 'Rp ${(v / 1000000).toStringAsFixed(1)}M';
  }
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/transactions_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);
    final txsAsync = ref.watch(transactionsListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    // ── Avatar + Name ──────────────────────────
                    userAsync.when(
                      data: (user) => _UserHeader(
                        name: user?.name ?? 'User',
                        email: user?.email ?? '',
                        avatar: user?.avatarUrl,
                        createdAt: user?.createdAt,
                      ).animate().fadeIn(duration: 400.ms),
                      loading: () => const _AvatarSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    // ── Stats row ──────────────────────────────
                    txsAsync.when(
                      data: (txs) {
                        final expenseCount = txs
                            .where((t) => t.type == TransactionType.debit)
                            .length;
                        final incomeCount = txs
                            .where((t) => t.type == TransactionType.credit)
                            .length;
                        return _StatsRow(
                          totalTx: txs.length,
                          expenses: expenseCount,
                          incomes: incomeCount,
                        ).animate().fadeIn(delay: 100.ms, duration: 350.ms);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Settings sections ──────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _SectionHeader('Sinkronisasi'),
                  _SettingsItem(
                    icon: Icons.sync_rounded,
                    color: AppColors.cyan,
                    label: 'Sync Gmail',
                    subtitle: 'Ambil transaksi dari email bank',
                    onTap: () => ref
                        .read(syncNotifierProvider.notifier)
                        .syncFromGmail(),
                  ),
                  _SettingsItem(
                    icon: Icons.email_outlined,
                    color: AppColors.violet,
                    label: 'Pengaturan Sync',
                    subtitle: 'Kelola akses Gmail',
                    onTap: () => context.push('/sync'),
                  ),
                  const SizedBox(height: 16),

                  const _SectionHeader('Preferensi'),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    color: AppColors.amber,
                    label: 'Notifikasi',
                    subtitle: 'Pengingat budget & transaksi',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.security_outlined,
                    color: AppColors.mint,
                    label: 'Keamanan',
                    subtitle: 'Biometrik & PIN',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    color: AppColors.pink,
                    label: 'Bahasa',
                    subtitle: 'Indonesia',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),

                  const _SectionHeader('Tentang'),
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    color: AppColors.textDim,
                    label: 'Versi Aplikasi',
                    subtitle: '1.0.0',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.shield_outlined,
                    color: AppColors.textDim,
                    label: 'Kebijakan Privasi',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).logout(),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.red),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.red, width: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  User Header
// ─────────────────────────────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatar;
  final DateTime? createdAt;

  const _UserHeader({
    required this.name,
    required this.email,
    this.avatar,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final memberSince = createdAt != null
        ? DateFormat('MMMM yyyy', 'id_ID').format(createdAt!)
        : null;

    return Column(
      children: [
        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: avatar != null
                  ? ClipOval(child: Image.network(avatar!, fit: BoxFit.cover))
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          style: const TextStyle(fontSize: 13, color: AppColors.textDim),
        ),
        if (memberSince != null) ...[
          const SizedBox(height: 4),
          Text(
            'Member sejak $memberSince',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMute),
          ),
        ],
      ],
    );
  }
}

class _AvatarSkeleton extends StatelessWidget {
  const _AvatarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 12),
        Container(
            width: 140, height: 18, color: AppColors.surface),
        const SizedBox(height: 6),
        Container(
            width: 180, height: 13, color: AppColors.surface),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int totalTx;
  final int expenses;
  final int incomes;

  const _StatsRow({
    required this.totalTx,
    required this.expenses,
    required this.incomes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _StatCell(label: 'Total Transaksi', value: '$totalTx'),
          _Divider(),
          _StatCell(label: 'Pengeluaran', value: '$expenses', color: AppColors.red),
          _Divider(),
          _StatCell(label: 'Pemasukan', value: '$incomes', color: AppColors.mint),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatCell({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMute),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 0.5, height: 40, color: AppColors.border);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Settings Items
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMute,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.color,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMute),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMute, size: 20),
          ],
        ),
      ),
    );
  }
}

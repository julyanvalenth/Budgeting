import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────────────────────────────────────

class _Category {
  final String key;
  final String name;
  final String emoji;
  final Color color;
  const _Category(this.key, this.name, this.emoji, this.color);
}

const _expenseCategories = [
  _Category('food', 'Makanan', '🍔', AppColors.orange),
  _Category('transport', 'Transport', '🚗', AppColors.cyan),
  _Category('shopping', 'Belanja', '🛍️', AppColors.pink),
  _Category('bills', 'Tagihan', '⚡', AppColors.violetSoft),
  _Category('entertainment', 'Hiburan', '🎬', AppColors.violet),
  _Category('health', 'Kesehatan', '❤️', AppColors.mint),
  _Category('education', 'Pendidikan', '📚', AppColors.amber),
  _Category('other', 'Lainnya', '📦', AppColors.textDim),
];

const _incomeCategories = [
  _Category('salary', 'Gaji', '💼', AppColors.mint),
  _Category('freelance', 'Freelance', '💻', AppColors.cyan),
  _Category('investment', 'Investasi', '📈', AppColors.amber),
  _Category('gift', 'Hadiah', '🎁', AppColors.pink),
  _Category('other', 'Lainnya', '📦', AppColors.textDim),
];

class _Wallet {
  final String key;
  final String name;
  final String emoji;
  final LinearGradient gradient;
  const _Wallet(this.key, this.name, this.emoji, this.gradient);
}

const _wallets = [
  _Wallet('bca', 'BCA Debit', '🏦', AppColors.bcaGradient),
  _Wallet('gopay', 'GoPay', '💚', AppColors.gopayGradient),
  _Wallet('cash', 'Cash', '💵', AppColors.cashGradient),
];

// ─────────────────────────────────────────────────────────────────────────────
//  Sheet
// ─────────────────────────────────────────────────────────────────────────────

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  TransactionType _type = TransactionType.debit;
  String _amountStr = '0';
  _Category? _selectedCat;
  _Wallet? _selectedWallet;
  final _noteController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKey(String k) {
    setState(() {
      _error = null;
      if (k == '⌫') {
        if (_amountStr.length <= 1) {
          _amountStr = '0';
        } else {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (k == '.') {
        if (!_amountStr.contains('.')) _amountStr += '.';
      } else {
        if (_amountStr == '0') {
          _amountStr = k;
        } else {
          // Limit to 12 digits before decimal
          final parts = _amountStr.split('.');
          if (parts[0].length < 12) _amountStr += k;
        }
      }
    });
  }

  double get _amount => double.tryParse(_amountStr) ?? 0;

  String get _displayAmount {
    if (_amountStr.contains('.')) return _amountStr;
    final v = double.tryParse(_amountStr) ?? 0;
    if (v == 0) return '0';
    return NumberFormat('#,###', 'id_ID').format(v);
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      setState(() => _error = 'Masukkan nominal yang valid');
      return;
    }
    if (_selectedCat == null) {
      setState(() => _error = 'Pilih kategori');
      return;
    }
    if (_selectedWallet == null) {
      setState(() => _error = 'Pilih dompet');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.create({
        'amount': _amount,
        'type': _type == TransactionType.debit ? 'DEBIT' : 'CREDIT',
        'description': _noteController.text.trim().isEmpty
            ? _selectedCat!.name
            : _noteController.text.trim(),
        'source': _selectedWallet!.key.toUpperCase(),
        // Must be UTC ISO-8601 (with Z) to pass Zod .datetime() validation
        'transactionDate': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats =
        _type == TransactionType.debit ? _expenseCategories : _incomeCategories;
    final accentColor =
        _type == TransactionType.debit ? AppColors.red : AppColors.mint;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type toggle
                  _TypeToggle(
                    type: _type,
                    onChanged: (t) => setState(() {
                      _type = t;
                      _selectedCat = null;
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Amount display
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 16,
                            color: accentColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _displayAmount,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Numpad
                  _Numpad(onKey: _onKey),
                  const SizedBox(height: 20),

                  // Category
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cats.map((cat) {
                      final sel = _selectedCat?.key == cat.key;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCat = cat),
                        child: AnimatedContainer(
                          duration: 120.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? cat.color.withValues(alpha: 0.2)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? cat.color : AppColors.border,
                              width: sel ? 1.0 : 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      sel ? cat.color : AppColors.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Wallet
                  const Text(
                    'Dompet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _wallets.map((w) {
                      final sel = _selectedWallet?.key == w.key;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedWallet = w),
                          child: AnimatedContainer(
                            duration: 120.ms,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: sel ? w.gradient : null,
                              color: sel ? null : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel
                                    ? Colors.transparent
                                    : AppColors.border,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(w.emoji,
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                  w.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sel
                                        ? Colors.white
                                        : AppColors.textDim,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Note
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Catatan (opsional)',
                      prefixIcon: Icon(Icons.edit_note_rounded,
                          color: AppColors.textMute, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Error
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            color: AppColors.red, fontSize: 12),
                      ),
                    ),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Transaksi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Type Toggle
// ─────────────────────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Pengeluaran',
            selected: type == TransactionType.debit,
            color: AppColors.red,
            onTap: () => onChanged(TransactionType.debit),
          ),
          _Tab(
            label: 'Pemasukan',
            selected: type == TransactionType.credit,
            color: AppColors.mint,
            onTap: () => onChanged(TransactionType.credit),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 150.ms,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: selected
                ? Border.all(color: color.withValues(alpha: 0.5), width: 0.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? color : AppColors.textMute,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Numpad
// ─────────────────────────────────────────────────────────────────────────────

class _Numpad extends StatelessWidget {
  final void Function(String key) onKey;
  const _Numpad({required this.onKey});

  static const _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '.', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: _keys.map((k) {
        final isBackspace = k == '⌫';
        return GestureDetector(
          onTap: () => onKey(k),
          child: Container(
            decoration: BoxDecoration(
              color: isBackspace
                  ? AppColors.red.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              k,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isBackspace ? AppColors.red : AppColors.text,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

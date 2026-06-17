import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF7C3AED),
              Color(0xFF1E1B4B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 24),

                  // App name
                  const Text(
                    'BudgetMate',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: 8),
                  Text(
                    'Pantau keuanganmu secara otomatis\ndari email bank & e-wallet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 64),

                  // Feature highlights
                  ...[
                    ('📧', 'Sync otomatis dari Gmail'),
                    ('📊', 'Dashboard pengeluaran real-time'),
                    ('🏷️', 'Kategorisasi cerdas dengan AI'),
                  ].map(
                    (feature) => _FeatureTile(
                      icon: feature.$1,
                      text: feature.$2,
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  ),

                  const SizedBox(height: 48),

                  // Google Sign In Button
                  _GoogleSignInButton()
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),
                  Text(
                    'Dengan login, kamu menyetujui kami membaca\nemail notifikasi transaksi dari Gmail',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<_GoogleSignInButton> {
  bool _isLoading = false;
  StreamSubscription<Uri>? _deepLinkSub;
  final _appLinks = AppLinks();
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _initDeepLink();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _initDeepLink() async {
    // Handle deep link jika app di-launch dari cold start via budgetmate://
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null && mounted) _handleDeepLink(initialUri);

    // Handle deep link saat app sudah berjalan
    _deepLinkSub = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme != 'budgetmate' || uri.host != 'auth') return;

    // Cancel subscription agar deep link tidak diproses dua kali
    _deepLinkSub?.cancel();
    _deepLinkSub = null;

    // Jika backend redirect dengan token langsung
    final token = uri.queryParameters['token'];
    if (token != null && mounted) {
      setState(() => _isLoading = false);
      ref.read(authNotifierProvider.notifier).saveTokenAndRefresh(token);
      return;
    }

    // Jika Google redirect dengan authorization code
    final code = uri.queryParameters['code'];
    if (code == null || !mounted) return;

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get(
        '/auth/mobile/callback',
        queryParameters: {'code': code},
      );
      final jwt = response.data['data']['token'] as String?;
      if (jwt != null && mounted) {
        setState(() => _isLoading = false);
        ref.read(authNotifierProvider.notifier).saveTokenAndRefresh(jwt);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    }
  }

  void _onAppResume() {
    // Jika user kembali ke app tanpa menyelesaikan login, reset loading
    if (_isLoading && mounted) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_isLoading && mounted) setState(() => _isLoading = false);
      });
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    final authUri = Uri.parse(
      '${ApiConstants.baseUrl.replaceAll('/api', '')}/api/auth/google',
    );

    try {
      final launched = await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka browser')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4285F4),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Masuk dengan Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

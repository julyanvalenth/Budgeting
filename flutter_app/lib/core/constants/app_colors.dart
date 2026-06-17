import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Budgetee dark theme tokens
  static const Color bg = Color(0xFF070612);
  static const Color bgSoft = Color(0xFF0D0A1D);
  static const Color surface = Color(0xFF16142A);
  static const Color surfaceHi = Color(0xFF1D1B35);
  static const Color text = Color(0xFFF5F4FB);
  static const Color textDim = Color(0xFF9B9DB8);
  static const Color textMute = Color(0xFF65687F);

  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetSoft = Color(0xFFA78BFA);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color mint = Color(0xFF34D399);
  static const Color pink = Color(0xFFF472B6);
  static const Color amber = Color(0xFFFBBF24);
  static const Color red = Color(0xFFF87171);
  static const Color orange = Color(0xFFFB923C);

  // Border (non-const, uses opacity)
  static Color get border => Colors.white.withValues(alpha: 0.07);
  static Color get borderHi => Colors.white.withValues(alpha: 0.14);

  // Legacy aliases — keep existing code compiling
  static const Color background = bg;
  static const Color cardBg = surface;
  static const Color textPrimary = text;
  static const Color textSecondary = textDim;
  static const Color textHint = textMute;
  static const Color primary = violet;
  static const Color primaryLight = violetSoft;
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color success = mint;
  static const Color danger = red;
  static const Color warning = amber;
  static const Color info = cyan;
  static const Color income = mint;
  static const Color expense = red;

  // Bank / e-wallet source colors
  static const Color bca = Color(0xFF6D28D9);
  static const Color mandiri = Color(0xFFF9A01B);
  static const Color bni = Color(0xFFFF6600);
  static const Color bri = Color(0xFF00529C);
  static const Color gopay = Color(0xFF0EA5E9);
  static const Color ovo = Color(0xFF4C3494);
  static const Color dana = Color(0xFF118EEA);
  static const Color shopeepay = Color(0xFFEE4D2D);

  static Color sourceColor(String source) {
    switch (source.toUpperCase()) {
      case 'BCA':       return bca;
      case 'MANDIRI':   return mandiri;
      case 'BNI':       return bni;
      case 'BRI':       return bri;
      case 'GOPAY':     return gopay;
      case 'OVO':       return ovo;
      case 'DANA':      return dana;
      case 'SHOPEE':
      case 'SHOPEEPAY': return shopeepay;
      default:          return textDim;
    }
  }

  // Gradient presets
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF2563EB), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bcaGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gopayGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cashGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

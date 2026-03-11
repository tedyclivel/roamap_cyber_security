import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';

// ─── Palettes par Variante ─────────────────────────────────────────
class IronMindPalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const IronMindPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  factory IronMindPalette.fromVariant(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.cyan:
        return const IronMindPalette(
          primary:   Color(0xFF22D3EE), 
          secondary: Color(0xFF38BDF8), 
          tertiary:  Color(0xFF818CF8),
        );
      case ThemeVariant.amber:
        return const IronMindPalette(
          primary:   Color(0xFFFBBF24), 
          secondary: Color(0xFFF59E0B), 
          tertiary:  Color(0xFFD97706),
        );
      case ThemeVariant.rose:
        return const IronMindPalette(
          primary:   Color(0xFFFB7185), 
          secondary: Color(0xFFF43F5E), 
          tertiary:  Color(0xFFE11D48),
        );
      case ThemeVariant.emerald:
      default:
        return const IronMindPalette(
          primary:   Color(0xFF4ADE80), 
          secondary: Color(0xFF22D3EE), 
          tertiary:  Color(0xFF8B5CF6),
        );
    }
  }
}

// ─── Couleurs de base ──────────────────────────────────────────────
class IronMindColors {
  IronMindColors._();

  static const Color background     = Color(0xFF0B0B0C);
  static const Color surface        = Color(0xFF121214);
  static const Color surfaceVariant = Color(0xFF1E1E22);
  static const Color card           = Color(0xFF161618);

  // Textes
  static const Color textPrimary   = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled  = Color(0xFF475569);

  // États
  static const Color success = Color(0xFF4ADE80);
  static const Color error   = Color(0xFFFB7185);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info    = Color(0xFF22D3EE);

  // Glassmorphism
  static const Color glassWhite  = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x2694A3B8);

  // Méthode pour obtenir les couleurs de domaine harmonisées
  static Color domainColor(int index, ThemeVariant variant) {
    final palette = IronMindPalette.fromVariant(variant);
    switch (index) {
      case 0: return const Color(0xFFFB923C); // Physique reste orange pour visibilité
      case 1: return palette.secondary;
      case 2: return palette.primary;
      case 3: return palette.tertiary;
      case 4: return const Color(0xFFFBBF24); // Linux reste jaune
      default: return palette.primary;
    }
  }
  
  // Raccourcis pour compatibilité (Emerald par défaut)
  static const Color physique = Color(0xFFFB923C);
  static const Color algo     = Color(0xFF38BDF8);
  static const Color cyber    = Color(0xFF4ADE80);
  static const Color mental   = Color(0xFF8B5CF6);
  static const Color linux    = Color(0xFFFBBF24);
  static const Color neonGreen = Color(0xFF4ADE80);
  static const Color neonCyan  = Color(0xFF22D3EE);
  static const Color neonPurple = Color(0xFF8B5CF6);
}

// ─── Thème Principal ───────────────────────────────────────────────
class IronMindTheme {
  IronMindTheme._();

  static ThemeData build(ThemeVariant variant) {
    final palette = IronMindPalette.fromVariant(variant);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: IronMindColors.background,
      colorScheme: ColorScheme.dark(
        background:   IronMindColors.background,
        surface:      IronMindColors.surface,
        primary:      palette.primary,
        secondary:    palette.secondary,
        tertiary:     palette.tertiary,
        error:        IronMindColors.error,
        onBackground: IronMindColors.textPrimary,
        onSurface:    IronMindColors.textPrimary,
        onPrimary:    IronMindColors.background,
      ),
      textTheme: _buildTextTheme(palette.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.primary,
          letterSpacing: 3,
        ),
      ),
      cardTheme: CardThemeData(
        color: IronMindColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: IronMindColors.glassBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: IronMindColors.glassBorder,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IronMindColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IronMindColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IronMindColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: IronMindColors.textSecondary, fontFamily: 'JetBrainsMono'),
        hintStyle:  const TextStyle(color: IronMindColors.textDisabled, fontFamily: 'JetBrainsMono'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: IronMindColors.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: IronMindColors.textDisabled,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(IronMindColors.background),
        side: BorderSide(color: palette.primary, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: IronMindColors.surfaceVariant,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return IronMindColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary.withOpacity(0.3);
          return IronMindColors.surfaceVariant;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.primary,
        inactiveTrackColor: IronMindColors.surfaceVariant,
        thumbColor: palette.primary,
        overlayColor: palette.primary.withOpacity(0.2),
        valueIndicatorColor: palette.primary,
        valueIndicatorTextStyle: const TextStyle(fontFamily: 'Orbitron', color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color accent) {
    return TextTheme(
      displayLarge:  GoogleFonts.orbitron(fontSize: 36, fontWeight: FontWeight.w800, color: IronMindColors.textPrimary, letterSpacing: 2),
      displayMedium: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.w700, color: IronMindColors.textPrimary, letterSpacing: 1.5),
      displaySmall:  GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.w700, color: IronMindColors.textPrimary),
      headlineLarge: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: IronMindColors.textPrimary),
      headlineMedium:GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.w600, color: IronMindColors.textPrimary),
      headlineSmall: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w600, color: IronMindColors.textPrimary),
      titleLarge:    GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w600, color: IronMindColors.textPrimary, letterSpacing: 1),
      titleMedium:   const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.w500, color: IronMindColors.textPrimary),
      titleSmall:    const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, fontWeight: FontWeight.w500, color: IronMindColors.textSecondary),
      bodyLarge:     const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, color: IronMindColors.textPrimary),
      bodyMedium:    const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, color: IronMindColors.textSecondary),
      bodySmall:     const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: IronMindColors.textDisabled),
      labelLarge:    TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, fontWeight: FontWeight.w700, color: accent, letterSpacing: 1),
      labelMedium:   const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, fontWeight: FontWeight.w500, color: IronMindColors.textSecondary, letterSpacing: 0.8),
      labelSmall:    const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, fontWeight: FontWeight.w400, color: IronMindColors.textDisabled, letterSpacing: 0.5),
    );
  }
}

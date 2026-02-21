import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppColors — Insightlancer Design System
/// Recruitment Portal · Alumni Dashboard
/// ─────────────────────────────────────────────────────────────────────────────
///
/// Usage:
///   color: AppColors.deepNavy
///   decoration: BoxDecoration(gradient: AppGradients.heroHeader)
///
/// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Primary ─────────────────────────────────────────────────────────────────

  /// Deep Navy Blue — primary brand color, hero headers, text, icons
  static const Color deepNavy = Color(0xFF1A365D);

  /// Navy Dark — deeper shade for shadows and pressed states
  static const Color navyDark = Color(0xFF102440);

  /// Navy Light — lighter navy for hover/focus rings
  static const Color navyLight = Color(0xFF254D7A);

  // ── Accent ──────────────────────────────────────────────────────────────────

  /// Sky Accent — active tabs, CTAs, links, progress fills
  static const Color skyAccent = Color(0xFF4A90D9);

  /// Sky Light — lighter sky for hover states
  static const Color skyLight = Color(0xFF6AAEE8);

  /// Sky Dark — darker sky for pressed states
  static const Color skyDark = Color(0xFF2F72B8);

  // ── Ice Blue ─────────────────────────────────────────────────────────────────

  /// Ice Blue — soft accents, borders, muted text on dark backgrounds
  static const Color iceBlue = Color(0xFFBFD7ED);

  /// Ice Blue Light — very light ice, progress bar tracks, chip backgrounds
  static const Color iceBlueFaint = Color(0xFFE4EFF8);

  // ── Backgrounds ──────────────────────────────────────────────────────────────

  /// Soft White — main scaffold/page background
  static const Color softWhite = Color(0xFFF7F9FC);

  /// Card White — elevated card surfaces
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Surface Grey — secondary surface, input fields, chip fills
  static const Color surfaceGrey = Color(0xFFF0F4F8);

  // ── Text ─────────────────────────────────────────────────────────────────────

  /// Text Primary — main body and heading text on light backgrounds
  static const Color textPrimary = Color(0xFF1A365D); // same as deepNavy

  /// Text Secondary — subtitles, labels, secondary copy
  static const Color textSecondary = Color(0xFF4A6580);

  /// Text Muted — placeholders, timestamps, fine print
  static const Color textMuted = Color(0xFF8FA8C0);

  /// Text On Dark — primary text on deep navy backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text On Dark Muted — secondary text on deep navy backgrounds
  static const Color textOnDarkMuted = Color(0xFF8CADC8);

  // ── Semantic — Status ────────────────────────────────────────────────────────

  /// Green — success, active, positive states
  static const Color success = Color(0xFF34C98B);

  /// Green Light — success badge background
  static const Color successLight = Color(0xFFDFF7EE);

  /// Amber — warning, pending, in-review states
  static const Color warning = Color(0xFFF5A623);

  /// Amber Light — warning badge background
  static const Color warningLight = Color(0xFFFEF3DC);

  /// Red — error, closed, destructive actions
  static const Color error = Color(0xFFE53E3E);

  /// Red Light — error badge background
  static const Color errorLight = Color(0xFFFDE8E8);

  /// Info — informational, new tags
  static const Color info = Color(0xFF4A90D9); // same as skyAccent

  /// Info Light — info badge background
  static const Color infoLight = Color(0xFFDCECF8);

  // ── Social Brand Colors ───────────────────────────────────────────────────────

  /// LinkedIn brand blue
  static const Color linkedIn = Color(0xFF0077B5);

  /// GitHub brand dark
  static const Color gitHub = Color(0xFF24292E);

  /// Portfolio / Website teal-green
  static const Color portfolio = Color(0xFF34C98B);

  // ── Overlay & Shadow ──────────────────────────────────────────────────────────

  /// Barrier color for dialogs and bottom sheets
  static Color barrierColor = deepNavy.withOpacity(0.40);

  /// Standard card shadow color
  static Color cardShadow = deepNavy.withOpacity(0.07);

  /// Hero section shadow color
  static Color heroShadow = deepNavy.withOpacity(0.20);

  /// Floating nav shadow color
  static Color navShadow = deepNavy.withOpacity(0.35);

  // ── Glassmorphism ─────────────────────────────────────────────────────────────

  /// Glass surface on dark navy (e.g. stat strips inside hero)
  static Color glassOnDark = Colors.white.withOpacity(0.07);

  /// Glass border on dark navy
  static Color glassBorderOnDark = Colors.white.withOpacity(0.10);

  /// Glass divider on dark navy
  static Color glassDividerOnDark = Colors.white.withOpacity(0.10);
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AppGradients — all LinearGradient / RadialGradient definitions
/// ─────────────────────────────────────────────────────────────────────────────

class AppGradients {
  AppGradients._(); // prevent instantiation

  // ── Hero / Header Gradients ───────────────────────────────────────────────────

  /// Full deep navy hero — used on HomeTab & ProfileTab top header card
  static const LinearGradient heroHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A365D), // deepNavy
      Color(0xFF1E4A7A), // navyLight-ish
    ],
  );

  /// Richer navy-to-slate hero — alternate for special screens
  static const LinearGradient heroHeaderRich = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
    colors: [
      Color(0xFF102440), // navyDark
      Color(0xFF1A365D), // deepNavy
      Color(0xFF254D7A), // navyLight
    ],
  );

  // ── Scaffold Background Gradient ──────────────────────────────────────────────

  /// Soft radial gradient for scaffold background (ice blue → white)
  static const RadialGradient scaffoldBackground = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.6,
    colors: [
      Color(0xFFDCECF8), // iceBlueFaint
      Color(0xFFF7F9FC), // softWhite
    ],
  );

  /// Subtle top-to-bottom linear alternative for scaffold background
  static const LinearGradient scaffoldBackgroundLinear = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F1FA),
      Color(0xFFF7F9FC),
    ],
  );

  // ── Accent / CTA Gradients ────────────────────────────────────────────────────

  /// Sky blue gradient — for primary buttons and active metric pods
  static const LinearGradient skyButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6AAEE8), // skyLight
      Color(0xFF4A90D9), // skyAccent
    ],
  );

  /// Navy button gradient — for secondary CTA buttons
  static const LinearGradient navyButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF254D7A), // navyLight
      Color(0xFF1A365D), // deepNavy
    ],
  );

  // ── Metric / Card Gradients ───────────────────────────────────────────────────

  /// Active Jobs pod gradient — sky blue tones
  static const LinearGradient metricActiveJobs = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6AAEE8),
      Color(0xFF4A90D9),
    ],
  );

  /// Applications pod gradient — teal-green tones
  static const LinearGradient metricApplications = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4DDBA4),
      Color(0xFF34C98B),
    ],
  );

  /// Warning / Pending pod gradient — amber tones
  static const LinearGradient metricWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7BE5C),
      Color(0xFFF5A623),
    ],
  );

  /// Closed / Error pod gradient — muted slate tones
  static const LinearGradient metricClosed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB0C4D8),
      Color(0xFF8FA8C0),
    ],
  );

  // ── Progress Bar Gradients ────────────────────────────────────────────────────

  /// Sky progress bar fill
  static const LinearGradient progressSky = LinearGradient(
    colors: [Color(0xFF6AAEE8), Color(0xFF4A90D9)],
  );

  /// Green progress bar fill
  static const LinearGradient progressGreen = LinearGradient(
    colors: [Color(0xFF4DDBA4), Color(0xFF34C98B)],
  );

  /// Amber progress bar fill
  static const LinearGradient progressAmber = LinearGradient(
    colors: [Color(0xFFF7BE5C), Color(0xFFF5A623)],
  );

  // ── Floating Nav Bar Gradient ─────────────────────────────────────────────────

  /// Floating bottom nav — deep navy with subtle left-to-right lift
  static const LinearGradient floatingNav = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF254D7A),
      Color(0xFF1A365D),
    ],
  );

  // ── Overlay Gradients ─────────────────────────────────────────────────────────

  /// Bottom fade overlay — for content that fades into the floating nav
  static const LinearGradient bottomFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xFFF7F9FC),
    ],
  );

  /// Dark overlay for modal barriers
  static LinearGradient modalBarrier = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.deepNavy.withOpacity(0.0),
      AppColors.deepNavy.withOpacity(0.6),
    ],
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AppShadows — reusable BoxShadow lists
/// ─────────────────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  /// Standard card shadow — subtle lift for white cards
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated card shadow — for modals and bottom sheets
  static List<BoxShadow> cardElevated = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Floating nav shadow
  static List<BoxShadow> floatingNav = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  /// Hero header bottom shadow
  static List<BoxShadow> hero = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.20),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// Metric pod / colored card shadow (use with pod's own color)
  static List<BoxShadow> coloredPod(Color podColor) => [
        BoxShadow(
          color: podColor.withOpacity(0.30),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];

  /// Button shadow
  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.skyAccent.withOpacity(0.35),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
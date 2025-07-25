import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode enumeration
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme state class
class ThemeState {
  final AppThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.primaryColor = Colors.blue,
    this.fontSize = 14.0,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'primaryColor': primaryColor.value,
      'fontSize': fontSize,
    };
  }

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      themeMode: AppThemeMode.values[json['themeMode'] ?? 0],
      primaryColor: Color(json['primaryColor'] ?? Colors.blue.value),
      fontSize: json['fontSize']?.toDouble() ?? 14.0,
    );
  }
}

/// Theme notifier class
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_settings';
  
  ThemeNotifier() : super(const ThemeState()) {
    _loadThemeSettings();
  }

  /// Load theme settings from shared preferences
  Future<void> _loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString(_themeKey);
      
      if (themeJson != null) {
        final themeData = Map<String, dynamic>.from(
          // Simple JSON parsing for basic types
          {
            'themeMode': prefs.getInt('themeMode') ?? 0,
            'primaryColor': prefs.getInt('primaryColor') ?? Colors.blue.value,
            'fontSize': prefs.getDouble('fontSize') ?? 14.0,
          }
        );
        
        state = ThemeState.fromJson(themeData);
      }
    } catch (e) {
      // If loading fails, keep default theme
      debugPrint('Failed to load theme settings: $e');
    }
  }

  /// Save theme settings to shared preferences
  Future<void> _saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', state.themeMode.index);
      await prefs.setInt('primaryColor', state.primaryColor.value);
      await prefs.setDouble('fontSize', state.fontSize);
    } catch (e) {
      debugPrint('Failed to save theme settings: $e');
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    final newMode = state.themeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    
    state = state.copyWith(themeMode: newMode);
    _saveThemeSettings();
  }

  /// Set specific theme mode
  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveThemeSettings();
  }

  /// Set primary color
  void setPrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
    _saveThemeSettings();
  }

  /// Set font size
  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
    _saveThemeSettings();
  }

  /// Reset to default theme
  void resetToDefault() {
    state = const ThemeState();
    _saveThemeSettings();
  }
}

/// Theme provider
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

/// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  
  switch (themeState.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Is dark mode provider (for simple boolean checks)
final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.themeMode == AppThemeMode.dark;
});

/// Light theme provider
final lightThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeState.primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(themeState.fontSize, Brightness.light),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
});

/// Dark theme provider
final darkThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeState.primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(themeState.fontSize, Brightness.dark),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
});

/// Build text theme with custom font size
TextTheme _buildTextTheme(double baseFontSize, Brightness brightness) {
  final baseTheme = brightness == Brightness.light 
      ? ThemeData.light().textTheme 
      : ThemeData.dark().textTheme;
  
  return baseTheme.copyWith(
    displayLarge: baseTheme.displayLarge?.copyWith(fontSize: baseFontSize + 42),
    displayMedium: baseTheme.displayMedium?.copyWith(fontSize: baseFontSize + 31),
    displaySmall: baseTheme.displaySmall?.copyWith(fontSize: baseFontSize + 22),
    headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: baseFontSize + 18),
    headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: baseFontSize + 14),
    headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: baseFontSize + 10),
    titleLarge: baseTheme.titleLarge?.copyWith(fontSize: baseFontSize + 8),
    titleMedium: baseTheme.titleMedium?.copyWith(fontSize: baseFontSize + 2),
    titleSmall: baseTheme.titleSmall?.copyWith(fontSize: baseFontSize),
    bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: baseFontSize + 2),
    bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: baseFontSize),
    bodySmall: baseTheme.bodySmall?.copyWith(fontSize: baseFontSize - 2),
    labelLarge: baseTheme.labelLarge?.copyWith(fontSize: baseFontSize),
    labelMedium: baseTheme.labelMedium?.copyWith(fontSize: baseFontSize - 2),
    labelSmall: baseTheme.labelSmall?.copyWith(fontSize: baseFontSize - 4),
  );
}

/// Available theme colors
final availableThemeColors = [
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.teal,
  Colors.indigo,
  Colors.pink,
  Colors.amber,
  Colors.cyan,
];

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/home_screen.dart';

const _fallbackSeedColor = Color(0xFF2196F3);

ThemeData _buildTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness:
        isDark ? Brightness.light : Brightness.dark,
  ));

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surfaceContainer,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(space: 0, thickness: 0),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Hive.initFlutter();
  runApp(const BrainTrainerApp());
}

class BrainTrainerApp extends StatelessWidget {
  const BrainTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final seedColor = lightDynamic?.primary ?? _fallbackSeedColor;
        final lightScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          title: 'BrainTrainer',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: _buildTheme(lightScheme),
          darkTheme: _buildTheme(darkScheme),
          home: const HomeScreen(),
        );
      },
    );
  }
}

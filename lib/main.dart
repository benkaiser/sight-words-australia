import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/progress_service.dart';
import 'screens/home_screen.dart';
import 'screens/placement_screen.dart';
import 'screens/session_screen.dart';
import 'screens/progress_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progressService = ProgressService();
  await progressService.init();

  runApp(
    ChangeNotifierProvider.value(
      value: progressService,
      child: const SightWordsApp(),
    ),
  );
}

class SightWordsApp extends StatelessWidget {
  const SightWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sight Words Australia',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}

/// Top-level navigator that manages screen flow.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

enum AppScreen { home, placement, session, progress }

class _AppShellState extends State<AppShell> {
  AppScreen _screen = AppScreen.home;

  @override
  void initState() {
    super.initState();
    final ps = Provider.of<ProgressService>(context, listen: false);
    if (!ps.placementDone) {
      _screen = AppScreen.placement;
    }
  }

  void _goto(AppScreen screen) => setState(() => _screen = screen);

  @override
  Widget build(BuildContext context) {
    final ps = Provider.of<ProgressService>(context);

    switch (_screen) {
      case AppScreen.placement:
        return PlacementScreen(
          progressService: ps,
          onComplete: () => _goto(AppScreen.home),
        );
      case AppScreen.session:
        return SessionScreen(
          progressService: ps,
          onComplete: () => _goto(AppScreen.home),
        );
      case AppScreen.progress:
        return ProgressScreen(progressService: ps, onBack: () => _goto(AppScreen.home));
      case AppScreen.home:
        return HomeScreen(
          progressService: ps,
          onStartSession: () => _goto(AppScreen.session),
          onViewProgress: () => _goto(AppScreen.progress),
        );
    }
  }
}

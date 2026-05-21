import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'models/aircraft_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    title: 'F-16 Falcon Viewer',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(false); // Resize tamamen engellendi
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AircraftState()),
      ],
      child: const F16ViewerApp(),
    ),
  );
}

class F16ViewerApp extends StatelessWidget {
  const F16ViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F-16 Falcon Viewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
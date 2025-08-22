import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'framework/device/device_feedback_manager.dart';
import 'framework/audio/volume_manager.dart';
import 'game/components/flutter_particle_system.dart';
import 'game/components/global_tap_detector.dart';
import 'game/screens/game_selection_screen.dart';

class EscapeRoomApp extends StatefulWidget {
  const EscapeRoomApp({super.key});

  @override
  State<EscapeRoomApp> createState() => _EscapeRoomAppState();
}

class _EscapeRoomAppState extends State<EscapeRoomApp> {
  @override
  void initState() {
    super.initState();
    DeviceFeedbackManager().initialize();
    VolumeManager().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalTapDetector(
      child: MaterialApp(
        title: 'Escape Master',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Noto Sans JP',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja'), Locale('en')],
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              Positioned.fill(
                child: FlutterParticleSystem(
                  key: FlutterParticleSystem.globalKey,
                ),
              ),
            ],
          );
        },
        home: const GameSelectionScreen(),
      ),
    );
  }
}

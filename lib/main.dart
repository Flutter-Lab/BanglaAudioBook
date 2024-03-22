import 'package:bangla_audio_book/audio_play_screen/player_screen.dart';
import 'package:bangla_audio_book/homepage/home_page.dart';
import 'package:bangla_audio_book/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Working in Background');
    // Call your Riverpod provider function here
    final providerContainer = ProviderContainer();

    // final yourProvider = Provider((ref) => TimerNotifier());
    final result = providerContainer.read(timerProvider);

    if (player.playing == true && result.seconds == 0) {
      print('Timer is Running again');
      providerContainer.read(timerProvider.notifier).startTimer();
    }

    // Do something with the result if needed
    print('Result from provider: $result');

    return Future.value(true); // Return true to indicate success
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  await Workmanager().initialize(callbackDispatcher);

  // Register a periodic task with WorkManager
  await Workmanager().registerPeriodicTask(
    'yourTaskName',
    'yourTaskName', // Task name
    frequency: const Duration(seconds: 5), // Execute task every 15 minutes
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  await Hive.openBox('user_data');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      home: const HomePage(),
    );
  }
}

import 'package:bangla_audio_book/audio_play_screen/player_screen.dart';
import 'package:bangla_audio_book/providers/timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class TimerText extends ConsumerWidget {
  const TimerText({super.key, required AudioPlayer player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Text(
        'Sesson: ${timerState.isRunning ? timerState.seconds.toString() : timerState.seconds} s');
  }
}

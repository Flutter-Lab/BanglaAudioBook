import 'dart:async';

import 'package:bangla_audio_book/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_play_screen/player_screen.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerData>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerData> {
  TimerNotifier() : super(TimerData());

  Timer? _timer;
  int? _previousSeconds;

  void toggleTimer() {
    if (state.isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (_previousSeconds != null) {
      state = TimerData(isRunning: true, seconds: _previousSeconds!);
    } else {
      state = TimerData(isRunning: true, seconds: 0, isActivated: true);
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(seconds: state.seconds + 1);
      if (state.seconds >= pauseTimeInSeconds) {
        player.pause();
        resetTimer();
      }
      if (player.playing == true && state.seconds == 0) {
        startTimer();
      }
    });
  }

  void pauseTimer() {
    _previousSeconds = state.seconds;
    _timer?.cancel();

    state = TimerData(isRunning: false, seconds: state.seconds);
  }

  void resetTimer() {
    _previousSeconds = 0;
    _timer?.cancel();

    state = TimerData(isRunning: false, seconds: 0);
  }
}

class TimerData {
  final bool isRunning;
  final bool isActivated;
  final int seconds;

  TimerData(
      {this.isRunning = false, this.seconds = 0, this.isActivated = false});

  TimerData copyWith({bool? isRunning, int? seconds, bool? isActivated}) {
    return TimerData(
      isRunning: isRunning ?? this.isRunning,
      seconds: seconds ?? this.seconds,
      isActivated: isActivated ?? this.isActivated,
    );
  }
}

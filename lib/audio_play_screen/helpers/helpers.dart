import 'dart:async';

StreamSubscription<int>? subscription;

Stream<int> everySecond() async* {
  int seconds = 0;
  while (true) {
    yield seconds++;
    await Future.delayed(const Duration(seconds: 1));
  }
}

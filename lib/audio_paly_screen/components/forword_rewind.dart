import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ForWordAndRewind extends StatelessWidget {
  const ForWordAndRewind({
    super.key,
    required AudioPlayer player,
  }) : _player = player;

  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              _player.seek(_player.position - const Duration(seconds: 30));
            },
            icon: const Icon(
              Icons.replay_30_outlined,
              size: 32,
            )),
        const SizedBox(width: 32),
        IconButton(
            onPressed: () {
              _player.seek(_player.position + const Duration(seconds: 30));
            },
            icon: const Icon(
              Icons.forward_30_outlined,
              size: 32,
            )),
      ],
    );
  }
}

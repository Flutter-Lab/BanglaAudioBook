import 'package:bangla_audio_book/audio_play_screen/player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/timer_provider.dart';

class BookCard extends ConsumerWidget {
  const BookCard({
    super.key,
    required this.book,
  });

  final Map book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var image = book['image'];
    var title = book['title'];

    final timerState = ref.watch(timerProvider);

    return GestureDetector(
      onTap: () {
        if (timerState.isActivated == false) {
          ref.read(timerProvider.notifier).startTimer();
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayerScreen(
                      bookMap: book,
                    )));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            child: Card(
              shape: const RoundedRectangleBorder(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

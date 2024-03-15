import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';

class ChapterList extends StatelessWidget {
  const ChapterList({
    super.key,
    required this.bookMap,
    required AudioPlayer player,
    required this.positionData,
  }) : _player = player;

  final Map bookMap;
  final AudioPlayer _player;
  final Duration positionData;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: bookMap['chapter_list'].length,
          itemBuilder: (context, index) {
            var chapter = bookMap['chapter_list'][index];
            var chapterStartTime = chapter['start_time'];
            var nextChapterStartTime =
                index < bookMap['chapter_list'].length - 1
                    ? (bookMap['chapter_list'][index + 1]['start_time'])
                    : bookMap['total_length'];

            int chapterLengthInSec = nextChapterStartTime - chapterStartTime;

            String chapterLength = getTimeFromSeconds(chapterLengthInSec);
            // var chapterLength = chapterLengthInSec;

            int position = positionData.inSeconds;
            int? chapterProgressInSec =
                (position >= chapterStartTime && position < nextChapterStartTime
                    ? (position - chapterStartTime)
                    : null) as int?;

            String? chapterProgressTime = chapterProgressInSec != null
                ? getTimeFromSeconds(chapterProgressInSec)
                : null;

            var progressPercent = chapterProgressInSec != null
                ? ((chapterProgressInSec / chapterLengthInSec) * 100).round()
                : null;

            return Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      _player.seek(Duration(seconds: chapter['start_time']));
                    },
                    title: Text('${chapter['title']}'),
                    subtitle: Row(
                      children: [
                        if (chapterProgressTime != null)
                          Text('$chapterProgressTime/'),
                        Text('$chapterLength min'),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        if (progressPercent != null && _player.playing)
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Lottie.asset(
                                    'assets/book_read_animation.json'),
                              ),
                              Expanded(
                                flex: 2,
                                child: Lottie.asset(
                                    'assets/music_animation_1.json'),
                              ),
                            ],
                          )),
                      ],
                    ),
                  ),
                  if (progressPercent != null)
                    LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      minHeight: 8,
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8)),
                      value: progressPercent / 100,
                    )
                ],
              ),
            );
          }),
    );
  }

  String getTimeFromSeconds(int seconds) {
    int minutes = seconds ~/ 60; // Get the whole number of minutes
    int remainingSeconds = seconds % 60; // Get the remaining seconds

    // Format the minutes and seconds with leading zeros if needed
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lottie/lottie.dart';

class ChapterList extends StatefulWidget {
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
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  int? chapterIndex;

  int currentSecond = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.bookMap['multi_source'] == true) {
      chapterIndex = getChapterIndex();
    }
  }

  // Stream<int> _everySecond() =>
  //     Stream.periodic(const Duration(seconds: 1), (count) => count);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.bookMap['chapter_list'].length,
                itemBuilder: (context, index) {
                  var chapter = widget.bookMap['chapter_list'][index];
                  var chapterStartTime = chapter['start_time'];
                  var nextChapterStartTime =
                      index < widget.bookMap['chapter_list'].length - 1
                          ? (widget.bookMap['chapter_list'][index + 1]
                              ['start_time'])
                          : widget.bookMap['total_length'];

                  int chapterLengthInSec =
                      widget.bookMap['multi_source'] == true
                          ? chapter['length']
                          : (nextChapterStartTime - chapterStartTime);

                  String chapterLength = getTimeFromSeconds(chapterLengthInSec);
                  // var chapterLength = chapterLengthInSec;

                  int position = widget.positionData.inSeconds;
                  //  chapterIndex = getChapterIndex();

                  int? chapterProgressInSec;
                  chapterProgressInSec = getChapterProgessInSec(
                      position: position,
                      chapterStartTime: chapterStartTime,
                      nextChapterStartTime: nextChapterStartTime,
                      chapterIndex: chapterIndex,
                      listIndex: index);

                  String? chapterProgressTime = chapterProgressInSec != null
                      ? getTimeFromSeconds(chapterProgressInSec)
                      : null;

                  var progressPercent = chapterProgressInSec != null
                      ? ((chapterProgressInSec / chapterLengthInSec) * 100)
                          .round()
                      : null;

                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (widget.bookMap['multi_source'] == true) {
                              //Change chapter index
                              setState(() {
                                chapterIndex = index;
                              });

                              //Change Player Audio Source
                              changePlayerAudioSource(chapter: chapter);

                              //Change audio index in Hive
                              saveAudioIndexInHive(index);
                            } else {
                              widget._player.seek(
                                  Duration(seconds: chapter['start_time']));
                            }
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
                              if (progressPercent != null &&
                                  widget._player.playing)
                                Expanded(
                                    child: Column(
                                  // mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Lottie.asset(
                                          'assets/book_read_animation.json'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Lottie.asset(
                                              repeat: true,
                                              'assets/music_animation_1.json'),
                                          Lottie.asset(
                                              repeat: true,
                                              'assets/music_animation_1.json'),
                                        ],
                                      ),
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
          ),
        ],
      ),
    );
  }

  int? getChapterProgessInSec(
      {required int position,
      required chapterStartTime,
      required nextChapterStartTime,
      required chapterIndex,
      required listIndex}) {
    int? chapterProgressInSec;
    if (widget.bookMap['multi_source'] == true) {
      if (chapterIndex == listIndex) {
        chapterProgressInSec = position;
      }
    } else {
      chapterProgressInSec =
          (position >= chapterStartTime && position < nextChapterStartTime
              ? (position - chapterStartTime)
              : null) as int?;
    }
    return chapterProgressInSec;
  }

  int getChapterIndex() {
    var box = Hive.box('user_data');
    var bookID = widget.bookMap['id'];

    var chapterIndex = box.get(bookID)?['index'] ?? 0;

    return chapterIndex;
  }

  String getTimeFromSeconds(int seconds) {
    int minutes = seconds ~/ 60; // Get the whole number of minutes
    int remainingSeconds = seconds % 60; // Get the remaining seconds

    // Format the minutes and seconds with leading zeros if needed
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }

  void changePlayerAudioSource({required Map chapter}) {
    widget._player.setAudioSource(LockCachingAudioSource(
        Uri.parse(
          // Supports range requests:
          chapter['audio_source'],
        ),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: '1',
          // Metadata to display in the notification:
          album: "Bangla Audio Book",
          title: chapter['title'],
          artUri: null,
        )));
  }

  void saveAudioIndexInHive(int index) {
    var box = Hive.box('user_data');
    var bookID = widget.bookMap['id'];

    box.put(bookID, {'index': index});
  }
}

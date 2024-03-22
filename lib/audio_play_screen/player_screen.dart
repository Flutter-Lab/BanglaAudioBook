import 'package:audio_session/audio_session.dart';
import 'package:bangla_audio_book/audio_play_screen/components/timer_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'common.dart';
import 'components/chapter_list/chapter_list.dart';
import 'components/control_buttons/control_buttons.dart';
import 'components/control_buttons/forword_rewind.dart';

class PlayerScreen extends StatefulWidget {
  final Map bookMap;

  const PlayerScreen({super.key, required this.bookMap});

  @override
  PlayerScreenState createState() => PlayerScreenState();
}

final player = AudioPlayer();

class PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver {
  // final _player = AudioPlayer();
  // String get audioSrc => widget.bookMap['audio_src'];
  late LockCachingAudioSource _audioSource;

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  String getChapterURL(Map bookMap) {
    var box = Hive.box('user_data');
    var bookID = widget.bookMap['id'];

    var bookInfo = box.get(bookID);
    // print('Book Info :: $bookInfo');
    var index = bookInfo?['index'] ?? 0;
    // print('Index is:: $index');
    String source = bookMap['chapter_list'][index]['audio_source'];
    // print('Got Source for Multi Audio');
    return source;
  }

  Future<void> _init() async {
    bool? isMultiSource = widget.bookMap['multi_source'];

    String srcUrl = isMultiSource == true
        ? getChapterURL(widget.bookMap)
        : widget.bookMap['audio_src'];

    print('Source is: $srcUrl');

    _audioSource = LockCachingAudioSource(
        Uri.parse(
          // Supports range requests:
          srcUrl,
        ),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: '1',
          // Metadata to display in the notification:
          album: "Bangla Audio Book",
          title: widget.bookMap['title'],
          artUri: null,
        ));
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
    try {
      // Use resolve() if you want to obtain a UriAudioSource pointing directly
      // to the cache file.
      // await _player.setAudioSource(await _audioSource.resolve());
      await player.setAudioSource(_audioSource);

      

      await goToPreviousListionPosition();
      player.play();

      //Go to Previous Listen Time if has any
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  Future<void> goToPreviousListionPosition() async {
    var box = Hive.box('user_data');
    var bookID = widget.bookMap['id'];
    if (box.containsKey(bookID)) {
      print('Found Previous Position');
      late int previousPosition;

      if (widget.bookMap['multi_source'] == true) {
        var bookInfo = box.get(bookID);
        previousPosition = bookInfo['position'] ?? 0;

        print('Book in map: ${box.get(bookID)}');

        print('Previous Position in Multi : $previousPosition');
      } else {
        previousPosition = box.get(bookID);
      }

      if (previousPosition > 15) {
        int newPosition = previousPosition - 10;
        await player.seek(Duration(seconds: newPosition));
      }
    } else {
      print('Not Found Previous Position');
    }
  }

  @override
  void dispose() async {
    // ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them

    print('Dispose is called');

    //Save Current user listen time with book_id

    saveCurrentAudioPostion();
    player.dispose();
    super.dispose();
  }

  void saveCurrentAudioPostion() {
    print('TTTT');
    var box = Hive.box('user_data');
    var currentPostion = player.position.inSeconds;
    if (currentPostion > 10) {
      var bookID = widget.bookMap['id'];

      if (widget.bookMap['multi_source'] == true) {
        int index = box.get(bookID)?['index'] ?? 0;
        box.put(bookID, {
          'index': index,
          'position': currentPostion,
        });
      } else {
        box.put(bookID, currentPostion);
      }

      print(
          'New Listen Position Saved. ID: $bookID , Position: $currentPostion ');
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, double, Duration?, PositionData>(
          player.positionStream,
          _audioSource.downloadProgressStream,
          player.durationStream,
          (position, downloadProgress, reportedDuration) {
        final duration = reportedDuration ?? Duration.zero;
        final bufferedPosition = duration * downloadProgress;
        return PositionData(position, bufferedPosition, duration);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.bookMap['title']),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  imageUrl: widget.bookMap['image'],
                ),
              ),
            ),
            // Display play/pause button and volume/speed sliders.
            ControlButtons(player),
            // Display seek bar. Using StreamBuilder, this widget rebuilds
            // each time the position, buffered position or duration changes.
            Expanded(
              flex: 3,
              child: StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;

                  // print(
                  //   positionData?.duration ?? Duration.zero,
                  // );
                  return Column(
                    children: [
                      SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: player.seek,
                      ),
                      ForWordAndRewind(player: player),
                      TimerText(player: player),
                      ChapterList(
                        bookMap: widget.bookMap,
                        player: player,
                        positionData: positionData?.position ?? Duration.zero,
                      ),
                    ],
                  );
                },
              ),
            ),

            // ElevatedButton(
            //   onPressed: _audioSource!.clearCache,
            //   child: const Text('Clear cache'),
            // ),
          ],
        ),
      ),
    );
  }
}

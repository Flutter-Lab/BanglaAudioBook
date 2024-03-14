import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChapterList extends StatelessWidget {
  const ChapterList({
    super.key,
    required this.bookMap,
    required AudioPlayer player,
  }) : _player = player;

  final Map bookMap;
  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: bookMap['chapter_list'].length,
          itemBuilder: (context, index) {
            var chapter = bookMap['chapter_list'][index];
            return Card(
              child: ListTile(
                  onTap: () {
                    _player.seek(Duration(seconds: chapter['start_time']));
                  },
                  title: Text('${chapter['title']}')),
            );
          }),
    );
  }
}

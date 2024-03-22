import 'package:bangla_audio_book/data/data.dart';
import 'package:flutter/material.dart';

import 'components/book_card.dart';
import 'components/setting_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [SettingButton()],
        centerTitle: true,
        title: const Text('Bangla Audio Book'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            // flex: 1,
            child: GridView.builder(
                itemCount: bookList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 1 / 2),
                itemBuilder: (context, index) {
                  Map book = bookList[index];
                  return BookCard(book: book);
                }),
          ),
          // Spacer(
          //   flex: 1,
          // )
        ],
      ),
    );
  }
}

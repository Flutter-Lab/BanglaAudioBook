import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../book_card.dart';

class BooksListView extends StatelessWidget {
  const BooksListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        // shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: bookList.length,
        itemBuilder: (context, index) {
          Map book = bookList[index];
          return BookCard(book: book);
        });
  }
}

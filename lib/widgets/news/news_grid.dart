import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/news_block.dart';
import './news_item.dart';

class NewsGrid extends StatelessWidget {
  final bool showMoreFavs;

  NewsGrid(this.showMoreFavs);

  @override
  Widget build(BuildContext context) {
    final newsData = Provider.of<NewsBlocks>(context);
    final news = showMoreFavs ? newsData.orderByFavorites : newsData.orderByDatetime;
    return news.isEmpty
        ? const Center(
            child: Text(
              'There is no news here yet.',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: news.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: news[i],
              child: NewsItem(),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
  }
}

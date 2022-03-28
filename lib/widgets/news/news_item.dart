import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/screen_arguments.dart';

import '../../helpers/dbhelper.dart';
import '../../providers/news_block.dart';
import '../../screens/edit_news_screen.dart';
import '../../screens/news_detail_page.dart';

class NewsItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> getUser() async {
      final userEmail = ModalRoute.of(context)!.settings.arguments as String;
      final dbUsers = await DBHelper.getData(DataBase.users);
      return dbUsers!.firstWhere((elem) => elem['email'] == userEmail);
    }

    final newsBlockFromProvider =
        Provider.of<NewsBlock>(context, listen: false);
    // final newsFromProvider = Provider.of<NewsBlocks>(context, listen: false);

    return FutureBuilder(
      future: getUser(),
      builder: (ctx, snapShot) {
        return snapShot.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GridTile(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        NewsDetailPage.routeName,
                        arguments: ScreenArgumentsForDetailPage(
                          newsBlockFromProvider,
                          (snapShot.data as Map)['email'],
                        ),
                      );
                    },
                    child: Hero(
                      tag: newsBlockFromProvider.id!,
                      child: Image.file(
                        newsBlockFromProvider.image!,
                        // File((snapShot.data as Map)['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  footer: GridTileBar(
                    backgroundColor: Colors.black87,
                    leading: Consumer<NewsBlock>(
                      builder: (ctx, news, _) => Row(
                        children: [
                          IconButton(
                            icon:
                                news.isFavorite((snapShot.data as Map)['email'])
                                    ? const Icon(Icons.favorite)
                                    : const Icon(Icons.favorite_border),
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: () {
                              news.tapOnIsFavorite(
                                  (snapShot.data as Map)['email']);
                            },
                          ),
                          Text(
                            news.usersWhoAddToFavorite.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      newsBlockFromProvider.title,
                      textAlign: TextAlign.center,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: (snapShot.data as Map)['email'] ==
                              newsBlockFromProvider.author
                          ? () {
                              Navigator.of(context).pushNamed(
                                EditNewsScreen.routeName,
                                arguments: ScreenArguments(
                                  newsBlockFromProvider.id,
                                  (snapShot.data as Map)['email'],
                                ),
                              );
                            }
                          : null,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              );
      },
    );
  }
}

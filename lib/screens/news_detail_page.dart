import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/helpers/dbhelper.dart';
import 'package:test_proj/models/screen_arguments.dart';
import 'package:test_proj/screens/edit_news_screen.dart';

import '../providers/news_block.dart';

var _enteredMessage = '';

class NewsDetailPage extends StatelessWidget {
  static const routeName = '/news-detail';

  Future<Map<String, dynamic>> getUser(
      BuildContext ctx, String userEmail) async {
    final dbUsers = await DBHelper.getData(DataBase.users);
    return dbUsers!.firstWhere((elem) => elem['email'] == userEmail);
  }

  var _isInit = true;

  void _tapOnButton() {
    _isInit = false;
  }

  void _sendAComment() {}

  @override
  Widget build(BuildContext context) {
    final screenArguments = ModalRoute.of(context)!.settings.arguments
        as ScreenArgumentsForDetailPage;
    final newsPage = screenArguments.newsPage;
    final email = screenArguments.email;

    return FutureBuilder(
      future: getUser(context, newsPage.author),
      builder: (ctx, snapShot) {
        return snapShot.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                appBar: AppBar(
                  title: const Text('News entry'),
                  actions: [
                    if (email == newsPage.author)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            EditNewsScreen.routeName,
                            arguments: ScreenArguments(
                              newsPage.id,
                              (snapShot.data as Map)['email'],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: FileImage(
                            File((snapShot.data as Map)['image']),
                          ),
                        ),
                        title: Text((snapShot.data as Map)['userName']),
                        subtitle: Text(newsPage.date.toString()),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              newsPage.title,
                              style: const TextStyle(fontSize: 24),
                            ),
                            Text(newsPage.body),
                          ],
                        ),
                      ),
                      Hero(
                        tag: newsPage.id!,
                        child: Image.file(
                          newsPage.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      TappingIsFavorite(
                          newsPage, email),
                      const Divider(),
                      Text('${newsPage.commentUser.length} comments'),
                      const SizedBox(height: 10),
                      if (newsPage.commentUser.isEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _isInit ? 3 : newsPage.commentUser.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: CircleAvatar(),
                            title: Text('comment'),
                            subtitle: Text('datetime comment'),
                          ),
                        ),
                      if (newsPage.commentUser.length > 3 && _isInit)
                        TextButton(
                          child: Text('Show more...'),
                          onPressed: () {},
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SendAComment(),
                            IconButton(
                              color: Theme.of(context).primaryColor,
                              icon: const Icon(Icons.send),
                              onPressed: _enteredMessage.trim().isEmpty
                                  ? null
                                  : _sendAComment,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}

class SendAComment extends StatefulWidget {
  @override
  State<SendAComment> createState() => _SendACommentState();
}

class _SendACommentState extends State<SendAComment> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: _controller,
        autocorrect: true,
        textCapitalization: TextCapitalization.sentences,
        enableSuggestions: true,
        decoration: const InputDecoration(
          label: Text('Send a comment...'),
        ),
        onChanged: (value) {
          setState(() {
            _enteredMessage = value;
          });
        },
      ),
    );
  }
}

// НУ И КОСТЫЛЬ..........
class TappingIsFavorite extends StatefulWidget {
  const TappingIsFavorite(
    this.newsPage,
    this.email,
  );

  final NewsBlock newsPage;
  final String email;

  @override
  State<TappingIsFavorite> createState() => _TappingIsFavoriteState();
}

class _TappingIsFavoriteState extends State<TappingIsFavorite> {
  @override
  Widget build(BuildContext context) {
    print(widget.email);
    return Row(
      children: [
        IconButton(
          icon: widget.newsPage.isFavorite(widget.email)
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border),
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            setState(() {
              widget.newsPage.tapOnIsFavorite(widget.email);
            });
          },
        ),
        Text(
          widget.newsPage.usersWhoAddToFavorite.length.toString(),
        ),
      ],
    );
  }
}

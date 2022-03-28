import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../helpers/dbhelper.dart';
import 'comment_user.dart';

class NewsBlock with ChangeNotifier {
  final String? id;
  final String title;
  final String body;
  final DateTime? date;
  String author;
  File? image;
  List<String> usersWhoAddToFavorite;
  List<CommentUser> commentUser;

  NewsBlock({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.author,
    required this.image,
    required this.usersWhoAddToFavorite,
    required this.commentUser,
  });
// Id - идентификатор новости
// Title - заголовок блока
// Image - обложка блока
// Body - текстовое содержимое блока
// Comments - Массив пользовательских комментариев к новости
// Favorite - Массив пользователей, оценивших запись,
// Date - Дата публикации

  String userInBlock(String email) {
    return usersWhoAddToFavorite.firstWhere((elem) => elem == email, orElse: (() => ''));
  }
  bool isFavorite(String email) {
    return userInBlock(email).isNotEmpty;
  }
  Future<void> tapOnIsFavorite(String email) async {
    if (isFavorite(email)) {
      usersWhoAddToFavorite.remove(userInBlock(email));
    } else {
      usersWhoAddToFavorite.add(email);
    }
    await DBHelper.update(
      id!,
      'usersWhoAddToFavorite = ?',
      [jsonEncode(usersWhoAddToFavorite)],
    );
    notifyListeners();
  }
}

class NewsBlocks with ChangeNotifier {
  List<NewsBlock> _items = [];

  List<NewsBlock> get items {
    return [..._items];
  }

  NewsBlock findById(String id) {
    return _items.firstWhere((elem) => elem.id == id);
  }

  List<NewsBlock> get orderByDatetime {
    final itemsSort = items;
    itemsSort.sort((b, a) => a.date!.compareTo(b.date!));
    return [...itemsSort];
  }

  List<NewsBlock> get orderByFavorites {
    final itemsSort = orderByDatetime;
    itemsSort.sort((b, a) => a.usersWhoAddToFavorite.length
        .compareTo(b.usersWhoAddToFavorite.length));
    return [...itemsSort];
  }

  Future<void> fetchAndSetOrders([bool filterByMoreFavs = false]) async {
    final dbNews = await DBHelper.getData(DataBase.news);
    if (dbNews == null) {
      return;
    }
    final List<NewsBlock> loadedNews = [];
    for (var elem in dbNews) {
      final commentaries =
          List<CommentUser>.from(jsonDecode(elem['commentUser'])); // its maybe doesn't work.
      final usersFavs =
          List<String>.from(jsonDecode(elem['usersWhoAddToFavorite']));
      loadedNews.add(
        NewsBlock(
          id: elem['id'],
          title: elem['title'],
          image: File(elem['image']),
          body: elem['body'],
          date: DateTime.parse(elem['date']),
          author: elem['author'],
          commentUser: commentaries,
          usersWhoAddToFavorite: usersFavs,
        ),
      );
    }
    _items = loadedNews;
    notifyListeners();
  }

  Future<void> addNews(NewsBlock newsBlock) async {
    final newNews = NewsBlock(
      id: const Uuid().v4(),
      title: newsBlock.title,
      image: newsBlock.image,
      body: newsBlock.body,
      date: DateTime.now(),
      author: newsBlock.author,
      commentUser: [], // to JSON file
      usersWhoAddToFavorite: [], // to JSON file
    );
    final commentUserToJson = jsonEncode(newNews.commentUser); // hmm..
    final usersFavsToJson = jsonEncode(newNews.usersWhoAddToFavorite);
    await DBHelper.insert(DataBase.news, {
      'id': newNews.id!,
      'title': newsBlock.title,
      'image': newsBlock.image!.path,
      'body': newsBlock.body,
      'date': DateTime.now().toIso8601String(),
      'author': newsBlock.author,
      'commentUser': commentUserToJson,
      'usersWhoAddToFavorite': usersFavsToJson,
    });
    _items.add(newNews);
    notifyListeners();
  }

  Future<void> updateNews(String id, NewsBlock newsBlock) async {
    final newsIndex = _items.indexWhere((elem) => elem.id == id);
    if (newsIndex >= 0) {
      final newNews = NewsBlock(
        id: id,
        title: newsBlock.title,
        image: newsBlock.image,
        body: newsBlock.body,
        date: DateTime.now(),
        author: newsBlock.author,
        commentUser: newsBlock.commentUser,
        usersWhoAddToFavorite: newsBlock.usersWhoAddToFavorite,
      );
      await DBHelper.update(id, 'title = ?, image = ?, body = ?', [
        newsBlock.title,
        newsBlock.image!.path,
        newsBlock.body,
      ]);
      _items[newsIndex] = newNews;
      notifyListeners();
    } else {
      print('...');
    }
  }
}

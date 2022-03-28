import 'package:test_proj/providers/news_block.dart';

class ScreenArguments {
  final String? newsId;
  final String email;

  ScreenArguments(
    this.newsId,
    this.email,
  );
}

class ScreenArgumentsForDetailPage {
  final NewsBlock newsPage;
  final String email;

  ScreenArgumentsForDetailPage(
    this.newsPage,
    this.email,
  );
}

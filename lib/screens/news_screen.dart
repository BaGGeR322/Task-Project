import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/screen_arguments.dart';
import '../screens/edit_news_screen.dart';
import '../widgets/news/news_grid.dart';
import '../providers/news_block.dart';

enum FilterOptions {
  Favorites,
  Datetime,
}

class NewsScreen extends StatefulWidget {
  static const routeName = '/news';

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  var _orderByFavorites = false;
  var _isInit = true;
  var _isLoading = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<NewsBlocks>(context)
          .fetchAndSetOrders()
          .then((_) => setState(() {
                _isLoading = false;
              }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final emailUser = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(
              EditNewsScreen.routeName,
              arguments: ScreenArguments(
                null,
                emailUser,
              ),
            );
          },
        ),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _orderByFavorites = true;
                } else {
                  _orderByFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Order by favorites'),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text('Order by datetime'),
                value: FilterOptions.Datetime,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NewsGrid(_orderByFavorites),
    );
  }
}

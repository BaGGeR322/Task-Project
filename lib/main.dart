import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user.dart';
import './providers/news_block.dart';
import './screens/news_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_news_screen.dart';
import './screens/news_detail_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserLogInOrSignUp(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsBlocks(),
        ),
      ],
      child: MaterialApp(
        title: 'Task project',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthScreen(),
        routes: {
          NewsScreen.routeName: (ctx) => NewsScreen(),
          EditNewsScreen.routeName: (ctx) => EditNewsScreen(),
          NewsDetailPage.routeName: (ctx) => NewsDetailPage(),
        },
      ),
    );
  }
}

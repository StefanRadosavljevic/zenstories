import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:zenstories/pages/details_page.dart';
import 'package:zenstories/pages/tabbar.dart';

import 'package:zenstories/providers/articles.dart';
import 'package:zenstories/providers/categories.dart';
import 'package:zenstories/providers/user.dart';

class FlutterNewsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final articlesChangeNotifier = ChangeNotifierProvider.value(
      value: ArticlesProvider(),
    );
    final categoriesChangeNotifier = ChangeNotifierProvider.value(
      value: CategoriesProvider(),
    );
    final userChangeNotifier = ChangeNotifierProvider.value(
      value: UserProvider(),
    );
    return MultiProvider(
      providers: [
        articlesChangeNotifier,
        categoriesChangeNotifier,
        userChangeNotifier,
      ],
      child: MaterialApp(
        title: 'News App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        initialRoute: Tabbar.routeName,
        routes: {
          Tabbar.routeName: (ctx) => Tabbar(),
          DetailsPage.routeName: (ctx) => DetailsPage(),
        },
      ),
    );
  }
}

void main() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  return runApp(FlutterNewsApp());
}

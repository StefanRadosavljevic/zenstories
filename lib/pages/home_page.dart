import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_news_app/widgets/articles.dart';
import 'package:flutter_news_app/widgets/categories.dart';

import 'package:flutter_news_app/providers/articles.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    var articlesProvider = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ZenStories',
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: articlesProvider.refresh,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Categories(),
              Articles(),
            ],
          ),
        ),
      ),
    );
  }
}

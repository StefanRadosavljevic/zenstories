import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'dart:math' as Math;

import 'package:zenstories/providers/articles.dart';
import 'package:zenstories/providers/categories.dart';
import 'package:zenstories/providers/user.dart';

import 'package:zenstories/widgets/article_card_item.dart';
import 'package:zenstories/widgets/article_list_item.dart';
import 'package:zenstories/widgets/article_options.dart';

import 'package:zenstories/pages/details_page.dart';
import 'package:zenstories/models/article.dart';

class Articles extends StatefulWidget {
  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  final _headlinesCount = 3;
  Map<int, Future<List<Article>>> _articlesFutures = {};
  var _isLoadingNextPage = false;

  void _readArticle(BuildContext context, int id) {
    Navigator.of(context).pushNamed(DetailsPage.routeName, arguments: id);
  }

  void _showMessage(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  void _showOptions(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ArticleOptions(
        id: id,
        bookmark: _bookmark,
        hideStory: _hideStory,
        share: _share,
        addFavorite: _addFavorite,
      ),
    );
  }

  void _bookmark(int id) {
    Navigator.of(context).pop();
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isBookmarked(id)) {
      userProvider.addBookmark(id);
      _showMessage(
        'Priča je uspešno dodata na listu sačuvanih.',
      );
    }
  }

  void _hideStory(int id) {
    Navigator.of(context).pop();
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.hideArticle(id);
    _showMessage('Priča je uspešno dodata na crnu listu. ');
  }

  void _share(int id) async {
    Navigator.of(context).pop();
    var article = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    ).findById(id);
    await Share.share(
      article.title,
      subject: 'Article',
    );
  }

  void _addFavorite(int id) {
    Navigator.of(context).pop();
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isFavorite(id)) {
      userProvider.addFavorite(id);
      _showMessage(
        'Priča je dodata u listu omiljenih priča.',
      );
    } else {
      _showMessage('Priča je već u listi vaših omiljenih priča.');
    }
  }

  Widget _buildArticlesCarousel({
    List<Article> data,
    Function onPressed,
    Function onLongPress,
  }) {
    var carouselCount = Math.min(_headlinesCount, data.length);
    var articles = data.sublist(0, carouselCount);
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.horizontal,
        itemCount: carouselCount,
        itemBuilder: (_, index) {
          var cardItem = articles[index];
          return ArticleCardItem(
            id: cardItem.id,
            title: cardItem.title,
            category: cardItem.category,
            image: cardItem.banner,
            onPress: onPressed,
            onLongPress: onLongPress,
          );
        });
  }

  Widget _buildArticlesList({
    List<Article> data,
    Function onPressed,
    Function onLongPress,
  }) {
    var carouselCount = Math.min(_headlinesCount, data.length);
    var articles = data.sublist(carouselCount);
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: articles.length,
        itemBuilder: (_, index) {
          var cardItem = articles[index];
          return Container(
            height: 100,
            child: ArticleListItem(
              id: cardItem.id,
              title: cardItem.title,
              category: cardItem.category,
              image: cardItem.banner,
              onPress: onPressed,
              date: cardItem.createdAt,
              onLongPress: onLongPress,
            ),
          );
        });
  }

  void _nextPage() async {
    var articlesProvider = Provider.of<ArticlesProvider>(
      context,
      listen: false,
    );
    setState(() {
      _isLoadingNextPage = true;
    });
    await articlesProvider.nextPage();
    setState(() {
      _isLoadingNextPage = false;
    });
  }

  Future<List<Article>> _buildArticlesFuture(int categoryId) {
    if (_articlesFutures[categoryId] != null) {
      return _articlesFutures[categoryId];
    }
    var articlesProvider = Provider.of<ArticlesProvider>(context);
    var articlesFuture = articlesProvider.fetchArticles(categoryId);
    _articlesFutures[categoryId] = articlesFuture;
    return articlesFuture;
  }

  @override
  Widget build(BuildContext context) {
    var articlesProvider = Provider.of<ArticlesProvider>(context);
    var categoriesProvider = Provider.of<CategoriesProvider>(context);
    if (categoriesProvider.currentCategory == null) {
      return CircularProgressIndicator();
    }

    return FutureBuilder(
      future: _buildArticlesFuture(categoriesProvider.currentCategory.id),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : snapshot.hasError
                  ? Text(snapshot.error)
                  : Column(
                      children: <Widget>[
                        Container(
                          height: 300,
                          margin: const EdgeInsets.only(left: 8.0),
                          child: _buildArticlesCarousel(
                              data: articlesProvider.articles,
                              onPressed: (id) => _readArticle(ctx, id),
                              onLongPress: (id) => _showOptions(ctx, id)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildArticlesList(
                              data: articlesProvider.articles,
                              onPressed: (id) => _readArticle(ctx, id),
                              onLongPress: (id) => _showOptions(ctx, id)),
                        ),
                        SizedBox(height: 20),
                        if (articlesProvider.articles.length == 0)
                          Container()
                        else if (!_isLoadingNextPage)
                          FlatButton(
                            child: Text('Učitaj još'),
                            onPressed: _nextPage,
                          )
                        else
                          CircularProgressIndicator(),
                        SizedBox(height: 20),
                      ],
                    ),
    );
  }
}

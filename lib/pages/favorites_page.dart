import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zenstories/providers/user.dart';
import 'package:zenstories/providers/articles.dart';

import 'package:zenstories/widgets/article_list_item.dart';

import 'package:zenstories/pages/details_page.dart';

class FavoritesPage extends StatelessWidget {
  void _showMessage(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  _deleteFavorite(BuildContext context, int id) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.deleteFavorite(id);
    _showMessage(
      context,
      'Priča je uspešno uklonjena sa liste omiljenih priča.',
    );
  }

  void _readArticle(BuildContext context, int id) {
    Navigator.of(context).pushNamed(DetailsPage.routeName, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    var articlesProvider = Provider.of<ArticlesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
          ),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              elevation: 0,
              title: Text(
                'Favoriti',
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
            Consumer<UserProvider>(
              builder: (_, userProvider, child) =>
                  userProvider.favorites != null &&
                          userProvider.favorites.length == 0
                      ? Container()
                      : ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemBuilder: (_, index) {
                            var article = articlesProvider.findById(
                              userProvider.favorites[index],
                            );
                            return Dismissible(
                              key: ValueKey(article.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _deleteFavorite(
                                context,
                                article.id,
                              ),
                              background: Container(
                                  color: Colors.red,
                                  child: Container(
                                    padding: EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  )),
                              child: ArticleListItem(
                                category: article.category,
                                id: article.id,
                                image: article.banner,
                                title: article.title,
                                onPress: (id) => _readArticle(context, id),
                                onLongPress: () {},
                                date: article.createdAt,
                              ),
                            );
                          },
                          itemCount: userProvider.favorites.length,
                        ),
            )
          ],
        ),
      ),
    );
  }
}

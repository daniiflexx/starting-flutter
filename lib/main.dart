import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
        ),
        home: MyHomePage(),
      ),
    );
  }
}
class Article {
  String title;
  String author;
  String description;
  String body;

   Article({this.title = '', this.author = '', this.description = '', this.body = ''});
}

class MyAppState extends ChangeNotifier {
  List<Article> articles = [];
  var favorites = <Article>[];
  
  void addArticle(Article newArticle) {
    articles.add(newArticle);
    notifyListeners();
  }
  
  void toggleFavorite(Article current) {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  void removeArticle(Article article) {
    articles.remove(article);
    favorites.remove(article);
    notifyListeners();
  }
  MyAppState() {
    addArticle(Article(
      title: 'Article 1',
      description: 'Description 1',
      body: 'Body 1',
      author: 'Author 1',
    ));
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = NewArticlePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth > 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add),
                      label: Text('Add article'),
                    )
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class NewArticlePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController authorController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Article'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextFormField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Body',
                labelStyle: Theme.of(context).textTheme.headlineSmall,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  var appState = context.read<MyAppState>();
                  appState.addArticle(Article(
                    title: titleController.text,
                    description: descriptionController.text,
                    body: bodyController.text,
                    author: authorController.text,
                  ));
                  // Clear the text fields
                  titleController.clear();
                  descriptionController.clear();
                  bodyController.clear();
                  authorController.clear();
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.secondary,
                ),
                foregroundColor: WidgetStateProperty.all(
                  Colors.white,
                ),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );  
    } else {
      return ListView.builder(
        itemCount: appState.favorites.length,
        itemBuilder: (context, index) {
          var article = appState.favorites[index];

          IconData icon;
          if (appState.favorites.contains(article)) {
            icon = Icons.favorite;
          } else {
            icon = Icons.favorite_border;
          }
          return ArticleCard(article: article);
        },
      );
    }
  }
}
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var articles = appState.articles;

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        var article = articles[index];

        IconData icon;
        if (appState.favorites.contains(article)) {
          icon = Icons.favorite;
        } else {
          icon = Icons.favorite_border;
        }
        return ArticleCard(article: article);
      },
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;

  ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    IconData icon;
    if (appState.favorites.contains(article)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Card(
      child: ListTile(
        title: Text(article.title),
        subtitle: Text(article.author),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(icon),
              onPressed: () {
                appState.toggleFavorite(article);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.removeArticle(article);
              },
            ),
          ],
        ),
      ),
    );
  }
}
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        // ↓ Make the following change.
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
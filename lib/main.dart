import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'history_tab.dart';
import 'article_open.dart';
import 'article_model.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { //MyApp is the main widget in the app that creates the MaterialApp widget, which is the root of the widget tree.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'In a Jiffy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {//MyHomePage widget is the stateful widget that displays the list of news articles in a ListView. It fetches the data from the NewsAPI using the fetchNews() function and stores it in the articles list.
  final String title;
  final String urlToImage;
  final String description;
  final String content;
  MyHomePage(
      {required Key key,
      required this.title,
      required this.urlToImage,
      required this.description,
        required this.content,})
      : super(key: key);

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  List<ArticleModel> articles = [];
  late SharedPreferences prefs =
      SharedPreferences.getInstance() as SharedPreferences;
  bool isLoading = true;

  String selectedCountry = 'in';
  final countries = [
    {'name': 'in', 'display': 'India'},
    {'name': 'us', 'display': 'United States'},
    {'name': 'au', 'display': 'Australia'},
    {'name': 'gb', 'display': 'United Kingdom'},
    // {'name': 'science', 'display': 'Science'},
    // {'name': 'sports', 'display': 'Sports'},
    // {'name': 'technology', 'display': 'Technology'},
  ];
//tab
  late TabController _tabController;
  final categories = [
    {'name': 'general', 'display': 'General'},
    {'name': 'technology', 'display': 'Technology'},
    {'name': 'business', 'display': 'Business'},
    {'name': 'science', 'display': 'Science'},
    {'name': 'entertainment', 'display': 'Entertainment'},
    {'name': 'health', 'display': 'Health'},
    {'name': 'sports', 'display': 'Sports'},
      ];

  @override
  void initState() {
    super.initState();
//tab
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          isLoading = true;
          articles.clear();
          selectedCategory = categories[_tabController.index]['name']!;
        });
        fetchNews();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => fetchNews());
    SharedPreferences.getInstance().then((prefs) {
      this.prefs = prefs;
      loadHistory();
    });
  }

  String selectedCategory = 'general';

  //The user's history is loaded using the loadHistory() function, which retrieves the list of viewed articles from SharedPreferences and updates the viewed property of each article accordingly.
  void loadHistory() {
    final history = prefs.getStringList('history') ?? [];
    if (articles != null) {
      setState(() {//When the articles list is updated, the setState() function is called, which triggers a rebuild of the widget tree, causing the ListView to update with the latest data.
        articles.forEach((article) {
          if (history.contains(article.title)) {
            article.viewed = true;
            history.remove(article.title);
          } else {
            article.viewed = false;
          }
        });
      });
      prefs.setStringList('history', history);
    }
  }

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse(
            'https://newsapi.org/v2/top-headlines?country=$selectedCountry&category=$selectedCategory&apiKey=7a8ffad608c448bb801c400f572f1eeb'
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isLoading = false;
        articles = List<Map<String, dynamic>>.from(data['articles'] ?? [])
            .where((article) => article != null)
            .map((article) => ArticleModel.fromJson(article))
            .toList();
        // print(articles.length);
        // articles.forEach((element) {
        //   print(element.toString());
        // });
        loadHistory();
      });
    }
  }

  //When the user taps on an article, the addToHistory() function is called, which adds the article's URL to the user's history using SharedPreferences.
  void addToHistory(String url) {
    final history = prefs.getStringList('history') ?? [];
    final uniqueUrls = Set<String>.from(history);
    if (uniqueUrls.contains(url)) return;
    uniqueUrls.add(url);
    prefs.setStringList('history', uniqueUrls.toList());
    setState(() {
      articles.forEach((article) {
        if (article.url == url) {
          article.viewed = true;
        }
      });
    });
  }

  void clearHistory() {
    prefs.remove('history');
    prefs.remove('history');
    setState(() {
      articles.forEach((article) {
        article.viewed = false;
      });
    });
  }

  //The refreshNews() function is called when the user pulls down the ListView to refresh the news articles.
  Future<void> refreshNews() async {
    await fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(//The AppBar displays the app's title and a history button that takes the user to the HistoryPage widget.
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
          child: Text('$selectedCountry'.toUpperCase(),
            style: TextStyle(fontSize: 25.0,
                fontWeight: FontWeight.bold),),
        ),
        title: Text(widget.title),
        centerTitle: true,
        //backgroundColor: Colors.blue[900],
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Colors.red, Colors.black])),
          ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 15, 120, 5),
          //   child: Text('$selectedCountry'.toUpperCase(),
          //   style: TextStyle(fontSize: 20.0,
          //   fontWeight: FontWeight.bold),),
          // ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return countries
                  .map(
                    (countries) => PopupMenuItem<String>(
                  value: countries['name'],
                  child: Text(countries['display']!),
                ),
              )
                  .toList();
            },
            onSelected: (countries) {
              setState(() {
                selectedCountry = countries!;
                isLoading = true;
                articles.clear();
              });
              fetchNews();
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
              if (result == true) {
                clearHistory();
              }
            },
          ),
        ],
        //tabbar
        bottom: TabBar(
          isScrollable:true,
          controller: _tabController,
          tabs: categories
              .map(
                (category) => Tab(
              text: category['display']!,
            ),
          )
              .toList(),
        ),
      ),
      body: (isLoading)
          ? Center(child: CircularProgressIndicator())
          : ScrollWrapper(
            builder: (context,properties) {
              return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return InkWell(
                      onTap: () {//The Card widget displays each news article's details, including its title, image, and description. When the user taps on the card, the onTap() function is called, which takes the user to the ArticlePage widget where the article's details are displayed in detail.
                        addToHistory(article.title);
                        //addToHistory(_getHoursPassed(article.publishedAt));
                        //addToHistory(_getHoursPassed(article.publishedAt));
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ArticlePage(
                              article: article.toJson(),
                              key: ValueKey('articlePage')),
                        ));
                      },
                      child: Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: EdgeInsets.all(12.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 7.0,
                                  ),
                                ]),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                article.urlToImage.isNotEmpty
                                    ? //image
                                    Container(
                                        height: 200.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //     image:
                                          //         NetworkImage(article.urlToImage),
                                          //     fit: BoxFit.cover),
                                          borderRadius: BorderRadius.circular(12.0),

                                        ),
                                      child: Image.network(article.urlToImage,
                                      errorBuilder: (context, obj, err){
                                        return Image.asset('assets/noimage.png');
                                      },),
                                      )
                                    : Container(
                                        height: 200.0,
                                        width: double.infinity,

                                        decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //     image: AssetImage(
                                          //         'assets/inajiffynew.png'),
                                          //     fit: BoxFit.cover),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                  child: Image.asset('assets/noimage.png'),
                                      ),
                                // CachedNetworkImage(
                                //   imageUrl: article.urlToImage,
                                //   placeholder: (context, url) => CircularProgressIndicator(),
                                //   errorWidget: (context, url, error) => Icon(Icons.error),
                                // ),
                                SizedBox(height: 8.0),
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                // ElevatedButton(
                                //   onPressed: () async {
                                //     if (await canLaunch(article.url)) {
                                //       await launch(article.url);
                                //     } else {
                                //       throw 'Could not launch ${article.url}';
                                //     }
                                //   },
                                //   child: Text('Read Full Story'),
                                // ),
                                Text(
                                  _getHoursPassed(article.publishedAt) is String
                                      ? _getHoursPassed(article.publishedAt)
                                      : '${_getHoursPassed(article.publishedAt)} hours ago',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
            }
          ),
    );

  }
}

dynamic _getHoursPassed(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Get the difference between the current time and the article's publish time
  Duration difference = DateTime.now().difference(date);
  if (difference.inHours > 24 && difference.inHours < 48) {
    return 'Yesterday';
  } else {
    // Convert the duration to hours and return the result as an integer
    return difference.inHours;
  }
}


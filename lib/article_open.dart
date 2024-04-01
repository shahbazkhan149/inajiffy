import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';


class ArticlePage extends StatefulWidget {
  final Map<String, dynamic> article;
  ArticlePage({required this.article, Key? key}) : super(key: key);
  @override
  _ArticlePageState createState() => _ArticlePageState();
}
class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full story:  ${widget.article['author']}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Colors.blue, Colors.black])),
        ),
        actions: [
          IconButton(onPressed: () {
            Share.share('${widget.article['url']}');
          },
              icon: Icon(Icons.share))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.article['urlToImage'].isNotEmpty
                ? //image
            Container(
              height: 200.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.network(
                widget.article['urlToImage'],
                errorBuilder: (context, obj, err) {
                  return Image.asset('assets/noimage.png');
                },
              ),
            )
                : Container(
              height: 200.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.asset('assets/noimage.png'),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.article['title'],
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.article['description'],
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getHoursPassed(widget.article['publishedAt']) is String
                    ? 'News from ${_getHoursPassed(widget.article['publishedAt'])}'
                    : 'News from ${_getHoursPassed(widget.article['publishedAt'])} hours ago',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(widget.article['url'])) {
                    await launch(widget.article['url']);
                  } else {
                    throw 'Could not launch ${widget.article['url']}';
                  }
                },
                child: Text('Read Full Story'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
dynamic _getHoursPassed(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Get the difference between the current time and the article's publish time
  Duration difference = DateTime.now().difference(date);
  if(difference.inHours>24 && difference.inHours<48){
    return 'Yesterday';
  }
  else {
    // Convert the duration to hours and return the result as an integer
    return difference.inHours;
  }
}

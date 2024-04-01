import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late SharedPreferences prefs;
  List<String> _history = [];
  List<String> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        prefs = value;
        _history = prefs.getStringList('history') ?? [];
        _filteredHistory = _history;
      });
    });
  }

  void clearHistory() {
    prefs.remove('history');
    setState(() {
      _history.clear();
      _filteredHistory.clear();
    });
  }

  void _filterHistory(String query) {
    setState(() {
      _filteredHistory = _history
          .where((title) => title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _history = prefs.getStringList('history') ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Colors.green, Colors.black])),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Clear history'),
                    content: Text('Are you sure you want to clear your news history?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Clear'),
                        onPressed: () {
                          clearHistory();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: _HistorySearchDelegate(_history, _filterHistory));
              },
            ),
          ),
        ],
      ),
      body: ScrollWrapper(
        builder: (context,properties) {
          return ListView.builder(
            itemCount: _filteredHistory.length,
            itemBuilder: (context, index) {


              final title = _filteredHistory[index];
              final DateTime now = DateTime.now();
              final DateFormat formatter = DateFormat('Hm');
              final String formatted = formatter.format(now);


              //print(formatted); // something like 2013-04-20
              //final publishedAt= history[index];
              return ListTile(
                title: Text(
                    title
                ),


              );
            },
          );
        }
      ),
    );
  }
}

class _HistorySearchDelegate extends SearchDelegate<String> {
  final List<String> history;
  final Function(String) filterHistory;

  _HistorySearchDelegate(this.history, this.filterHistory);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    filterHistory(query);

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(history[index]),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? history
        : history
        .where((title) =>
        title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]),
          onTap: () {
            query = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}
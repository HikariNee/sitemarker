import 'package:flutter/material.dart';
import 'package:sitemarker/operations/errors.dart';
import 'package:sitemarker/pages/page_add.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:sitemarker/operations/dbrecord_provider.dart';
import 'package:sitemarker/components/record_item.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final List<String> recordNames = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        centerTitle: true,
        elevation: 2.0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'Sitemarker',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<DBRecordProvider>(
              builder: (context, value, child) {
                for (int i = 0; i < value.records.length; i++) {
                  recordNames.add(value.records[i].name);
                }
                return IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate:
                          SitemarkerSearchDelegate(recordNames: recordNames),
                    );
                  },
                  icon: const Icon(Icons.search),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Consumer<DBRecordProvider>(
          builder: (context, value, child) {
            return value.records.isEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: value.records.length,
                    itemBuilder: (context, index) {
                      return RecordItem(record: value.records.toList()[index]);
                    },
                  )
                : Center(
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          'No records in database',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      ],
                    ),
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageAdd()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> launchURL(String url) async {
    Uri url_ = Uri.parse(url);
    if (!await launchUrl(url_)) {
      throw CouldNotLaunchBrowserException(url);
    }
  }

  showAlertDialog(BuildContext context, String url) {
    String alertText =
        'Could not launch $url. Please open a browser and type in the URL';

    AlertDialog ad = AlertDialog(
      title: const Text('Error attempting to open URL'),
      content: Text(alertText),
      actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
    );

    showDialog(context: context, builder: (BuildContext context) => ad);
  }
}

class SitemarkerSearchDelegate extends SearchDelegate {
  List<String> recordNames;

  SitemarkerSearchDelegate(
      {super.searchFieldLabel,
      super.searchFieldStyle,
      super.searchFieldDecorationTheme,
      super.keyboardType,
      super.textInputAction,
      required this.recordNames});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (String name in recordNames) {
      if (name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(name);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var record in recordNames) {
      if (record.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(record);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/event_list_tile.dart';

class SearchPage extends StatefulWidget {
  final List<Event> _events;

  SearchPage(this._events);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

//TODO fix the fact that filter effects search results...
class _SearchPageState extends State<SearchPage> {
  bool visible;
  TextEditingController t;
  List<Event> items;
  String prevToken;
  String quotes;
  @override
  void initState() {
    super.initState();
    items = List<Event>();
    visible = false;
    t = TextEditingController();
    quotes = '""';
    prevToken = quotes;
  }

  void changeList(String token) {
    prevToken = token;
    if (token.isNotEmpty) {
      String tokenLower = token.toLowerCase();
      List<Event> matchingEvents = List<Event>();
      for (Event event in widget._events) {
        String titleLower = event.title.toLowerCase();
        if (titleLower.contains(tokenLower)) {
          matchingEvents.add(event);
        }
      }
      setState(() {
        items.clear();
        items.addAll(matchingEvents);
        items.sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));
      });
    } else {
      setState(() {
        items.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Container(
              width: 280.0,
              height: 40,
              margin: EdgeInsets.all(2),
              child: TextField(
                onChanged: (value) {
                  changeList(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search Events',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: items.length == 0
                  ? Center(
                      child: Text(
                          'No results found for ${prevToken.isEmpty ? quotes : prevToken}.'))
                  : ListView.builder(
                      cacheExtent: 0,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return EventListTile(
                          items[index],
                          0xffFFFFFF
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}

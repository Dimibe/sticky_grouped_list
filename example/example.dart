import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

void main() => runApp(MyApp());

List _elements = [
  {'name': 'John', 'group': 'Team A'},
  {'name': 'Will', 'group': 'Team B'},
  {'name': 'Beth', 'group': 'Team A'},
  {'name': 'Miranda', 'group': 'Team B'},
  {'name': 'Mike', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Grouped List View Example'),
        ),
        body: StickyGroupedListView<Element, DateTime>(
          elements: _elements,
          order: StickyGroupedListOrder.ASC,
          groupBy: (Element element) =>
              DateTime(element.date.year, element.date.month, element.date.day),
          floatingHeader: true,
          groupSeparatorBuilder: (Element element) => Container(
            height: 50,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  border: Border.all(
                    color: Colors.blue[300],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${element.date.day}. ${element.date.month}, ${element.date.year}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          itemBuilder: (_, Element element) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              elevation: 8.0,
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Icon(element.icon),
                  title: Text(element.name),
                  trailing: Text('${element.date.hour}:00'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Element implements Comparable {
  DateTime date;
  String name;
  IconData icon;

  Element(this.date, this.name, this.icon);

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

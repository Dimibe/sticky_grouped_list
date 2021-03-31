import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

void main() => runApp(MyApp());

List<Element> _elements = <Element>[
  Element(DateTime(2020, 6, 24, 9, 25), 'Hello how are you?'),
  Element(DateTime(2020, 6, 24, 9, 36), 'Fine and what about you?', true),
  Element(DateTime(2020, 6, 24, 9, 39), 'I am fine too'),
  Element(DateTime(2020, 6, 25, 14, 12),
      'Hey you do you wanna go to the cinema?', true),
  Element(
      DateTime(2020, 6, 25, 14, 19), 'Yes of course when do we want to meet'),
  Element(DateTime(2020, 6, 25, 14, 20), 'Lets meet at 8 o clock', true),
  Element(DateTime(2020, 6, 25, 14, 25), 'Okay see you then :)'),
  Element(DateTime(2020, 6, 27, 18, 41),
      'Hey whats up? Can you help me real quick?'),
  Element(DateTime(2020, 6, 27, 18, 45), 'Of course  what do you need?', true),
  Element(DateTime(2020, 6, 27, 18, 47),
      'Can you send me the homework for tomorrow please?'),
  Element(
    DateTime(2020, 6, 27, 18, 48),
    'I dont understand the math questions :(',
  ),
  Element(DateTime(2020, 6, 27, 18, 56), 'Yeah sure I have send them per mail',
      true),
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
          title: Text('Chat with Peter'),
        ),
        body: Column(
          children: [
            Container(
              height: 700,
              child: StickyGroupedListView<Element, DateTime>(
                elements: _elements,
                order: StickyGroupedListOrder.DESC,
                reverse: true,
                groupBy: (Element element) => DateTime(
                    element.date.year, element.date.month, element.date.day),
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
                          color: Colors.blue[300]!,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${DateFormat.yMMMd().format(element.date)}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (_, Element element) {
                  return Align(
                    alignment: element.swapped
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 370,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        elevation: 8.0,
                        margin: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            leading: element.swapped
                                ? Text(DateFormat.Hm().format(element.date))
                                : Icon(Icons.person),
                            title: Text(element.name),
                            trailing: element.swapped
                                ? Icon(Icons.person_outline)
                                : Text(DateFormat.Hm().format(element.date)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a new message here'),
            ),
          ],
        ),
      ),
    );
  }
}

class Element implements Comparable {
  DateTime date;
  String name;
  bool swapped = false;

  Element(this.date, this.name, [this.swapped = false]);

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

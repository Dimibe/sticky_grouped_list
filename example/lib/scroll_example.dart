import 'package:flutter/material.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

/// This example shows the usage of the [StickyGroupedListView] with a
/// [GroupedItemScrollController]. The list shows 100 elements divided in ten
/// groups.
/// When clicking the [FloatingActionButton] the scroll controller jumps to the
/// index 50.
void main() => runApp(MyApp());

List<Element> _elements =
    List.generate(100, (index) => Element(index, 'Item $index', index ~/ 10));

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final itemScrollController = GroupedItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

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
          title: const Text('Grouped List View Example'),
        ),
        body: StickyGroupedListView<Element, int>(
          elements: _elements,
          groupBy: (Element element) => element.group,
          elementIdentifier: (Element element) => element.id,
          floatingHeader: true,
          groupSeparatorBuilder: _getGroupSeparator,
          itemBuilder: _getItem,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: 10,
          itemScrollController: itemScrollController,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_forward),
          onPressed: () {
            itemScrollController.jumpToElement(
              identifier: 50,
            );
          },
        ),
      ),
    );
  }

  Widget _getGroupSeparator(Element element) {
    return SizedBox(
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
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${element.group}', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Widget _getItem(BuildContext ctx, Element element) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: SizedBox(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(element.name),
        ),
      ),
    );
  }
}

class Element {
  int id;
  String name;
  int group;

  Element(this.id, this.name, this.group);
}

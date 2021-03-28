import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sticky_grouped_list/sticky_grouped_list.dart';

final List _elements = [
  {'name': 'John', 'group': 'Team A'},
  //{'name': 'Will', 'group': 'Team B'},
  // {'name': 'Beth', 'group': 'Team A'},
  {'name': 'Miranda', 'group': 'Team B'},
  // {'name': 'Mike', 'group': 'Team C'},
  {'name': 'Danny', 'group': 'Team C'},
];
void main() {
  Widget _buildGroupSeperator(dynamic element) {
    return Text(element['group']);
  }

  testWidgets('find elemets and group separators', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StickyGroupedListView(
            groupBy: (dynamic element) => element['group'],
            elements: _elements,
            order: StickyGroupedListOrder.DESC,
            groupSeparatorBuilder: _buildGroupSeperator,
            itemBuilder: (context, dynamic element) => Text(element['name']),
          ),
        ),
      ),
    );

    expect(find.text('John'), findsOneWidget);
    expect(find.text('Danny'), findsOneWidget);
    expect(find.text('Team A'), findsOneWidget);
    expect(find.text('Team B'), findsOneWidget);
    expect(find.text('Team C'), findsWidgets);
  });

  testWidgets('empty list', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StickyGroupedListView(
            groupBy: (dynamic element) => element['group'],
            elements: [],
            groupSeparatorBuilder: _buildGroupSeperator,
            itemBuilder: (context, dynamic element) => Text(element['name']),
          ),
        ),
      ),
    );
  });

  testWidgets('finds only one group separator per group',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StickyGroupedListView(
            groupBy: (dynamic element) => element['group'],
            elements: _elements,
            groupSeparatorBuilder: _buildGroupSeperator,
            itemBuilder: (context, dynamic element) => Text(element['name']),
          ),
        ),
      ),
    );
    expect(find.text("Team B"), findsOneWidget);
  });
}

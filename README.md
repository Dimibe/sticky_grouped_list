# Sticky grouped list package for Flutter.
 
A ListView with sticky headers in which list items can be grouped to sections. Based on [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list).

<img src="https://raw.githubusercontent.com/Dimibe/grouped_list/master/assets/screenshot-for-readme.png" width="300">

#### Features
* Features from scrollable_positioned_list.
* List items can be separated in groups.
* Sticky headers with floating option. 
* All fields from `ScrollablePositionedList` available.

## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 sticky_ grouped_list: ^0.1.0
 ```
 
 In your dart file, import the library:

 ```Dart
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
 ``` 
 
 Create a `StickyGroupedListView` Widget:
 
 ```Dart
  StickyGroupedListView<dynamic, String>(
    elements: _elements,
    groupBy: (element) => element['group'],
    groupSeparatorBuilder: (element) => element['group'],
    itemBuilder: (context, element) => Text(element['name']),
    order: GroupedListOrder.ASC,
  ),
```

### Parameters:
| Name | Description | Required | Default value |
|----|----|----|----|
|`elements`| A list of the data you want to display in the list | required | - |
|`groupBy` |Function which maps an element to its grouped value | required | - |
| `floatingHeader` | When set to `true` the sticky header will float over the list | no | `false` |
|`itemBuilder` / `indexedItemBuilder`| Function which returns an Widget which defines the item. `indexedItemBuilder` provides the current index as well. If both are defined `indexedItemBuilder` is preferred| yes, either of them | - |
|`groupSeparator`| Function which returns an Widget which defines the section separator | required | - |
|`separator` | A Widget which defines a separator between items inside a section | no | no separator |
| `order` | Change to `GroupedListOrder.DESC` to reverse the group sorting | no | `GroupedListOrder.ASC` |

You can also use most fields from the `ScrollablePositionedList.builder` constructor.

### Used packages: 
| Package name | Copyright | License |
|----|----|----|
|[scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list) | Copyright 2018 the Dart project authors, Inc. All rights reserved | [BSD 3-Clause "New" or "Revised" License](https://github.com/Dimibe/sticky_grouped_list/blob/master/LICENSE) |

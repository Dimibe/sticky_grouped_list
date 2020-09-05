
# Sticky grouped list package for Flutter.
[![Pub](https://img.shields.io/pub/v/sticky_grouped_list.svg)](https://pub.dev/packages/sticky_grouped_list)
![CI](https://github.com/Dimibe/sticky_grouped_list/workflows/CI/badge.svg)
 
A ListView with sticky headers in which list items can be grouped to sections. Based on [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list).

<img src="https://raw.githubusercontent.com/Dimibe/sticky_grouped_list/master/assets/new-screenshot-for-readme.png" width="300">


#### Highlight - Chat Dialog

Easy creation of chat-like dialogs.
Just set the option `reverse` to `true` and the option `order` to `StickyGroupedListOrder.DESC`. A full example can be found in the examples.
The list will be scrolled to the end in the initial state and therefore scrolling will be against redeaing direction. 

![](https://raw.githubusercontent.com/Dimibe/sticky_grouped_list/master/assets/chat.png)


#### Features
* Easy creation of chat-like interfaces. 
* List items can be separated in groups.
* For the groups an individual header can be set.
* Sticky headers with floating option. 
* All fields from `ScrollablePositionedList` available.

## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 sticky_grouped_list: ^0.3.0
 ```
 
 In your dart file, import the library:

 ```Dart
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
 ``` 
 
 Create a `StickyGroupedListView` Widget:
 
 ```Dart
  StickyGroupedListView<dynamic, String>(
    elements: _elements,
    groupBy: (dynamic element) => element['group'],
    groupSeparatorBuilder: (dynamic element) => Text(element['group']),
    itemBuilder: (context, dynamic element) => Text(element['name']),
    itemScrollController: GroupedItemScrollController(),
    order: StickyGroupedListOrder.ASC,
  ),
```

### Parameters:
| Name | Description | Required | Default value |
|----|----|----|----|
|`elements`| A list of the data you want to display in the list | required | - |
|`itemBuilder` / `indexedItemBuilder`| Function which returns an Widget which defines the item. `indexedItemBuilder` provides the current index as well. If both are defined `indexedItemBuilder` is preferred| yes, either of them | - |
|`groupBy` |Function which maps an element to its grouped value | required | - |
|`groupSeparatorBuilder`| Function which gets a element and returns an Widget which defines the group header separator | required | - |
|`separator` | A Widget which defines a separator between items inside a group | no | no separator |
| `floatingHeader` | When set to `true` the sticky header will float over the list | no | `false` |
| `order` | Change to `StickyGroupedListOrder.DESC` to reverse the group sorting | no | `StickyGroupedListOrder.ASC` |
|`itemScrollController`| Instead of an `ItemScrollController` a `GroupedItemScrollController` needs to be provided. | no | - |
|`reverse`| Scrolls in opposite from reading direction (Starting at bottom and scrolling up). Same as in scrollable_positioned_list. | no | false |

*`GroupedItemScrollController.srollTo()` and `GroupedItemScrollController.jumpTo()` automatic set the `alignment` so that the item is fully visible aligned under the group header. Both methods take `automaticAlignment` as a additional optional paramenter which needs to be set to true if `alignment` is specified.*

**Also the fields from `ScrollablePositionedList.builder` can be used.**

### Used packages: 
| Package name | Copyright | License |
|----|----|----|
|[scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list) | Copyright 2018 the Dart project authors, Inc. All rights reserved | [BSD 3-Clause "New" or "Revised" License](https://github.com/Dimibe/sticky_grouped_list/blob/master/LICENSE) |

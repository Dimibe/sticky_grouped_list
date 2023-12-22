/// This library brings support for a list view in which the items can be
/// grouped together in different sections.
///
/// This library is based on the package [scrollable_positioned_list] which
/// brings the ability to programatically scroll through the list.
///
/// * See https://pub.dev/packages/scrollable_positioned_list
///
/// To use this library in your code:
/// ```
/// import 'package:sticky_grouped_list/sticky_grouped_list.dart';
/// ```
library sticky_grouped_list;

export 'src/sticky_grouped_list.dart'
    show StickyGroupedListView, GroupedItemScrollController;
export 'src/sticky_grouped_list_order.dart' show StickyGroupedListOrder;

export 'package:scrollable_positioned_list/scrollable_positioned_list.dart'
    show ItemPositionsListener, ScrollOffsetListener, ScrollOffsetController;

library sticky_grouped_list;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A groupable list of widgets similar to [ScrollablePositionedList], execpt
/// that the items can be sectioned into groups.
///
/// See [ScrollablePositionedList]
class StickyGroupedListView<T, E> extends StatefulWidget {
  final Key? key;

  /// Items of which [itemBuilder] or [indexedItemBuilder] produce the list.
  final List<T> elements;

  /// Defines which elements are grouped together.
  ///
  /// Function is called for each element in the list, when equal for two
  /// elements, those two belong to the same group.
  final E Function(T element) groupBy;

  /// Can be used to define a custom sorting for the groups.
  ///
  /// If not set groups will be sorted with their natural sorting order or their
  /// specific [Comparable] implementation.
  final int Function(E value1, E value2)? groupComparator;

  /// Can be used to define a custom sorting for the elements inside each group.
  ///
  /// If not set elements will be sorted with their natural sorting order or
  /// their specific [Comparable] implementation.
  final int Function(T element1, T element2)? itemComparator;

  /// Called to build group separators for each group.
  /// element is always the first element of the group.
  final Widget Function(T element) groupSeparatorBuilder;

  /// Called to build children for the list with
  /// 0 <= element < elements.length.
  final Widget Function(BuildContext context, T element)? itemBuilder;

  /// Called to build children for the list with
  /// 0 <= element, index < elements.length
  final Widget Function(BuildContext context, T element, int index)?
      indexedItemBuilder;

  /// Whether the sorting of the list is ascending or descending.
  ///
  /// Defaults to ASC.
  final StickyGroupedListOrder order;

  /// Called to build separators for between each item in the list.
  final Widget separator;

  /// Whether the group headers float over the list or occupy their own space.
  final bool floatingHeader;

  /// Background color of the sticky header.
  /// Only used if [floatingHeader] is false.
  final Color stickyHeaderBackgroundColor;

  /// Controller for jumping or scrolling to an item.
  final GroupedItemScrollController? itemScrollController;

  /// Notifier that reports the items laid out in the list after each frame.
  final ItemPositionsListener? itemPositionsListener;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// How the scroll view should respond to user input.
  ///
  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Whether the view scrolls in the reading direction.
  ///
  /// Defaults to false.
  ///
  /// See [ScrollView.reverse].
  final bool reverse;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// See [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// See [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// See [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// The minimum cache extent used by the underlying scroll lists.
  /// See [ScrollView.cacheExtent].
  ///
  /// Note that the [ScrollablePositionedList] uses two lists to simulate long
  /// scrolls, so using the [ScrollController.scrollTo] method may result
  /// in builds of widgets that would otherwise already be built in the
  /// cache extent.
  final double? minCacheExtent;

  /// The number of children that will contribute semantic information.
  ///
  /// See [ScrollView.semanticChildCount] for more information.
  final int? semanticChildCount;

  /// Index of an item to initially align within the viewport.
  final int initialScrollIndex;

  /// Determines where the leading edge of the item at [initialScrollIndex]
  /// should be placed.
  final double initialAlignment;

  /// Creates a [StickyGroupedListView].
  StickyGroupedListView({
    this.key,
    required this.elements,
    required this.groupBy,
    required this.groupSeparatorBuilder,
    this.groupComparator,
    this.itemBuilder,
    this.indexedItemBuilder,
    this.itemComparator,
    this.order = StickyGroupedListOrder.ASC,
    this.separator = const SizedBox.shrink(),
    this.floatingHeader = false,
    this.stickyHeaderBackgroundColor = const Color(0xffF7F7F7),
    this.scrollDirection = Axis.vertical,
    this.itemScrollController,
    this.itemPositionsListener,
    this.physics,
    this.padding,
    this.reverse = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.minCacheExtent,
    this.semanticChildCount,
    this.initialAlignment = 0,
    this.initialScrollIndex = 0,
  })  : assert(itemBuilder != null || indexedItemBuilder != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _StickyGroupedListViewState<T, E>();
}

class _StickyGroupedListViewState<T, E>
    extends State<StickyGroupedListView<T, E>> {
  StreamController<int> _streamController = StreamController<int>();
  late ItemPositionsListener _listener;
  late GroupedItemScrollController _controller;
  GlobalKey? _groupHeaderKey;
  List<T> _sortedElements = [];
  GlobalKey _key = GlobalKey();
  int _topElementIndex = 0;
  RenderBox? _headerBox;
  RenderBox? _listBox;
  double? _headerDimension;
  bool Function(int)? _isSeparator;

  @override
  void initState() {
    super.initState();
    _controller = widget.itemScrollController ?? GroupedItemScrollController();
    _controller._bind(this);
    _listener = widget.itemPositionsListener ?? ItemPositionsListener.create();
    _listener.itemPositions.addListener(_positionListener);
  }

  @override
  void dispose() {
    _listener.itemPositions.removeListener(_positionListener);
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._sortedElements = _sortElements();
    var hiddenIndex = widget.reverse ? _sortedElements.length * 2 - 1 : 0;
    _isSeparator = widget.reverse ? (int i) => i.isOdd : (int i) => i.isEven;

    return Stack(
      key: _key,
      alignment: Alignment.topCenter,
      children: <Widget>[
        ScrollablePositionedList.builder(
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          itemScrollController: _controller,
          physics: widget.physics,
          itemPositionsListener: _listener,
          initialAlignment: widget.initialAlignment,
          initialScrollIndex: widget.initialScrollIndex,
          minCacheExtent: widget.minCacheExtent,
          semanticChildCount: widget.semanticChildCount,
          padding: widget.padding,
          reverse: widget.reverse,
          itemCount: _sortedElements.length * 2,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          itemBuilder: (context, index) {
            int actualIndex = index ~/ 2;

            if (index == hiddenIndex) {
              return Opacity(
                opacity: 0,
                child:
                    widget.groupSeparatorBuilder(_sortedElements[actualIndex]),
              );
            }

            if (_isSeparator!(index)) {
              E curr = widget.groupBy(_sortedElements[actualIndex]);
              E prev = widget.groupBy(
                  _sortedElements[actualIndex + (widget.reverse ? 1 : -1)]);
              if (prev != curr) {
                return widget
                    .groupSeparatorBuilder(_sortedElements[actualIndex]);
              }
              return widget.separator;
            }
            return _buildItem(context, actualIndex);
          },
        ),
        StreamBuilder<int>(
          stream: _streamController.stream,
          initialData: _topElementIndex,
          builder: (_, snapshot) => _showFixedGroupHeader(snapshot.data!),
        )
      ],
    );
  }

  Widget _buildItem(context, int actualIndex) {
    return widget.indexedItemBuilder == null
        ? widget.itemBuilder!(context, _sortedElements[actualIndex])
        : widget.indexedItemBuilder!(
            context, _sortedElements[actualIndex], actualIndex);
  }

  _positionListener() {
    _headerBox ??=
        _groupHeaderKey?.currentContext?.findRenderObject() as RenderBox?;
    double headerHeight = _headerBox?.size.height ?? 0;
    _listBox ??= _key.currentContext?.findRenderObject() as RenderBox?;
    double height = _listBox?.size.height ?? 0;
    _headerDimension = headerHeight / height;

    ItemPosition reducePositions(ItemPosition pos, ItemPosition current) {
      if (widget.reverse) {
        return current.itemTrailingEdge > pos.itemTrailingEdge ? current : pos;
      }
      return current.itemTrailingEdge < pos.itemTrailingEdge ? current : pos;
    }

    ItemPosition currentItem = _listener.itemPositions.value
        .where((ItemPosition position) =>
            !_isSeparator!(position.index) &&
            position.itemTrailingEdge > _headerDimension!)
        .reduce(reducePositions);

    int index = currentItem.index ~/ 2;
    if (_topElementIndex != index) {
      E curr = widget.groupBy(_sortedElements[index]);
      E prev = widget.groupBy(_sortedElements[_topElementIndex]);
      if (prev != curr) {
        _topElementIndex = index;
        _streamController.add(_topElementIndex);
      }
    }
  }

  List<T> _sortElements() {
    List<T> elements = widget.elements;
    if (elements.isNotEmpty) {
      elements.sort((e1, e2) {
        var compareResult;
        // compare groups
        if (widget.groupComparator != null) {
          compareResult =
              widget.groupComparator!(widget.groupBy(e1), widget.groupBy(e2));
        } else if (widget.groupBy(e1) is Comparable) {
          compareResult = (widget.groupBy(e1) as Comparable)
              .compareTo(widget.groupBy(e2) as Comparable);
        }
        // compare elements inside group
        if ((compareResult == null || compareResult == 0)) {
          if (widget.itemComparator != null) {
            compareResult = widget.itemComparator!(e1, e2);
          } else if (e1 is Comparable) {
            compareResult = e1.compareTo(e2);
          }
        }
        return compareResult;
      });
    }
    if (widget.order == StickyGroupedListOrder.DESC) {
      elements = elements.reversed.toList();
    }
    return elements;
  }

  Widget _showFixedGroupHeader(int index) {
    if (widget.elements.length > 0) {
      _groupHeaderKey = GlobalKey();
      return Container(
        key: _groupHeaderKey,
        color:
            widget.floatingHeader ? null : widget.stickyHeaderBackgroundColor,
        width: widget.floatingHeader ? null : MediaQuery.of(context).size.width,
        child: widget.groupSeparatorBuilder(_sortedElements[index]),
      );
    }
    return Container();
  }
}

/// Controller to jump or scroll to a particular element the list.
///
/// See [ItemScrollController].
class GroupedItemScrollController extends ItemScrollController {
  _StickyGroupedListViewState? _stickyGroupedListViewState;

  /// Jumps to the element at [index]. The element will be placed under the
  /// group header.
  /// To set a custom [alignment] set [automaticAlignment] to false.
  ///
  /// See [ItemScrollController.jumpTo]
  @override
  void jumpTo(
      {required int index,
      double alignment = 0,
      bool automaticAlignment = true}) {
    if (automaticAlignment) {
      alignment = _stickyGroupedListViewState?._headerDimension ?? alignment;
    }
    return super.jumpTo(index: index * 2 + 1, alignment: alignment);
  }

  /// Scrolls to the element at [index]. The element will be placed under the
  /// group header.
  /// To set a custom [alignment] set [automaticAlignment] to false.
  ///
  /// See [ItemScrollController.scrollTo]
  @override
  Future<void> scrollTo({
    required int index,
    double alignment = 0,
    bool automaticAlignment = true,
    required Duration duration,
    Curve curve = Curves.linear,
    List<double> opacityAnimationWeights = const [40, 20, 40],
  }) {
    if (automaticAlignment) {
      alignment = _stickyGroupedListViewState?._headerDimension ?? alignment;
    }
    return super.scrollTo(
      index: index * 2 + 1,
      alignment: alignment,
      duration: duration,
      curve: curve,
      opacityAnimationWeights: opacityAnimationWeights,
    );
  }

  void _bind(_StickyGroupedListViewState stickyGroupedListViewState) {
    assert(_stickyGroupedListViewState == null);
    _stickyGroupedListViewState = stickyGroupedListViewState;
  }
}

/// Used to define the order of a [StickyGroupedListView].
enum StickyGroupedListOrder { ASC, DESC }

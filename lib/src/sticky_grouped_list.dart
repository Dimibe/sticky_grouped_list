import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'sticky_grouped_list_order.dart';

/// A groupable list of widgets similar to [ScrollablePositionedList], execpt
/// that the items can be sectioned into groups.
///
/// See [ScrollablePositionedList]
class StickyGroupedListView<T, E> extends StatefulWidget {
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

  /// Used to clearly indentify an element. The returned value can be of any
  /// type but must be unique for each element.
  ///
  /// Used by [GroupedItemScrollController] to scroll and jump to a specific
  /// element.
  final dynamic Function(T element)? elementIdentifier;

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

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  ///  Defaults to false.
  ///
  /// See [ScrollView.shrinkWrap].
  final bool shrinkWrap;

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
  const StickyGroupedListView({
    super.key,
    required this.elements,
    required this.groupBy,
    required this.groupSeparatorBuilder,
    this.groupComparator,
    this.itemBuilder,
    this.indexedItemBuilder,
    this.itemComparator,
    this.elementIdentifier,
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
    this.shrinkWrap = false,
  }) : assert(itemBuilder != null || indexedItemBuilder != null);

  @override
  State<StatefulWidget> createState() => StickyGroupedListViewState<T, E>();
}

@internal
class StickyGroupedListViewState<T, E>
    extends State<StickyGroupedListView<T, E>> {
  /// Used within [GroupedItemScrollController].
  @protected
  List<T> sortedElements = [];

  /// Used within [GroupedItemScrollController].
  @protected
  double? headerDimension;

  final StreamController<int> _streamController = StreamController<int>();
  late ItemPositionsListener _listener;
  late GroupedItemScrollController _controller;
  GlobalKey? _groupHeaderKey;
  final GlobalKey _key = GlobalKey();
  int _topElementIndex = 0;
  RenderBox? _headerBox;
  RenderBox? _listBox;
  bool Function(int)? _isSeparator;

  @override
  void initState() {
    super.initState();
    _controller = widget.itemScrollController ?? GroupedItemScrollController();
    _controller._attach(this);
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
  void deactivate() {
    _controller._detach();
    super.deactivate();
  }

  @override
  void didUpdateWidget(StickyGroupedListView<T, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemScrollController?._stickyGroupedListViewState == this) {
      oldWidget.itemScrollController?._detach();
    }
    if (widget.itemScrollController?._stickyGroupedListViewState != this) {
      widget.itemScrollController?._detach();
      widget.itemScrollController?._attach(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    sortedElements = _sortElements();
    var hiddenIndex = widget.reverse ? sortedElements.length * 2 - 1 : 0;
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
          initialScrollIndex: widget.initialScrollIndex * 2,
          minCacheExtent: widget.minCacheExtent,
          semanticChildCount: widget.semanticChildCount,
          padding: widget.padding,
          reverse: widget.reverse,
          itemCount: sortedElements.length * 2,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          shrinkWrap: widget.shrinkWrap,
          itemBuilder: (context, index) {
            int actualIndex = index ~/ 2;

            if (index == hiddenIndex) {
              return Opacity(
                opacity: 0,
                child:
                    widget.groupSeparatorBuilder(sortedElements[actualIndex]),
              );
            }

            if (_isSeparator!(index)) {
              E curr = widget.groupBy(sortedElements[actualIndex]);
              E prev = widget.groupBy(
                  sortedElements[actualIndex + (widget.reverse ? 1 : -1)]);
              if (prev != curr) {
                return widget
                    .groupSeparatorBuilder(sortedElements[actualIndex]);
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
        ? widget.itemBuilder!(context, sortedElements[actualIndex])
        : widget.indexedItemBuilder!(
            context, sortedElements[actualIndex], actualIndex);
  }

  _positionListener() {
    _headerBox ??=
        _groupHeaderKey?.currentContext?.findRenderObject() as RenderBox?;
    double headerHeight = _headerBox?.size.height ?? 0;
    _listBox ??= _key.currentContext?.findRenderObject() as RenderBox?;
    double height = _listBox?.size.height ?? 0;
    headerDimension = headerHeight / height;

    ItemPosition reducePositions(ItemPosition pos, ItemPosition current) {
      if (widget.reverse) {
        return current.itemTrailingEdge > pos.itemTrailingEdge ? current : pos;
      }
      return current.itemTrailingEdge < pos.itemTrailingEdge ? current : pos;
    }

    ItemPosition currentItem = _listener.itemPositions.value
        .where((ItemPosition position) =>
            !_isSeparator!(position.index) &&
            position.itemTrailingEdge > headerDimension!)
        .reduce(reducePositions);

    int index = currentItem.index ~/ 2;
    if (_topElementIndex != index) {
      E curr = widget.groupBy(sortedElements[index]);
      E prev = widget.groupBy(sortedElements[_topElementIndex]);
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
        int? compareResult;
        // compare groups
        if (widget.groupComparator != null) {
          compareResult =
              widget.groupComparator!(widget.groupBy(e1), widget.groupBy(e2));
        } else if (widget.groupBy(e1) is Comparable) {
          compareResult = (widget.groupBy(e1) as Comparable)
              .compareTo(widget.groupBy(e2) as Comparable);
        }
        // compare elements inside group
        if (compareResult == null || compareResult == 0) {
          if (widget.itemComparator != null) {
            compareResult = widget.itemComparator!(e1, e2);
          } else if (e1 is Comparable) {
            compareResult = e1.compareTo(e2);
          }
        }
        return compareResult!;
      });
    }
    if (widget.order == StickyGroupedListOrder.DESC) {
      elements = elements.reversed.toList();
    }
    return elements;
  }

  Widget _showFixedGroupHeader(int index) {
    if (widget.elements.isNotEmpty) {
      _groupHeaderKey = GlobalKey();
      return Container(
        key: _groupHeaderKey,
        color:
            widget.floatingHeader ? null : widget.stickyHeaderBackgroundColor,
        width: widget.floatingHeader ? null : MediaQuery.of(context).size.width,
        child: widget.groupSeparatorBuilder(sortedElements[index]),
      );
    }
    return Container();
  }

  /// The purpose of this method is to wrap [widget.elementIdentifier] and
  /// type cast the provided [element] to [T].
  /// Since the [GroupedItemScrollController] has no information about [T] it's
  /// not possible to call [widget.elementIdentifier] directly.
  @protected
  dynamic getIdentifier(dynamic element) {
    return widget.elementIdentifier!(element as T);
  }
}

/// Controller to jump or scroll to a particular element the list.
///
/// See [ItemScrollController].
class GroupedItemScrollController extends ItemScrollController {
  StickyGroupedListViewState? _stickyGroupedListViewState;

  /// Whether any [StickyGroupedListView] objects are attached this object.
  ///
  /// If `false`, then [jumpTo] and [scrollTo] must not be called.
  @override
  bool get isAttached => _stickyGroupedListViewState != null;

  /// Jumps to the element at [index]. The element will be placed under the
  /// group header.
  /// To set a custom [alignment] set [automaticAlignment] to false.
  ///
  /// See [ItemScrollController.jumpTo]
  @override
  void jumpTo({
    required int index,
    double alignment = 0,
    bool automaticAlignment = true,
  }) {
    if (automaticAlignment) {
      alignment = _stickyGroupedListViewState!.headerDimension ?? alignment;
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
    required Duration duration,
    double alignment = 0,
    bool automaticAlignment = true,
    Curve curve = Curves.linear,
    List<double> opacityAnimationWeights = const [40, 20, 40],
  }) {
    if (automaticAlignment) {
      alignment = _stickyGroupedListViewState!.headerDimension ?? alignment;
    }
    return super.scrollTo(
      index: index * 2 + 1,
      alignment: alignment,
      duration: duration,
      curve: curve,
      opacityAnimationWeights: opacityAnimationWeights,
    );
  }

  void jumpToElement({
    required dynamic identifier,
    double alignment = 0,
    bool automaticAlignment = true,
  }) {
    return jumpTo(
      index: _findIndexByIdentifier(identifier),
      alignment: alignment,
      automaticAlignment: automaticAlignment,
    );
  }

  Future<void> scrollToElement({
    required dynamic identifier,
    required Duration duration,
    double alignment = 0,
    bool automaticAlignment = true,
    Curve curve = Curves.linear,
    List<double> opacityAnimationWeights = const [40, 20, 40],
  }) {
    return scrollTo(
      index: _findIndexByIdentifier(identifier),
      duration: duration,
      alignment: alignment,
      automaticAlignment: automaticAlignment,
      curve: curve,
      opacityAnimationWeights: opacityAnimationWeights,
    );
  }

  int _findIndexByIdentifier(dynamic identifier) {
    var elements = _stickyGroupedListViewState!.sortedElements;
    var identify = _stickyGroupedListViewState!.getIdentifier;

    for (int i = 0; i < elements.length; i++) {
      if (identify(elements[i]) == identifier) {
        return i;
      }
    }
    return -1;
  }

  void _attach(StickyGroupedListViewState stickyGroupedListViewState) {
    assert(_stickyGroupedListViewState == null);
    _stickyGroupedListViewState = stickyGroupedListViewState;
  }

  void _detach() {
    _stickyGroupedListViewState = null;
  }
}

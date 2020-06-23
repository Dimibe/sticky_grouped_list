library sticky_grouped_list;

import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StickyGroupedListView<T, E> extends StatefulWidget {
  final E Function(T element) groupBy;
  final Widget Function(T element) groupSeparatorBuilder;
  final Widget Function(BuildContext context, T element) itemBuilder;
  final Widget Function(BuildContext context, T element, int index)
      indexedItemBuilder;
  final StickyGroupedListOrder order;
  final Widget separator;
  final List<T> elements;
  final bool floatingHeader;
  final Key key;
  final GroupedItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Axis scrollDirection;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double minCacheExtent;
  final int semanticChildCount;
  final int initialScrollIndex;
  final double initialAlignment;

  StickyGroupedListView({
    @required this.elements,
    @required this.groupBy,
    @required this.groupSeparatorBuilder,
    this.itemBuilder,
    this.indexedItemBuilder,
    this.order,
    this.separator = const SizedBox.shrink(),
    this.floatingHeader = false,
    this.key,
    this.scrollDirection = Axis.vertical,
    this.itemScrollController,
    this.itemPositionsListener,
    this.physics,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.minCacheExtent,
    this.semanticChildCount,
    this.initialAlignment = 0,
    this.initialScrollIndex = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StickyGroupedListViewState<T, E>();
}

class _StickyGroupedListViewState<T, E>
    extends State<StickyGroupedListView<T, E>> {
  ItemPositionsListener _listener;
  ItemScrollController _controller;
  GlobalKey _groupHeaderKey;
  List<T> _sortedElements = [];
  GlobalKey _key = GlobalKey();
  int _topElementIndex = 0;
  RenderBox headerBox;
  RenderBox listBox;

  @override
  Widget build(BuildContext context) {
    this._sortedElements = _sortElements();
    return Stack(
      key: _key,
      alignment: Alignment.topCenter,
      children: <Widget>[
        ScrollablePositionedList.builder(
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          itemScrollController: _getController(),
          physics: widget.physics,
          itemPositionsListener: _getListener(),
          initialAlignment: widget.initialAlignment,
          initialScrollIndex: widget.initialScrollIndex,
          minCacheExtent: widget.minCacheExtent,
          semanticChildCount: widget.semanticChildCount,
          padding: widget.padding,
          itemCount: _sortedElements.length * 2,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          itemBuilder: (context, index) {
            int actualIndex = index ~/ 2;
            if (index == 0) {
              return Opacity(
                opacity: 0,
                child:
                    widget.groupSeparatorBuilder(_sortedElements[actualIndex]),
              );
            }
            if (index.isEven) {
              E curr = widget.groupBy(_sortedElements[actualIndex]);
              E prev = widget.groupBy(_sortedElements[actualIndex - 1]);
              if (prev != curr) {
                return widget
                    .groupSeparatorBuilder(_sortedElements[actualIndex]);
              }
              return widget.separator;
            }
            return _buildItem(context, actualIndex);
          },
        ),
        _showFixedGroupHeader(),
      ],
    );
  }

  Widget _buildItem(context, int actualIndex) {
    return widget.indexedItemBuilder == null
        ? widget.itemBuilder(context, _sortedElements[actualIndex])
        : widget.indexedItemBuilder(
            context, _sortedElements[actualIndex], actualIndex);
  }

  _positionListener() {
    headerBox ??= _groupHeaderKey?.currentContext?.findRenderObject();
    double headerHeight = headerBox?.size?.height ?? 0;
    listBox ??= _key?.currentContext?.findRenderObject();
    double height = listBox?.size?.height ?? 0;

    ItemPosition currentItem = _listener.itemPositions.value
        .where((ItemPosition position) =>
            position.index.isOdd &&
            position.itemTrailingEdge > headerHeight / height)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min);

    int index = (currentItem?.index ?? 0) ~/ 2;
    if (_topElementIndex != index) {
      E curr = widget.groupBy(_sortedElements[index]);
      E prev = widget.groupBy(_sortedElements[_topElementIndex]);
      if (prev != curr) {
        setState(() {
          _topElementIndex = index;
        });
      }
    }
  }

  List<T> _sortElements() {
    List<T> elements = widget.elements;
    if (elements.isNotEmpty) {
      elements.sort((e1, e2) {
        var compareResult;
        if (widget.groupBy(e1) is Comparable) {
          compareResult = (widget.groupBy(e1) as Comparable)
              .compareTo(widget.groupBy(e2) as Comparable);
        }
        if ((compareResult == null || compareResult == 0) && e1 is Comparable) {
          compareResult = (e1).compareTo(e2);
        }
        return compareResult;
      });
    }
    if (widget.order == StickyGroupedListOrder.DESC) {
      elements = elements.reversed.toList();
    }
    return elements;
  }

  Widget _showFixedGroupHeader() {
    if (widget.elements.length > 0) {
      _groupHeaderKey = GlobalKey();
      return Container(
        key: _groupHeaderKey,
        color: widget.floatingHeader ? null : Color(0xffF7F7F7),
        width: widget.floatingHeader ? null : MediaQuery.of(context).size.width,
        child: widget.groupSeparatorBuilder(_sortedElements[_topElementIndex]),
      );
    }
    return Container();
  }

  GroupedItemScrollController _getController() {
    _controller = widget.itemScrollController ?? GroupedItemScrollController();
    return _controller;
  }

  ItemPositionsListener _getListener() {
    _listener = widget.itemPositionsListener ?? ItemPositionsListener.create();
    _listener.itemPositions.addListener(_positionListener);
    return _listener;
  }
}

class GroupedItemScrollController extends ItemScrollController {
  @override
  void jumpTo({@required int index, double alignment = 0}) {
    return super.jumpTo(index: index * 2 + 1, alignment: alignment);
  }

  @override
  Future<void> scrollTo(
      {@required int index,
      double alignment = 0,
      @required Duration duration,
      Curve curve = Curves.linear}) {
    return super.scrollTo(
        index: index * 2 + 1,
        alignment: alignment,
        duration: duration,
        curve: curve);
  }
}

enum StickyGroupedListOrder { ASC, DESC }

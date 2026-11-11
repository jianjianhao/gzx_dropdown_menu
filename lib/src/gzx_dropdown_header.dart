import 'package:flutter/material.dart';

import 'gzx_dropdown_menu_controller.dart';

/// Signature for when a tap has occurred.
typedef OnItemTap<T> = void Function(T value);

/// Dropdown header widget.
class GZXDropDownHeader extends StatefulWidget {
  /// Background color of each header item.
  final Color color;

  /// Border width of the whole header.
  final double borderWidth;

  /// Border color of the whole header.
  final Color borderColor;

  /// Text style of a header item when the menu is not showing.
  final TextStyle style;

  /// Text style of a header item when the menu is showing.
  final TextStyle? dropDownStyle;

  /// Default icon size.
  final double iconSize;

  /// Icon color when the menu is not showing.
  final Color iconColor;

  /// Icon color when the menu is showing.
  final Color? iconDropDownColor;

  /// Height of the header.
  final double height;

  /// Height of the divider between two header items.
  final double dividerHeight;

  /// Color of the divider between two header items.
  final Color dividerColor;

  /// Controller shared with [GZXDropDownMenu].
  final GZXDropdownMenuController controller;

  /// Called when a header item is tapped, the value is the item index.
  final OnItemTap? onItemTap;

  /// Header items, the index must match the menus of [GZXDropDownMenu].
  final List<GZXDropDownHeaderItem> items;

  /// Key of the Stack that contains this header and the [GZXDropDownMenu].
  final GlobalKey stackKey;

  /// Creates a dropdown header widget, Contains more than one header items.
  GZXDropDownHeader({
    Key? key,
    required this.items,
    required this.controller,
    required this.stackKey,
    this.style = const TextStyle(color: Color(0xFF666666), fontSize: 13),
    this.dropDownStyle,
    this.height = 40,
    this.iconColor = const Color(0xFFafada7),
    this.iconDropDownColor,
    this.iconSize = 20,
    this.borderWidth = 1,
    this.borderColor = const Color(0xFFeeede6),
    this.dividerHeight = 20,
    this.dividerColor = const Color(0xFFeeede6),
    this.onItemTap,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  State<GZXDropDownHeader> createState() => _GZXDropDownHeaderState();
}

class _GZXDropDownHeaderState extends State<GZXDropDownHeader> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(GZXDropDownHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownStyle = widget.dropDownStyle ??
        TextStyle(color: Theme.of(context).primaryColor, fontSize: 13);
    final iconDropDownColor =
        widget.iconDropDownColor ?? Theme.of(context).primaryColor;
    final items = widget.items;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: items.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // 按可用宽度平分，避免头部不是整屏宽时格子宽度与屏幕宽度不一致。
                final itemWidth = constraints.maxWidth / items.length;
                return Row(
                  children: <Widget>[
                    for (int index = 0; index < items.length; index++)
                      SizedBox(
                        width: itemWidth,
                        child: _buildItem(
                          items[index],
                          index,
                          dropDownStyle,
                          iconDropDownColor,
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildItem(
    GZXDropDownHeaderItem item,
    int index,
    TextStyle dropDownStyle,
    Color iconDropDownColor,
  ) {
    final isShowDropDownItemWidget =
        index == widget.controller.menuIndex && widget.controller.isShow;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleItemTap(index),
      child: Container(
        color: widget.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isShowDropDownItemWidget
                          ? dropDownStyle
                          : widget.style.merge(item.style),
                    ),
                  ),
                  Icon(
                    isShowDropDownItemWidget
                        ? item.iconDropDownData ??
                            item.iconData ??
                            Icons.arrow_drop_up
                        : item.iconData ?? Icons.arrow_drop_down,
                    color: isShowDropDownItemWidget
                        ? iconDropDownColor
                        : item.style?.color ?? widget.iconColor,
                    size: item.iconSize ?? widget.iconSize,
                  ),
                ],
              ),
            ),
            if (index != widget.items.length - 1)
              Container(
                width: 1,
                height: widget.dividerHeight,
                color: widget.dividerColor,
              ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(int index) {
    // 计算 DropdownMenu 相对 Stack 的顶部偏移，stackKey 未挂载时退化为全局坐标，不再强制解包。
    final overlayRenderBox =
        widget.stackKey.currentContext?.findRenderObject() as RenderBox?;
    final headerRenderBox = context.findRenderObject() as RenderBox?;
    if (headerRenderBox != null && headerRenderBox.hasSize) {
      final position = headerRenderBox.localToGlobal(Offset.zero,
          ancestor: overlayRenderBox);
      widget.controller.dropDownMenuTop =
          position.dy + headerRenderBox.size.height;
    }

    if (widget.controller.isShow && widget.controller.menuIndex == index) {
      widget.controller.hide();
    } else {
      if (widget.controller.isShow) {
        widget.controller.hide(isShowHideAnimation: false);
      }
      widget.controller.show(index);
    }

    widget.onItemTap?.call(index);
  }
}

class GZXDropDownHeaderItem {
  final String title;
  final IconData? iconData;
  final IconData? iconDropDownData;
  final double? iconSize;
  final TextStyle? style;

  const GZXDropDownHeaderItem(
    this.title, {
    this.iconData,
    this.iconDropDownData,
    this.iconSize,
    this.style,
  });
}

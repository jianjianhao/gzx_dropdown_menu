import 'package:flutter/material.dart';

import 'gzx_dropdown_menu_controller.dart';

/// Information about the dropdown menu widget, such as the height of the drop down menu to be displayed.
class GZXDropdownMenuBuilder {
  /// A dropdown menu displays the widget.
  final Widget dropDownWidget;

  /// Dropdown menu height.
  final double dropDownHeight;

  const GZXDropdownMenuBuilder({
    required this.dropDownWidget,
    required this.dropDownHeight,
  });
}

/// Signature for the dropdown menu callbacks.
///
/// [isShow] tells whether the menu is being shown or hidden, [index] is the
/// index of the menu the event belongs to.
typedef DropdownMenuChange = void Function(bool isShow, int? index);

/// Dropdown menu widget.
///
/// The widget returns a [Positioned], so it must be a direct child of the
/// [Stack] that also owns the [GZXDropDownHeader]'s `stackKey`.
class GZXDropDownMenu extends StatefulWidget {
  /// Controller shared with [GZXDropDownHeader].
  final GZXDropdownMenuController controller;

  /// Menus to display, indexed the same way as the header items.
  final List<GZXDropdownMenuBuilder> menus;

  /// Duration of the show/hide animation, in milliseconds.
  final int animationMilliseconds;

  /// Color of the mask below the menu.
  final Color maskColor;

  /// Called when dropdown menu start showing or hiding.
  final DropdownMenuChange? dropdownMenuChanging;

  /// Called when dropdown menu has been shown or hidden.
  final DropdownMenuChange? dropdownMenuChanged;

  /// Creates a dropdown menu widget.
  /// The widget must be inside the Stack because the widget is a Positioned.
  const GZXDropDownMenu({
    super.key,
    required this.controller,
    required this.menus,
    this.animationMilliseconds = 500,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.5),
    this.dropdownMenuChanging,
    this.dropdownMenuChanged,
  });

  @override
  State<GZXDropDownMenu> createState() => _GZXDropDownMenuState();
}

class _GZXDropDownMenuState extends State<GZXDropDownMenu>
    with SingleTickerProviderStateMixin {
  /// Drives both the menu height and the mask opacity, value range is 0~1.
  late final AnimationController _animationController;

  /// Height of the menu the current animation cycle belongs to.
  double _menuHeight = 0;

  /// Index of the menu the current animation cycle belongs to.
  int? _menuIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animationMilliseconds),
      vsync: this,
    )..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.isShow) {
      // 首次构建时 controller 已是显示状态，等首帧结束再同步，避免在 build 期间回调使用方。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onControllerChanged();
        }
      });
    }
  }

  @override
  void didUpdateWidget(GZXDropDownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.animationMilliseconds != widget.animationMilliseconds) {
      _animationController.duration =
          Duration(milliseconds: widget.animationMilliseconds);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = widget.controller;
    final index = controller.menuIndex;
    if (index < 0 || index >= widget.menus.length) return;

    if (controller.isShow) {
      // 已经完整展示同一个菜单，重复通知不需要重跑动画。
      if (_menuIndex == index &&
          _animationController.status == AnimationStatus.completed) {
        return;
      }
      _startShow(index);
    } else {
      // 没有内容正在展示，忽略这次隐藏通知，避免多余回调。
      if (_animationController.value == 0) return;
      // 同一个菜单已经在隐藏动画中，忽略重复通知。
      if (_menuIndex == index &&
          _animationController.status == AnimationStatus.reverse) {
        return;
      }
      _startHide(index);
    }
  }

  void _startShow(int index) {
    // 隐藏动画没播完就被新的展示打断时，补发它的结束回调，
    // 保证每次 changing(false, x) 都有配对的 changed(false, x)。
    if (_animationController.status == AnimationStatus.reverse &&
        _menuIndex != null) {
      widget.dropdownMenuChanged?.call(false, _menuIndex);
    }

    _menuIndex = index;
    _menuHeight = widget.menus[index].dropDownHeight;

    if (_menuHeight <= 0) {
      // 高度为 0 没有可展示的内容，直接归位且不参与显示/隐藏回调，
      // 避免除零和 changing 没有配对的 changed。
      _animationController.value = 0;
      setState(() {});
      return;
    }

    widget.dropdownMenuChanging?.call(true, index);
    // forward 会从当前进度继续，因此动画中途反向时也能平滑过渡。
    _animationController.forward();
    setState(() {});
  }

  void _startHide(int index) {
    _menuIndex = index;
    widget.dropdownMenuChanging?.call(false, index);

    if (widget.controller.isShowHideAnimation) {
      _animationController.reverse();
    } else {
      final wasAlreadyHidden =
          _animationController.status == AnimationStatus.dismissed;
      // value 由 0 之外的值改成 0 时，状态变为 dismissed 并触发 _onAnimationStatus。
      _animationController.value = 0;
      if (wasAlreadyHidden) {
        widget.dropdownMenuChanged?.call(false, index);
      }
    }
    setState(() {});
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    switch (status) {
      case AnimationStatus.completed:
        widget.dropdownMenuChanged?.call(true, _menuIndex);
        break;
      case AnimationStatus.dismissed:
        widget.dropdownMenuChanged?.call(false, _menuIndex);
        break;
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuIndex = widget.controller.menuIndex;
    if (menuIndex < 0 || menuIndex >= widget.menus.length) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: widget.controller.dropDownMenuTop ?? 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        // 菜单内容只在切换菜单时重建，动画每帧只重建高度与蒙层。
        child: widget.menus[menuIndex].dropDownWidget,
        builder: (BuildContext context, Widget? child) {
          final progress = _animationController.value;
          return Column(
            children: <Widget>[
              if (child != null) _buildDropDownContainer(progress, child),
              _buildMask(context, progress),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropDownContainer(double progress, Widget child) {
    final height = _menuHeight * progress;
    if (height <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.white,
      child: ClipRect(
        // 高度变化时内容保持原有布局高度，只做裁剪，避免收起过程被压扁。
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: _menuHeight,
          child: child,
        ),
      ),
    );
  }

  Widget _buildMask(BuildContext context, double progress) {
    if (progress <= 0 || _menuHeight <= 0) {
      return const SizedBox.shrink();
    }
    final alpha = widget.maskColor.a / 255.0 * progress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.controller.hide(),
      child: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height,
        color: widget.maskColor.withValues(alpha: alpha),
      ),
    );
  }
}

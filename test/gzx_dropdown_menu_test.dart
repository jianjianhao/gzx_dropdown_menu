import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';

Widget _buildApp({
  required GZXDropdownMenuController controller,
  required GlobalKey stackKey,
  List<GZXDropDownHeaderItem>? items,
  double dropDownHeight = 200,
  DropdownMenuChange? onChanging,
  DropdownMenuChange? onChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        key: stackKey,
        children: <Widget>[
          Column(
            children: <Widget>[
              GZXDropDownHeader(
                items: items ??
                    const <GZXDropDownHeaderItem>[
                      GZXDropDownHeaderItem('A'),
                      GZXDropDownHeaderItem('B'),
                    ],
                controller: controller,
                stackKey: stackKey,
              ),
              const Expanded(child: SizedBox.expand()),
            ],
          ),
          GZXDropDownMenu(
            controller: controller,
            animationMilliseconds: 100,
            menus: <GZXDropdownMenuBuilder>[
              GZXDropdownMenuBuilder(
                dropDownHeight: dropDownHeight,
                dropDownWidget: const SizedBox(
                  height: 200,
                  child: Text('menu-0'),
                ),
              ),
              const GZXDropdownMenuBuilder(
                dropDownHeight: 200,
                dropDownWidget: Text('menu-1'),
              ),
            ],
            dropdownMenuChanging: onChanging,
            dropdownMenuChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}

void main() {
  test('controller show/hide/toggle notify listeners', () {
    final controller = GZXDropdownMenuController();
    var notifyCount = 0;
    controller.addListener(() => notifyCount++);

    controller.show(2);
    expect(controller.isShow, isTrue);
    expect(controller.menuIndex, 2);

    controller.hide();
    expect(controller.isShow, isFalse);

    controller.toggle(1);
    expect(controller.isShow, isTrue);
    expect(controller.menuIndex, 1);

    controller.toggle(1);
    expect(controller.isShow, isFalse);
    expect(notifyCount, 4);

    controller.dispose();
  });

  testWidgets('show/hide fires changing and changed callbacks in order',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();
    final events = <String>[];

    await tester.pumpWidget(_buildApp(
      controller: controller,
      stackKey: stackKey,
      onChanging: (bool isShow, int? index) =>
          events.add('changing:$isShow:$index'),
      onChanged: (bool isShow, int? index) =>
          events.add('changed:$isShow:$index'),
    ));

    expect(find.text('menu-0'), findsNothing);

    controller.show(0);
    await tester.pumpAndSettle();
    expect(find.text('menu-0'), findsOneWidget);
    expect(events, <String>['changing:true:0', 'changed:true:0']);

    controller.hide();
    await tester.pumpAndSettle();
    expect(find.text('menu-0'), findsNothing);
    expect(events, <String>[
      'changing:true:0',
      'changed:true:0',
      'changing:false:0',
      'changed:false:0',
    ]);
  });

  testWidgets('hiding without animation finishes in a single frame',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();
    final events = <String>[];

    await tester.pumpWidget(_buildApp(
      controller: controller,
      stackKey: stackKey,
      onChanged: (bool isShow, int? index) =>
          events.add('changed:$isShow:$index'),
    ));

    controller.show(0);
    await tester.pumpAndSettle();

    controller.hide(isShowHideAnimation: false);
    await tester.pump();

    expect(find.text('menu-0'), findsNothing);
    expect(events.last, 'changed:false:0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap mask hides the menu', (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();

    await tester
        .pumpWidget(_buildApp(controller: controller, stackKey: stackKey));
    controller.show(0);
    await tester.pumpAndSettle();

    // 菜单占据顶部 40~240，点击下方区域应命中蒙层并收起菜单。
    await tester.tapAt(const Offset(400, 500));
    await tester.pumpAndSettle();

    expect(controller.isShow, isFalse);
  });

  testWidgets('tapping a header item toggles the related menu',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();

    await tester
        .pumpWidget(_buildApp(controller: controller, stackKey: stackKey));

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(controller.isShow, isTrue);
    expect(controller.menuIndex, 0);
    expect(find.text('menu-0'), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(controller.isShow, isTrue);
    expect(controller.menuIndex, 1);
    expect(find.text('menu-1'), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(controller.isShow, isFalse);
  });

  testWidgets('duplicated header items report the right index',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();
    const item = GZXDropDownHeaderItem('same');

    await tester.pumpWidget(_buildApp(
      controller: controller,
      stackKey: stackKey,
      items: <GZXDropDownHeaderItem>[item, item],
    ));

    await tester.tap(find.text('same').at(1));
    await tester.pumpAndSettle();

    expect(controller.menuIndex, 1);
  });

  testWidgets('out of range menu index does not throw',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();

    await tester
        .pumpWidget(_buildApp(controller: controller, stackKey: stackKey));

    controller.show(5);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('menu-0'), findsNothing);
  });

  testWidgets('zero height menu does not throw nor divide by zero',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();
    final events = <String>[];

    await tester.pumpWidget(_buildApp(
      controller: controller,
      stackKey: stackKey,
      dropDownHeight: 0,
      onChanged: (bool isShow, int? index) =>
          events.add('changed:$isShow:$index'),
    ));

    controller.show(0);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // 高度为 0 的菜单没有内容可展示，不参与显示/隐藏回调。
    expect(events, isEmpty);
    expect(find.text('menu-0'), findsNothing);
  });

  testWidgets('interrupted hide still reports changed(false) for that menu',
      (WidgetTester tester) async {
    final controller = GZXDropdownMenuController();
    final stackKey = GlobalKey();
    final events = <String>[];

    await tester.pumpWidget(_buildApp(
      controller: controller,
      stackKey: stackKey,
      onChanging: (bool isShow, int? index) =>
          events.add('changing:$isShow:$index'),
      onChanged: (bool isShow, int? index) =>
          events.add('changed:$isShow:$index'),
    ));

    controller.show(0);
    await tester.pumpAndSettle();
    events.clear();

    // 隐藏动画播放到一半就被新的展示打断。
    controller.hide();
    await tester.pump(const Duration(milliseconds: 40));
    controller.show(1);
    await tester.pumpAndSettle();

    expect(events, <String>[
      'changing:false:0',
      'changed:false:0',
      'changing:true:1',
      'changed:true:1',
    ]);
    expect(find.text('menu-1'), findsOneWidget);
  });
}

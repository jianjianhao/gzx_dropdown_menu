import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gzx_dropdown_menu_example/gzx_dropdown_menu_test_page.dart';

void main() {
  testWidgets('dropdown page renders header items',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GZXDropDownMenuTestPage()));

    expect(find.text('全城'), findsOneWidget);
    expect(find.text('品牌'), findsOneWidget);

    await tester.tap(find.text('品牌'));
    await tester.pumpAndSettle();
    expect(find.text('金逸影城'), findsOneWidget);

    // 菜单展示中切换到另一个菜单，验证无动画隐藏 + 重新展开的链路。
    await tester.tap(find.text('距离近'));
    await tester.pumpAndSettle();
    expect(find.text('价格低'), findsOneWidget);

    // 两级联动菜单（Row + 两个 ListView）在动画裁剪下不应报溢出。
    await tester.tap(find.text('全城'));
    await tester.pumpAndSettle();
    expect(find.text('1区'), findsOneWidget);

    await tester.tap(find.text('1区'));
    await tester.pumpAndSettle();
    expect(find.textContaining('街道办'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}

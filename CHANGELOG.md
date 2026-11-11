## [4.0.0] - [2026-11-11]
### ⚡️ Improvements
* 最低环境升级到 Dart 3.1 / Flutter 3.22，适配当前 Flutter 3.44（Dart 3.12）
* 下拉动画改为 `AnimatedBuilder`，动画每帧不再重建整棵菜单，只重建高度与蒙层
* 菜单内容按实际高度裁剪（`ClipRect` + `OverflowBox`），收起过程不再被压扁
* 头部布局改用 `LayoutBuilder` 平分宽度，头部非整屏宽时格子宽度也正确
* 新增 `GZXDropdownMenuController.toggle`，`const` 化 `GZXDropdownMenuBuilder`、`GZXDropDownHeaderItem`
* 补充单元/组件测试与 example 交互测试，移除无效的空测试

### 🐛 Bug Fixes
* 修复无动画隐藏（`isShowHideAnimation: false`）后蒙层残留、吞掉页面点击的问题，并保证 `dropdownMenuChanged` 一定回调
* 修复 `dropdownMenuChanged` 回调携带错误 index（切换菜单时上报成新 index）
* 修复 `dropDownHeight` 为 0 时 `动画值 / 高度` 除零产生 NaN，导致蒙层颜色断言崩溃
* 修复头部使用 `items.indexOf(item)` 定位 index，相同 item 重复出现时拿到的 index 错误
* 修复 `stackKey` / 头部 Context 未挂载时强制解包 `!` 导致的空指针崩溃
* 修复菜单内容状态用 `取反` 推导、每次通知都切换，重复通知或父级重建后与 controller 状态错位的问题
* 修复 `controller` 实例变化时监听未迁移（新增 `didUpdateWidget`）
* 修复 `controller.menuIndex` 越界时返回非 `Positioned` 导致的布局异常
* 修复 `dispose` 缺少 `@override`、未使用 mixin、`withOpacity`/`opacity` 等已废弃 API
* 修复 example 使用已移除的 `AppBar.brightness` 造成的编译错误

## [3.1.0] - [2021-04-07]
### ✨ New Features
* Add iconDropDownData to customize icon when menu is show
### 🐛 Bug Fixes
* Fixed the drop down menu not showing fully when the width of the drop down menu is smaller than the width of the screen

## [3.0.0+3] - [2021-04-07]
* Formatting code to increase the score

## [3.0.0+2] - [2021-04-07]
* Using trailing commas and Format code

## [3.0.0+1] - [2021-04-06]
* Fixed Dart Analysis 3 issues
* Add DartDoc comments, remove useless code, and change variable names
* README add to-do list

## [3.0.0] - [2021-04-02]
* Migrate to null safety.

## [2.1.0] - [2020-06-03]
### ✨ New Features
* GZXDropDownMenu add dropdownMenuChanging and dropdownMenuChanged callback
* GZXDropDownHeaderItem add style (see https://github.com/GanZhiXiong/gzx_dropdown_menu/issues/27)
### ⚡️ Improvements
* Add removeListener and removeStatusListener when the animation is recreated
* Reduced calls to setstate
### 🐛 Bug Fixes
* Fixed Dropdown menu hide mask no animation

## [2.0.0+2] - [2020-05-11]
* Update Readme

## [2.0.0+1] - [2020-05-11]
* Update Readme

## [2.0.0] - [2020-05-10]
### ✨ New Features
* Mask color animation display
* Support for changing mask colors
### ⚡️ Improvements
* Modify the drop-down header to not scroll
* Hide dropdown menu add animation
### 🐛 Bug Fixes
* Fix-issues-16
* Fix repeatedly click current header,can't hide

## [1.0.3] - [2019-08-06]
* When the drop-down menu appears, click on the margin to collapse the menu, but the icon of header remains unchanged (https://github.com/GanZhiXiong/gzx_dropdown_menu/issues/2#issue-469594783)
* Slide the interface to the right and write the input field and the keypad will pop up causing the list to report an error (https://github.com/GanZhiXiong/gzx_dropdown_menu/issues/1#issue-467276935)

## [1.0.2] - [2019-06-06]
* update readme

## [1.0.1] - [2019-06-06]
* refactor code

## [1.0.0] - [2019-06-03]
* Custom dropdown header
* Custom dropdown header item
* Custom dropdown menu
* Custom dropdown menu show animation time
* Control dropdown menu show or hide
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:popup_menu/src/grid_menu_layout.dart';
import 'package:popup_menu/src/list_menu_layout.dart';
import 'package:popup_menu/src/menu_config.dart';
import 'package:popup_menu/src/menu_layout.dart';
import 'package:popup_menu/src/triangle_painter.dart';
import 'package:popup_menu/src/utils.dart';
import 'custom_close_button.dart';
import 'menu_item.dart';

export 'menu_item.dart';
export 'menu_config.dart';

enum MenuType {
  /// 格子
  grid,

  /// 单列
  list
}

enum ArrowAlignment {
  left,
  center,
  right,
}

typedef MenuClickCallback = void Function(MenuItemProvider item);

class PopupMenu {
  OverlayEntry? _entry;
  late List<MenuItemProvider> items;
  final ArrowAlignment arrowAlignment;
  final VoidCallback? onDismiss;
  final MenuClickCallback? onClickMenu;
  final VoidCallback? onShow;
  BuildContext context;
  bool _isShow = false;
  bool get isShow => _isShow;
  final MenuConfig config;
  Size _screenSize = window.physicalSize / window.devicePixelRatio;
  MenuLayout? menuLayout;
  PopupMenu({
    required this.context,
    required this.items,
    this.config = const MenuConfig(),
    this.onClickMenu,
    this.onDismiss,
    this.onShow,
    this.arrowAlignment = ArrowAlignment.center, // Default to center
  });

  void show({
    Rect? rect,
    GlobalKey? widgetKey,
    Color? closeButtonColor, // Allow the user to specify the close button color
  }) {
    assert(rect != null || widgetKey != null, "'rect' and 'key' can't be both null");

    final attachRect = rect ?? getWidgetGlobalRect(widgetKey!);

    if (config.type == MenuType.grid) {
      menuLayout = GridMenuLayout(
        config: config,
        items: this.items,
        onDismiss: dismiss,
        context: context,
        onClickMenu: onClickMenu,
      );
    } else if (config.type == MenuType.list) {
      menuLayout = ListMenuLayout(
        config: config,
        items: items,
        onDismiss: dismiss,
        context: context,
        onClickMenu: onClickMenu,
      );
    }

    _LayoutP layoutp = _calculateOffset(
      context,
      attachRect,
      menuLayout!.width,
      menuLayout!.height,
    );

    _entry = OverlayEntry(builder: (context) {
      return build(layoutp, menuLayout!, closeButtonColor);
    });

    Overlay.of(context)!.insert(_entry!);
    _isShow = true;
    onShow?.call();
  }

  Widget build(_LayoutP layoutp, MenuLayout menu, Color? closeButtonColor) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dismiss();
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            // triangle arrow
            Positioned(
              left: layoutp.offset.dx +
                  (arrowAlignment == ArrowAlignment.center
                      ? layoutp.width / 2 - 7.5
                      : (arrowAlignment == ArrowAlignment.right ? layoutp.width - 20 : 0)),
              top: layoutp.isDown ? layoutp.offset.dy - config.arrowHeight : layoutp.offset.dy + layoutp.height,
              child: Align(
                alignment: Alignment.topRight,
                child: CustomCloseButton(
                  color: closeButtonColor, // Set the custom background color
                  onPressed: dismiss, // Use the dismiss method to close the menu
                ),
              ),
            ),
            // menu content
            Positioned(
              left: layoutp.offset.dx,
              top: layoutp.offset.dy - 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add the close button at the top of the popup with customizable color

                  menu.build(), // The existing menu layout
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _LayoutP _calculateOffset(
    BuildContext context,
    Rect attachRect,
    double contentWidth,
    double contentHeight,
  ) {
    double dx = attachRect.left + attachRect.width / 2.0 - contentWidth / 2.0;

    if (dx < 10.0) dx = 10.0;
    if (dx + contentWidth > _screenSize.width) dx = _screenSize.width - contentWidth - 10;

    double dy = attachRect.top - contentHeight;
    bool isDown = false;

    if (dy <= MediaQuery.of(context).padding.top + 10) {
      dy = attachRect.bottom + config.arrowHeight;
      isDown = true;
    } else {
      dy -= config.arrowHeight;
    }

    return _LayoutP(
      width: contentWidth,
      height: contentHeight,
      attachRect: attachRect,
      offset: Offset(dx, dy),
      isDown: isDown,
    );
  }

  void dismiss() {
    if (!_isShow) {
      return;
    }

    _entry?.remove();
    _isShow = false;
    onDismiss?.call();
  }
}

class _LayoutP {
  double width;
  double height;
  Offset offset;
  Rect attachRect;
  bool isDown;

  _LayoutP({
    required this.width,
    required this.height,
    required this.offset,
    required this.attachRect,
    required this.isDown,
  });
}

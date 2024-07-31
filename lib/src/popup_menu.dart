import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:popup_menu/src/grid_menu_layout.dart';
import 'package:popup_menu/src/list_menu_layout.dart';
import 'package:popup_menu/src/menu_config.dart';
import 'package:popup_menu/src/menu_layout.dart';
import 'package:popup_menu/src/triangle_painter.dart';
import 'package:popup_menu/src/utils.dart';
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

  /// callback
  final VoidCallback? onDismiss;
  final MenuClickCallback? onClickMenu;
  final VoidCallback? onShow;

  /// Cannot be null
  BuildContext context;

  /// It's showing or not.
  bool _isShow = false;
  bool get isShow => _isShow;

  final MenuConfig config;
  Size _screenSize = window.physicalSize / window.devicePixelRatio;

  PopupMenu({
    required this.context,
    required this.items,
    this.config = const MenuConfig(),
    this.onClickMenu,
    this.onDismiss,
    this.onShow,
    this.arrowAlignment = ArrowAlignment.center, // Default to center
  });
  MenuLayout? menuLayout;

  void show({
    Rect? rect,
    GlobalKey? widgetKey,
  }) {
    assert(rect != null || widgetKey != null,
        "'rect' and 'key' can't be both null");

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
      return build(layoutp, menuLayout!);
    });

    Overlay.of(context)!.insert(_entry!);
    _isShow = true;
    onShow?.call();
  }

  Widget build(_LayoutP layoutp, MenuLayout menu) {
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
                      : (arrowAlignment == ArrowAlignment.right
                          ? layoutp.width - 15
                          : 0)),
              top: layoutp.isDown
                  ? layoutp.offset.dy - config.arrowHeight
                  : layoutp.offset.dy + layoutp.height,
              child: CustomPaint(
                size: Size(15.0, config.arrowHeight),
                painter: TrianglePainter(
                  isDown: !layoutp.isDown,
                  color: config.backgroundColor,
                ),
              ),
            ),
            // menu content
            Positioned(
              left: layoutp.offset.dx,
              top: layoutp.offset.dy,
              child: menu.build(),
            ),
          ],
        ),
      ),
    );
  }

  /// 计算布局位置
  _LayoutP _calculateOffset(
    BuildContext context,
    Rect attachRect,
    double contentWidth,
    double contentHeight,
  ) {
    double dx;
    switch (arrowAlignment) {
      case ArrowAlignment.left:
        dx = attachRect.left;
        break;
      case ArrowAlignment.center:
        dx = attachRect.left + attachRect.width / 2.0 - contentWidth / 2.0;
        break;
      case ArrowAlignment.right:
        dx = attachRect.right - contentWidth;
        break;
    }

    // Ensure the menu doesn't go out of the screen
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + contentWidth > _screenSize.width && dx > 10.0) {
      dx = _screenSize.width - contentWidth - 10;
    }

    // Determine if the menu should be displayed above or below the trigger area
    double dy = attachRect.bottom + config.arrowHeight;
    bool isDown =
        true; // Assume the arrow points down (menu is below the trigger)
    if (dy + contentHeight > _screenSize.height) {
      dy = attachRect.top - contentHeight - config.arrowHeight;
      isDown = false; // Arrow points up (menu is above the trigger)
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
      // Remove method should only be called once
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

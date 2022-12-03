// import 'dart:io';

// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:arthurmorgan/enums.dart';
// import 'package:flutter/material.dart';

// class WindowTitleBar extends StatelessWidget {
//   final InterfaceBrightness brightness;
//   const WindowTitleBar({Key? key, required this.brightness}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Platform.isWindows
//         ? Container(
//             width: MediaQuery.of(context).size.width,
//             height: 50.0,
//             color: Colors.transparent,
//             margin: const EdgeInsets.only(left: 200),
//             child: MoveWindow(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: Container(),
//                   ),
//                   MinimizeWindowButton(
//                     colors: WindowButtonColors(
//                       iconNormal: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       normal: Colors.transparent,
//                       mouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.04)
//                           : Colors.white.withOpacity(0.04),
//                       mouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.08)
//                           : Colors.white.withOpacity(0.08),
//                     ),
//                   ),
//                   MaximizeWindowButton(
//                     colors: WindowButtonColors(
//                       iconNormal: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       normal: Colors.transparent,
//                       mouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.04)
//                           : Colors.white.withOpacity(0.04),
//                       mouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.08)
//                           : Colors.white.withOpacity(0.08),
//                     ),
//                   ),
//                   CloseWindowButton(
//                     onPressed: () {
//                       appWindow.close();
//                     },
//                     colors: WindowButtonColors(
//                       iconNormal: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       iconMouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black
//                           : Colors.white,
//                       normal: Colors.transparent,
//                       mouseOver: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.04)
//                           : Colors.white.withOpacity(0.04),
//                       mouseDown: brightness == InterfaceBrightness.light
//                           ? Colors.black.withOpacity(0.08)
//                           : Colors.white.withOpacity(0.08),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         : Container();
//   }
// }

import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

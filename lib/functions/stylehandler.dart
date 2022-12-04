import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class StyleHandler {
  static void setWindowStyle(String windowStyle) {
    switch (windowStyle) {
      case 'opaque':
        Window.setEffect(
          effect: WindowEffect.solid,
          color: Color(0xCC222222),
        );
        break;

      case 'transparent':
        Window.setEffect(
          effect: WindowEffect.transparent,
          color: Color(0xCC222222),
        );
        break;

      case 'aero':
        Window.setEffect(
          effect: WindowEffect.aero,
          color: Color(0xCC222222),
        );
        break;

      case 'acrylic':
        Window.setEffect(
          effect: WindowEffect.acrylic,
          color: Color(0xCC222222),
        );
        break;

      case 'mica':
        Window.setEffect(
          effect: WindowEffect.mica,
          color: Color(0xCC222222),
        );
        break;
    }
  }
}

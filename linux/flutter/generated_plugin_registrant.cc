//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>
#include <window_to_front/window_to_front_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) bitsdojo_window_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BitsdojoWindowPlugin");
  bitsdojo_window_plugin_register_with_registrar(bitsdojo_window_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_acrylic_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterAcrylicPlugin");
  flutter_acrylic_plugin_register_with_registrar(flutter_acrylic_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_to_front_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowToFrontPlugin");
  window_to_front_plugin_register_with_registrar(window_to_front_registrar);
}

import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'global_data.dart';

class Utils {
  static String padPassToKey(String pass) {
    return pass.padRight(32, "1");
  }

  static void clearTemp() {
    try {
      File(path.join(
              GlobalData.gAppDocDir!.path, "ArthurMorgan", "Temp", "temp.meb"))
          .deleteSync();
    } catch (e) {
      log(e.toString());
    }
  }
}

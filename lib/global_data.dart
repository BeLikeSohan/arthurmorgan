import 'dart:io';

import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:oauth2/oauth2.dart';

class GlobalData {
  static Client? gClient;
  static GDriveManager? gDriveManager;
  static Directory? gAppDocDir;

  static String? gClientId;
  static String? gClientSecret;
}

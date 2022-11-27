import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:desktop_experiments/functions/googleoauthmanager.dart';
import 'package:desktop_experiments/functions/preferencesmanager.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/pages/mainpage/screens/dashboard_screen.dart';
import 'package:desktop_experiments/pages/mainpage/screens/sign_in_screen.dart';
import 'package:desktop_experiments/providers/auth_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void loadLoginInfo() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    if ((await PreferencesManager.isLoggedInBefore())) {
      String oauthJson = await PreferencesManager.getOAuthJson();
      authProvider.loadOAuthInformation(oauthJson);
    }
  }

  void loadClientFile() async {
    String dir = Directory.current.path;
    log(dir);
    List fileList = Directory(dir).listSync();

    String? configFilePath;

    for (var file in fileList) {
      if (file.path.endsWith("json")) {
        log("found json config");
        log(file.toString());
        configFilePath = file.path;
      }
    }

    if (configFilePath == null) {
      Future.delayed(Duration.zero, () {
        // again
        showDialog(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: const Text("Google API not configured."),
                content: Text(
                    "Please follow the tutorial in the Github readme and paste the json file from Google API dashboard to the root folder of this app. Restart the app after that."),
                actions: [
                  FilledButton(
                    child: const Text("Exit"),
                    onPressed: () {
                      exit(0);
                    },
                  )
                ],
              );
            });
      });
    } else {
      File file = File(configFilePath);
      String jsonString = await file.readAsString();

      var dataJson = jsonDecode(jsonString);

      GlobalData.gClientId = dataJson["installed"]["client_id"];
      GlobalData.gClientSecret = dataJson["installed"]["client_secret"];

      loadLoginInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    loadClientFile();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.getIsLoggedIn) {
      return SignInScreen();
    } else {
      Client client = authProvider.getClient;
      GlobalData.gClient = client;
      GlobalData.gDriveManager = GDriveManager(client);
      PreferencesManager.setOAuthJson(client.credentials.toJson());
      PreferencesManager.setIsLoggedInBefore(true);
      return DashboardScreen();
    }
  }
}

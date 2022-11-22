import 'dart:developer';

import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:desktop_experiments/functions/googleoauthmanager.dart';
import 'package:desktop_experiments/functions/preferencesmanager.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/pages/mainpage/components/dashboard_screen.dart';
import 'package:desktop_experiments/pages/mainpage/components/sign_in_screen.dart';
import 'package:desktop_experiments/providers/auth_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
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

  @override
  void initState() {
    super.initState();
    loadLoginInfo();
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

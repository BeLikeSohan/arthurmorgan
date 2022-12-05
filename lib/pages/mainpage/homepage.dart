import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:arthurmorgan/functions/gdrivemanager.dart';
import 'package:arthurmorgan/functions/preferencesmanager.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/pages/mainpage/screens/dashboard_screen.dart';
import 'package:arthurmorgan/pages/mainpage/screens/sign_in_screen.dart';
import 'package:arthurmorgan/providers/auth_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:oauth2/oauth2.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.getIsLoggedIn) {
      return const SignInScreen();
    } else {
      Client client = authProvider.getClient;
      GlobalData.gClient = client;
      GlobalData.gDriveManager = GDriveManager(client);
      PreferencesManager.setOAuthJson(client.credentials.toJson());
      return const DashboardScreen();
    }
  }
}

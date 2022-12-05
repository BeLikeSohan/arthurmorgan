import 'package:arthurmorgan/functions/googleoauthmanager.dart';
import 'package:arthurmorgan/functions/preferencesmanager.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  Client? client;

  void initiateLogin() {
    GoogleOAuthManager().login().then((_) {
      client = _;
      isLoggedIn = true;
      PreferencesManager.setIsLoggedInBefore(true);
      notifyListeners();
    });
  }

  void loadOAuthInformation(String oauthjson) {
    GoogleOAuthManager().createClientFromCreds(oauthjson).then((_) {
      client = _;
      isLoggedIn = true;

      notifyListeners();
    });
  }

  void logout(BuildContext context) async {
    Provider.of<GDriveProvider>(context, listen: false).logout();
    await PreferencesManager.removeLoginInfo();
    await PreferencesManager.setIsLoggedInBefore(false);
    isLoggedIn = false;
    client = null;
    notifyListeners();
  }

  get getIsLoggedIn {
    return isLoggedIn;
  }

  get getClient {
    return client;
  }
}

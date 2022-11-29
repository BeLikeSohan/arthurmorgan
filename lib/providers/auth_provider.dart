import 'package:arthurmorgan/functions/googleoauthmanager.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  Client? client;

  void initiateLogin() {
    GoogleOAuthManager().login().then((_) {
      client = _;
      isLoggedIn = true;
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

  get getIsLoggedIn {
    return isLoggedIn;
  }

  get getClient {
    return client;
  }
}

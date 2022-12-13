import 'dart:developer';

import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:flutter/material.dart';
import 'package:libmorgan/libmorgan.dart';

class GDriveProvider extends ChangeNotifier {
  List<GFile>? files = [];
  bool fileListFetched = false; // TODO: PATCH
  UserState userState = UserState.undetermined;
  bool isLoggedIn =
      false; // THIS isLoggedIn is not google login, the internal login method using verify file

  void getFileList() async {
    files = await GlobalData.gDriveManager!.getFiles();
    fileListFetched = true;
    notifyListeners();
  }

  void setUserState() async {
    var isNew = await GlobalData.gDriveManager!.checkIfNewUser();
    if (isNew) {
      userState = UserState.noninitiated;
    } else {
      userState = UserState.initiated;
    }
    notifyListeners();
  }

  void setupArthurMorgan(String password) async {
    GlobalData.gMorgan = Morgan(password, 16);
    var verifyString = GlobalData.gMorgan!.genVerifyString();
    var result =
        await GlobalData.gDriveManager!.setupArthurMorgan(verifyString);
    if (result) {
      userState = UserState.initiated;
    } else {
      GlobalData.logger.d("error");
    }
    notifyListeners();
  }

  void login(String password) async {
    var verifyFileMedia = await GlobalData.gDriveManager!.getVerifyFile();

    List<int> verifyFileBytes = [];

    verifyFileMedia.stream.listen((data) {
      verifyFileBytes.insertAll(verifyFileBytes.length, data);
    }, onDone: () {
      // GlobalData.logger.d("Verify DL Done");
      // GlobalData.logger.d(String.fromCharCodes(verifyFileBytes));
      // var result = FileHandler.checkPassword(
      //     password, String.fromCharCodes(verifyFileBytes));
      // if (result) {
      //   //FileHandler.init(password);
      //   isLoggedIn = true;
      //   notifyListeners();
      // } else {
      //   isLoggedIn = false; // why not
      //   notifyListeners();
      // }
      isLoggedIn =
          FileHandler.init(password, String.fromCharCodes(verifyFileBytes));
      GlobalData.logger.d(isLoggedIn.toString());
      notifyListeners();
    }, onError: (error) {
      GlobalData.logger.d("Verify DL Some Error");
      notifyListeners();
    });
  }

  void logout() {
    userState = UserState.undetermined;
    isLoggedIn = false;
    files = [];
    fileListFetched = false;
    notifyListeners();
  }

  get getFiles {
    return files;
  }

  get getFileListFetched {
    return fileListFetched;
  }

  get getUserState {
    return userState;
  }

  get getIsLoggedIn {
    return isLoggedIn;
  }
}

import 'dart:developer';

import 'package:desktop_experiments/enums.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/models/gfile.dart';
import 'package:flutter/material.dart';

class GDriveProvider extends ChangeNotifier {
  List<GFile>? files;
  bool fileListFetched = false;
  UserState userState = UserState.undetermined;

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

  get getFiles {
    return files;
  }

  get getFileListFetched {
    return fileListFetched;
  }

  get getUserState {
    return userState;
  }
}

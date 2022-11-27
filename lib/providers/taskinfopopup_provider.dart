import 'package:flutter/material.dart';

class TaskInfoPopUpProvider extends ChangeNotifier {
  bool isShow = false;
  String taskTitle = "";

  void show(String _) {
    isShow = true;
    taskTitle = _;
    notifyListeners();
  }

  void hide() {
    isShow = false;
    notifyListeners();
  }

  get getIsShow {
    return isShow;
  }

  get getTaskTitle {
    return taskTitle;
  }
}

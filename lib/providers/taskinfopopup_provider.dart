import 'package:flutter/material.dart';

class TaskInfoPopUpProvider extends ChangeNotifier {
  bool isShow = false;
  String taskTitle = "";
  double progress = 0;

  void show(String _) {
    isShow = true;
    taskTitle = _;
    notifyListeners();
  }

  void hide() {
    isShow = false;
    notifyListeners();
  }

  void setProgress(double i) {
    progress = i;
    notifyListeners();
  }

  get getIsShow {
    return isShow;
  }

  get getTaskTitle {
    return taskTitle;
  }

  get getProgress {
    return progress;
  }
}

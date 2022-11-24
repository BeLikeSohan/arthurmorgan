import 'package:desktop_experiments/models/gfile.dart';
import 'package:flutter/cupertino.dart';

class FileInfoSheetProvider extends ChangeNotifier {
  bool isOpen = false;
  GFile? currentSelectedFile;

  void setIsOpen(bool value) {
    isOpen = value;
    notifyListeners();
  }

  void setCurrentGFile(GFile gfile) {
    currentSelectedFile = gfile;
    setIsOpen(true);
    notifyListeners();
  }

  get getIsOpen {
    return isOpen;
  }

  get getcurrentSelectedFile {
    return currentSelectedFile;
  }
}

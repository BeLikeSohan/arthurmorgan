import 'dart:developer';

import 'package:desktop_experiments/enums.dart';
import 'package:desktop_experiments/functions/filehandler.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/models/gfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class FileInfoSheetProvider extends ChangeNotifier {
  bool isOpen = false;
  GFile? currentSelectedFile;
  List<int> encryptedPreviewData = [];
  PreviewLoadState previewLoadState = PreviewLoadState.notloaded;
  Uint8List? previewData;

  void setIsOpen(bool value) {
    isOpen = value;
    notifyListeners();
  }

  void setCurrentGFile(GFile gfile) {
    currentSelectedFile = gfile;
    setIsOpen(true);
    encryptedPreviewData = [];
    previewLoadState = PreviewLoadState.notloaded;
    notifyListeners();
  }

  void loadAndDecryptPreview() async {
    previewLoadState = PreviewLoadState.loading;
    notifyListeners();
    var stream =
        await GlobalData.gDriveManager!.downloadFile(currentSelectedFile!);
    stream.listen((data) {
      encryptedPreviewData.insertAll(encryptedPreviewData.length, data);
    }, onDone: () {
      log("DL Done");
      previewData =
          FileHandler.decryptUintList(Uint8List.fromList(encryptedPreviewData));
      previewLoadState = PreviewLoadState.loaded;
      notifyListeners();
    }, onError: (error) {
      log("Some Error");
      notifyListeners();
    });
  }

  get getIsOpen {
    return isOpen;
  }

  get getcurrentSelectedFile {
    return currentSelectedFile;
  }

  get getPreviewLoadState {
    return previewLoadState;
  }

  get getPreviewData {
    return previewData;
  }
}

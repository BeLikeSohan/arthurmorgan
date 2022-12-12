import 'dart:developer';
import 'dart:io';

import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/providers/encryption_upload_provider.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

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
        await GlobalData.gDriveManager!.downloadThumbnail(currentSelectedFile!);
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

  void saveToDisk(BuildContext context) async {
    if (currentSelectedFile!.mimeType!.startsWith("video")) {
      Provider.of<EncryptionUploadProvider>(context, listen: false)
          .downloadAndDecryptVideo(context, currentSelectedFile!);
    } else if (currentSelectedFile!.mimeType!.startsWith("image")) {
      Provider.of<EncryptionUploadProvider>(context, listen: false)
          .downloadAndDecryptImage(context, currentSelectedFile!);
    }
    // Provider.of<TaskInfoPopUpProvider>(context, listen: false)
    //     .show("Downloading ${currentSelectedFile!.name}");

    // double totalGetLen = 0;

    // String docDir = GlobalData.gAppDocDir!.path;

    // String tempPath =
    //     path.join(docDir, "ArthurMorgan", "Downloads", "temp.jpeg");

    // File tempFile = File(tempPath);

    // var stream =
    //     await GlobalData.gDriveManager!.downloadFile(currentSelectedFile!);
    // stream.listen((data) {
    //   //encryptedData.insertAll(encryptedData.length, data);
    //   tempFile.writeAsBytesSync(data, mode: FileMode.append);
    //   totalGetLen += double.parse(data.length);
    //   Provider.of<TaskInfoPopUpProvider>(context, listen: false)
    //       .setProgress((totalGetLen / currentSelectedFile!.size) * 100);
    // }, onDone: () {
    //   log("Download (Save to disk)");
    //   Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();

    //   String savePath = path.join(
    //       docDir, "ArthurMorgan", "Downloads", currentSelectedFile!.name);

    //   log(savePath);

    //   //data = FileHandler.decryptUintList(Uint8List.fromList(encryptedData));

    //   // File(savePath).create(recursive: true).then((saveFile) {
    //   //   //saveFile.writeAsBytes(data);
    //   //   log("SAVE TO DISK DONE");
    //   //   Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    //   // });
    // }, onError: (error) {
    //   log("Download (Save to disk) error");
    // });
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

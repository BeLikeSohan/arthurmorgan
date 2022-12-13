import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/providers/encryption_upload_provider.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:arthurmorgan/windowtitlebar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  void uploadFile(BuildContext context) async {
    // TODO: MOVE THIS
    GlobalData.logger.d("upload start");
    var files = await FileHandler.getFile();
    if (files == null) return;
    // showUploadingDialog(context); // ok next time thanks for the warning

    var encryptionProvider =
        Provider.of<EncryptionUploadProvider>(context, listen: false);

    encryptionProvider.uploadFiles(context, files);
    // int i = 1;
    //for (File file in files) {
    // Provider.of<TaskInfoPopUpProvider>(context, listen: false).show(
    //     "Uploading ${file.path.split("\\").last} ($i / ${files.length})");

    //encryptionProvider.startVideoEncryption(context, file);
    // var encryptedFile = await FileHandler.encryptFile(file);
    // if (encryptedFile != null) {
    //   var stream =
    //       await FileHandler.getStreamFromFile(encryptedFile!.encryptedFile);
    //   await GlobalData.gDriveManager!.uploadFile(
    //       encryptedFile.encryptedName, encryptedFile.length, stream);
    //   GlobalData.logger.d("done");
    // }
    // FileHandler.encryptFile(file);
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (GlobalData.isEncryptionCompleted) {
    //     GlobalData.logger.d("is encrypting");
    //     Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    //     Provider.of<GDriveProvider>(context, listen: false).getFileList();
    //   } else if (!GlobalData.isEncryptionCompleted &&
    //       GlobalData.isCurrentlyEncrypting) {
    //     GlobalData.logger.d("encrypt done");
    //     timer.cancel();
    //   }
    // });
    // i++;
    //}

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 5),
                      child: FlutterLogo(),
                    ),
                    Text(
                      "Arthur Morgan",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 3, right: 5),
                  child: Button(
                    child: Text("Upload"),
                    onPressed: () {
                      uploadFile(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3, right: 5),
                  child: Button(
                    child: Text("New Folder"),
                    onPressed: null,
                  ),
                )
              ],
            ),
          ),
          WindowButtons()
        ],
      ),
    );
  }
}

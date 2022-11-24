import 'dart:developer';

import 'package:desktop_experiments/enums.dart';
import 'package:desktop_experiments/functions/filehandler.dart';
import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/providers/fileinfosheet_provider.dart';
import 'package:desktop_experiments/providers/gdrive_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:googleapis/servicemanagement/v1.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void showNewUserDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("New User!"),
            content: const Text(
                "Lorem ipsum dolor sit amet. Nam repellendus voluptate eos fuga dolorem et nihil saepe non ullam voluptates est deserunt molestias. 33 ducimus iure in distinctio voluptates ex sint recusandae vel soluta atque ut dolor"),
            actions: [
              Button(
                child: const Text("Not now"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: const Text("Setup Arthur Morgan"),
                onPressed: () {
                  Navigator.pop(context);
                  setupArthurMorganDialog(context);
                },
              ),
            ],
          );
        });
  }

  void setupArthurMorganDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("Setup Arthur Morgan"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  Text(
                      "This will create a folder named 'ArthurMorgan' in your GDrive root directory."),
                  SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Password",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Confirm Password",
                  )
                ],
              ),
            ),
            actions: [
              Button(
                child: const Text("Not now"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                  child: const Text("Setup Arthur Morgan"),
                  onPressed: () {
                    Navigator.pop(context);
                    GlobalData.gDriveManager!.setupArthurMorgan().then((_) {
                      if (!_) {
                        log("failed");
                      } else {
                        setState(() {});
                      }
                    });
                  }),
            ],
          );
        });
  }

  void uploadFile() async {
    log("upload start");
    var file = await FileHandler.getFile();
    if (file == null) return;
    var encryptedFile = await FileHandler.encryptFile(file, "test1test");
    var stream =
        await FileHandler.getStreamFromFile(encryptedFile.encryptedFile);
    await GlobalData.gDriveManager!
        .uploadFile(encryptedFile.encryptedName, encryptedFile.length, stream);
    log("done");
  }

  // void checkIfNewUser() async {
  //   GlobalData.gDriveManager!.checkIfNewUser().then((isNew) {
  //     if (isNew) {
  //
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    Provider.of<GDriveProvider>(context, listen: false).setUserState();
  }

  @override
  Widget build(BuildContext context) {
    var gdriveProvider = Provider.of<GDriveProvider>(context);

    if (gdriveProvider.getUserState == UserState.initiated &&
        !gdriveProvider.getFileListFetched) {
      gdriveProvider.getFileList();
    }

    if (gdriveProvider.getFileListFetched) {
      return BodyWithSideSheet(
        sheetWidth: 350,
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    child: Text("Upload"),
                    onPressed: () {
                      uploadFile();
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Button(
                    child: Text("Download All"),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Button(
                    child: Text("New Folder"),
                    onPressed: () {},
                  )
                ],
              ),
              Expanded(child: FileListGrid())
            ],
          ),
        ),
        sheetBody: FileInfoSheet(),
        show: Provider.of<FileInfoSheetProvider>(context).getIsOpen,
      );
    }

    return Container(
      child: Center(
        child: ProgressRing(),
      ),
    );
  }
}

class FileListGrid extends StatelessWidget {
  const FileListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    var gdriveProvider = Provider.of<GDriveProvider>(context);

    return Container(
      margin: EdgeInsets.only(top: 10),
      //height: double.infinity,
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 100,
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: gdriveProvider.getFiles.length,
          itemBuilder: ((context, index) {
            return Button(
              onPressed: () {
                Provider.of<FileInfoSheetProvider>(context, listen: false)
                    .setCurrentGFile(gdriveProvider.getFiles[index]);
              },
              child: Container(
                margin: EdgeInsets.all(2),
                child: Column(
                  children: [
                    const Expanded(
                        child: Icon(
                      FluentIcons.photo2,
                      size: 30,
                    )),
                    Text(gdriveProvider.getFiles[index].name)
                  ],
                ),
              ),
            );
          })),
    );
  }
}

class FileInfoSheet extends StatelessWidget {
  const FileInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var fileinfosheetprovider = Provider.of<FileInfoSheetProvider>(context);
    if (!fileinfosheetprovider.getIsOpen) return ProgressRing();
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Container(
              height: 200,
              child: Button(
                child: Text("Show Preview"),
                onPressed: () {
                  GlobalData.gDriveManager!.downloadFile(
                      fileinfosheetprovider.getcurrentSelectedFile);
                },
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "File Details",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Name",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.name,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Size",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.size.toString(),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Created",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.createdTime.toString(),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:desktop_experiments/enums.dart';
import 'package:desktop_experiments/functions/filehandler.dart';
import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:desktop_experiments/pages/mainpage/screens/components/taskinfopopup.dart';
import 'package:desktop_experiments/providers/fileinfosheet_provider.dart';
import 'package:desktop_experiments/providers/gdrive_provider.dart';
import 'package:desktop_experiments/providers/taskinfopopup_provider.dart';
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
    TextEditingController passwordController = TextEditingController();
    TextEditingController passwordConfirmController = TextEditingController();

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
                    controller: passwordController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Confirm Password",
                    controller: passwordConfirmController,
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
                    if (passwordController.text !=
                            passwordConfirmController.text &&
                        passwordController.text.isEmpty) {
                      log("password mismatch");
                      return;
                    }
                    Provider.of<GDriveProvider>(context, listen: false)
                        .setupArthurMorgan(passwordController.text);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  void showUploadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("Uploading"),
            content: Container(
              height: 50,
              child: Column(
                children: [
                  Text("Encrypting and uploading file to GDrive"),
                  SizedBox(
                    height: 25,
                  ),
                  ProgressBar(),
                ],
              ),
            ),
          );
        });
  }

  void uploadFile() async {
    // TODO: MOVE THIS
    log("upload start");
    var files = await FileHandler.getFile();
    if (files == null) return;
    // showUploadingDialog(context); // ok next time thanks for the warning

    for (File file in files) {
      Provider.of<TaskInfoPopUpProvider>(context, listen: false)
          .show("Uploading ${file.path.split("\\").last}");
      var encryptedFile = await FileHandler.encryptFile(file);
      var stream =
          await FileHandler.getStreamFromFile(encryptedFile.encryptedFile);
      await GlobalData.gDriveManager!.uploadFile(
          encryptedFile.encryptedName, encryptedFile.length, stream);
      log("done");
    }

    // Navigator.pop(context);
    Provider.of<TaskInfoPopUpProvider>(context, listen: false).hide();
    Provider.of<GDriveProvider>(context, listen: false).getFileList();
  }

  void loginDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("Login"),
            content: Container(
              height: 90,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "'ArthurMorgan' is installed in this GDrive, enter the password to continue"),
                  SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Password",
                    controller: passwordController,
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: const Text("Exit"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                  child: const Text("Login"),
                  onPressed: () {
                    Provider.of<GDriveProvider>(context, listen: false)
                        .login(passwordController.text);
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<GDriveProvider>(context, listen: false).setUserState();
  }

  @override
  Widget build(BuildContext context) {
    var gdriveProvider = Provider.of<GDriveProvider>(context);

    if (gdriveProvider.getUserState == UserState.noninitiated) {
      Future.delayed(Duration.zero, () async {
        // this thing works but not sure if its a good practice
        showNewUserDialog(context);
      });
    }

    if (gdriveProvider.getUserState == UserState.initiated &&
        !gdriveProvider.getIsLoggedIn) {
      Future.delayed(Duration.zero, () async {
        // this thing works but not sure if its a good practice
        loginDialog(context);
      });
    }

    if (gdriveProvider.getUserState == UserState.initiated &&
        gdriveProvider.getIsLoggedIn &&
        !gdriveProvider.getFileListFetched) {
      gdriveProvider.getFileList();
    }

    if (gdriveProvider.getFileListFetched) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          BodyWithSideSheet(
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
                        onPressed: null,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Button(
                        child: Text("New Folder"),
                        onPressed: null,
                      )
                    ],
                  ),
                  Expanded(child: FileListGrid())
                ],
              ),
            ),
            sheetBody: FileInfoSheet(),
            show: Provider.of<FileInfoSheetProvider>(context).getIsOpen,
          ),
          TaskInfoPopup()
        ],
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

  Widget previewWidget(var fileinfosheetprovider) {
    // refactor it pls
    if (fileinfosheetprovider.getPreviewLoadState ==
        PreviewLoadState.notloaded) {
      return Card(
        child: Container(
          height: 250,
          child: Center(
              child: Button(
            child: Text("Show Preview"),
            onPressed: () {
              fileinfosheetprovider.loadAndDecryptPreview();
            },
          )),
        ),
      );
    } else if (fileinfosheetprovider.getPreviewLoadState ==
        PreviewLoadState.loading) {
      return Card(
        child: Container(height: 250, child: Center(child: ProgressRing())),
      );
    } else {
      return Card(
        child: Container(
            height: 250,
            child: Image.memory(fileinfosheetprovider.getPreviewData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var fileinfosheetprovider = Provider.of<FileInfoSheetProvider>(context);
    if (!fileinfosheetprovider.getIsOpen) return Center(child: ProgressRing());
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          previewWidget(fileinfosheetprovider),
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
          SizedBox(
            height: 20,
          ),
          Button(
            child: Text("Download"),
            onPressed: () {
              fileinfosheetprovider.saveToDisk(context);
            },
          )
        ],
      ),
    );
  }
}

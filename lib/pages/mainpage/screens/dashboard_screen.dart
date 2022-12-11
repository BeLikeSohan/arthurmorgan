import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:arthurmorgan/enums.dart';
import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/functions/preferencesmanager.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/pages/mainpage/screens/components/filelistgrid.dart';
import 'package:arthurmorgan/pages/mainpage/screens/components/taskinfopopup.dart';
import 'package:arthurmorgan/providers/fileinfosheet_provider.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mime/mime.dart';
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
            content: SizedBox(
              height: 130,
              child: Column(
                children: [
                  const Text(
                      "This will create a folder named 'ArthurMorgan' in your GDrive root directory."),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Password",
                    controller: passwordController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Confirm Password",
                    controller: passwordConfirmController,
                  ),
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

  void selectRootFolderDialog(BuildContext context) async {
    if (PreferencesManager.getCustomRootFolderName() != null) {
      GlobalData.gCustomRootFolder =
          PreferencesManager.getCustomRootFolderName();
      Provider.of<GDriveProvider>(context, listen: false).setUserState();
      return;
    }

    TextEditingController rootFolderController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("Select root folder"),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  const Text(
                      "Enter the folder name where ArthurMorgan is/should be installed. Leave empty to use the root folder."),
                  const SizedBox(
                    height: 10,
                  ),
                  TextBox(
                    placeholder: "Folder name",
                    controller: rootFolderController,
                  ),
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
                  child: const Text("Next"),
                  onPressed: () {
                    if (rootFolderController.text.isNotEmpty) {
                      GlobalData.gCustomRootFolder = rootFolderController.text;
                      PreferencesManager.setCustomRootFolderName(
                          rootFolderController.text);
                    }
                    Navigator.pop(context);
                    Provider.of<GDriveProvider>(context, listen: false)
                        .setUserState();
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
            content: SizedBox(
              height: 50,
              child: Column(
                children: const [
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

  void loginDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("Login"),
            content: SizedBox(
              height: 90,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      "'ArthurMorgan' is installed in this GDrive, enter the password to continue"),
                  const SizedBox(
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
  }

  @override
  Widget build(BuildContext context) {
    var gdriveProvider = Provider.of<GDriveProvider>(context);

    if (gdriveProvider.getUserState == UserState.undetermined) {
      Future.delayed(Duration.zero, () async {
        // this thing works but not sure if its a good practice
        selectRootFolderDialog(context);
      });
    }

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
              margin: const EdgeInsets.only(left: 15, top: 29, right: 15),
              child: FileListGrid(),
            ),
            sheetBody: const FileInfoSheet(),
            show: Provider.of<FileInfoSheetProvider>(context).getIsOpen,
          ),
          const TaskInfoPopup()
        ],
      );
    }

    return const Center(
      child: ProgressRing(),
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
        child: SizedBox(
          height: 250,
          child: Center(
              child: Button(
            child: const Text("Show Preview"),
            onPressed: () {
              fileinfosheetprovider.loadAndDecryptPreview();
            },
          )),
        ),
      );
    } else if (fileinfosheetprovider.getPreviewLoadState ==
        PreviewLoadState.loading) {
      return const Card(
        child: SizedBox(height: 250, child: Center(child: ProgressRing())),
      );
    } else {
      return Card(
        child: SizedBox(
            height: 250,
            child: Image.memory(fileinfosheetprovider.getPreviewData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var fileinfosheetprovider = Provider.of<FileInfoSheetProvider>(context);

    if (!fileinfosheetprovider.getIsOpen) {
      return const Center(child: ProgressRing());
    }

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 39),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lookupMimeType(fileinfosheetprovider.currentSelectedFile!.name)!
              .startsWith("image"))
            previewWidget(fileinfosheetprovider),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "File Details",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Name",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.name,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Size",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.size.toString(),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Created",
          ),
          Text(
            fileinfosheetprovider.getcurrentSelectedFile.createdTime.toString(),
          ),
          const SizedBox(
            height: 20,
          ),
          Button(
            child: const Text("Download"),
            onPressed: () {
              fileinfosheetprovider.saveToDisk(context);
            },
          )
        ],
      ),
    );
  }
}

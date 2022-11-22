import 'dart:developer';

import 'package:desktop_experiments/functions/gdrivemanager.dart';
import 'package:desktop_experiments/global_data.dart';
import 'package:fluent_ui/fluent_ui.dart';

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

  void checkIfNewUser() async {
    GlobalData.gDriveManager!.checkIfNewUser().then((isNew) {
      if (isNew) {
        showNewUserDialog(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfNewUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ProgressRing(),
      ),
    );
  }
}

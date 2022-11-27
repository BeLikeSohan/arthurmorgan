import 'package:desktop_experiments/providers/taskinfopopup_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class TaskInfoPopup extends StatelessWidget {
  const TaskInfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    var taskInfoProvider = Provider.of<TaskInfoPopUpProvider>(context);
    return taskInfoProvider.getIsShow
        ? Container(
            width: 300,
            margin: EdgeInsets.all(15),
            child: InfoBar(
              title: Text(taskInfoProvider.getTaskTitle),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  ProgressBar(),
                ],
              ),
              severity: InfoBarSeverity.info,
            ))
        : Container();
  }
}

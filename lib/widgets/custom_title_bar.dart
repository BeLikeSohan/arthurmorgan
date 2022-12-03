import 'package:arthurmorgan/windowtitlebar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

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
                    )
                  ],
                ),
              ),
            ),
          ),
          WindowButtons()
        ],
      ),
    );
  }
}

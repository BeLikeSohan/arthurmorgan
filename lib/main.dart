import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/pages/mainpage/homepage.dart';
import 'package:arthurmorgan/providers/auth_provider.dart';
import 'package:arthurmorgan/providers/fileinfosheet_provider.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:arthurmorgan/windowtitlebar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  await Window.setEffect(
    effect: WindowEffect.aero,
    color: Color(0xCC222222),
  );

  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 720);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.centerRight;
    win.title = "ArthurMorgan";
    win.show();
  });

  GlobalData.gAppDocDir = await getApplicationDocumentsDirectory();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: GDriveProvider(),
        ),
        ChangeNotifierProvider.value(
          value: FileInfoSheetProvider(),
        ),
        ChangeNotifierProvider.value(
          value: TaskInfoPopUpProvider(),
        ),
      ],
      child: FluentApp(
        title: "ArthurMorgan",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(accentColor: Colors.blue, brightness: Brightness.dark),
        themeMode: ThemeMode.dark,
        home: const MainWindow(),
      ),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  int currentTabIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationPaneTheme(
      data: NavigationPaneThemeData(backgroundColor: Colors.transparent),
      child: NavigationView(
        appBar: NavigationAppBar(
          title: MoveWindow(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Arthur Morgan"),
            ),
          ),
          actions: WindowTitleBar(
            brightness: InterfaceBrightness.dark,
          ),
        ),
        pane: NavigationPane(
          selected: currentTabIndex,
          onChanged: (index) => setState(() => currentTabIndex = index),
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text("Home"),
              body: const HomePage(),
            ),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.teamwork),
              title: const Text("About"),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text("ArthurMorgan"),
                  Text("Version 0.1.1 - Dev"),
                  Text("github.com/belikesohan/arthurmorgan")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

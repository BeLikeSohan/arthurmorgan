import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_experiments/pages/mainpage/homepage.dart';
import 'package:desktop_experiments/providers/auth_provider.dart';
import 'package:desktop_experiments/providers/gdrive_provider.dart';
import 'package:desktop_experiments/windowtitlebar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import 'enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(700, 500);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window with Flutter";
    win.show();
  });
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
      ],
      child: FluentApp(
        title: 'Flutter Demo',
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
    return SafeArea(
      child: NavigationView(
        appBar: NavigationAppBar(
          title: Text("Desktop Experiments"),
          leading: Container(
            child: Icon(FluentIcons.visual_studio_for_windows),
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
              body: HomePage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.photo2),
              title: const Text("Files"),
              body: Container(),
            ),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text("Settings"),
              body: HomePage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.teamwork),
              title: const Text("About"),
              body: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:arthurmorgan/functions/preferencesmanager.dart';
import 'package:arthurmorgan/pages/settings/settings.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/pages/mainpage/homepage.dart';
import 'package:arthurmorgan/providers/auth_provider.dart';
import 'package:arthurmorgan/providers/encryption_upload_provider.dart';
import 'package:arthurmorgan/providers/fileinfosheet_provider.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:arthurmorgan/providers/settings_provider.dart';
import 'package:arthurmorgan/providers/taskinfopopup_provider.dart';
import 'package:arthurmorgan/widgets/custom_title_bar.dart';
import 'package:arthurmorgan/windowtitlebar.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();
  await WindowManager.instance.ensureInitialized();

  PreferencesManager.init();
  GlobalData.gAppDocDir = await getApplicationDocumentsDirectory();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    //await windowManager.setSize(const Size(755, 545));
    //await windowManager.setMinimumSize(const Size(350, 600));
    await windowManager.center();
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
    await Window.setEffect(
      effect: WindowEffect.mica,
      color: Color(0xCC222222),
    );
  });

  runApp(const MyApp());
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
        ChangeNotifierProvider.value(
          value: SettingsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: EncryptionUploadProvider(),
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

  void loadLoginInfo() async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    if ((await PreferencesManager.isLoggedInBefore())) {
      String oauthJson = await PreferencesManager.getOAuthJson();
      authProvider.loadOAuthInformation(oauthJson);
    }
  }

  void loadClientFile() async {
    String dir = Directory.current.path;
    log(dir);
    List fileList = Directory(dir).listSync();

    String? configFilePath;

    for (var file in fileList) {
      if (file.path.endsWith("json")) {
        log("found json config");
        log(file.toString());
        configFilePath = file.path;
      }
    }

    if (configFilePath == null) {
      Future.delayed(Duration.zero, () {
        // again
        showDialog(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: const Text("Google API not configured."),
                content: const Text(
                    "Please follow the tutorial in the Github readme and paste the json file from Google API dashboard to the root folder of this app. Restart the app after that."),
                actions: [
                  FilledButton(
                    child: const Text("Exit"),
                    onPressed: () {
                      exit(0);
                    },
                  )
                ],
              );
            });
      });
    } else {
      File file = File(configFilePath);
      String jsonString = await file.readAsString();

      var dataJson = jsonDecode(jsonString);

      GlobalData.gClientId = dataJson["installed"]["client_id"];
      GlobalData.gClientSecret = dataJson["installed"]["client_secret"];

      loadLoginInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    loadClientFile();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationPaneTheme(
      data: NavigationPaneThemeData(backgroundColor: Colors.transparent),
      child: Stack(alignment: Alignment.topRight, children: [
        NavigationView(
          // appBar: NavigationAppBar(
          //   title: DragToMoveArea(
          //     child: Align(
          //       alignment: AlignmentDirectional.centerStart,
          //       child: Text("Arthur Morgan"),
          //     ),
          //   ),
          //   actions: WindowButtons(),
          // ),
          contentShape: RoundedRectangleBorder(),
          pane: NavigationPane(
            selected: currentTabIndex,
            onChanged: (index) => setState(() => currentTabIndex = index),
            displayMode: PaneDisplayMode.open,
            header: SizedBox(
              height: 30,
            ),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Home"),
                body: const HomePage(),
              ),
            ],
            footerItems: [
              PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text("Settings"),
                  body: SettingsPage()),
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
        CustomTitleBar(),
      ]),
    );
  }
}

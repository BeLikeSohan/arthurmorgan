import 'package:arthurmorgan/consts.dart';
import 'package:arthurmorgan/providers/settings_provider.dart';
import 'package:arthurmorgan/widgets/expandable_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:googleapis/servicemanagement/v1.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text("Settings"),
      ),
      children: [
        _ThemeModeSection(),
        _WindowStyleSection(),
        ExpandableCard(
          header: Text("Account Information"),
          trailingActions: [
            Button(
              child: Text("Logout"),
              onPressed: () {},
            )
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: hello.soilcsi@gmail.com"),
              Text("Identifier: 3203412948uurdcgeutf784")
            ],
          ),
        ),
        spacer,
        ExpandableCard(
          header: Text("Encryption Information"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Algorithm: 256bit AES-CBC"),
              Text("Key: **********************")
            ],
          ),
        ),
        spacer,
        ExpandableCard(
          header: Text("Software Information"),
          trailingActions: [
            Button(
              child: Text("Check for updates"),
              onPressed: () {},
            )
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Version: 0.1.1-dev-arthurmorgan"),
              Text("Backend: libarthurmorgan-0.1.0")
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeSection extends StatelessWidget {
  const _ThemeModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Theme Mode", style: FluentTheme.of(context).typography.subtitle),
        spacer,
        RadioButton(
          checked: settingsProvider.currentThemeMode == "light",
          onChanged: (value) {
            if (value) settingsProvider.setThemeMode("light");
          },
          content:
              Text("Light", style: FluentTheme.of(context).typography.body),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.currentThemeMode == "dark",
          onChanged: (value) {
            if (value) settingsProvider.setThemeMode("dark");
          },
          content: Text("Dark"),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.currentThemeMode == "system",
          onChanged: (value) {
            if (value) settingsProvider.setThemeMode("system");
          },
          content: Text("System"),
        ),
        biggerSpacer
      ],
    );
  }
}

class _WindowStyleSection extends StatelessWidget {
  const _WindowStyleSection({super.key});

  @override
  Widget build(BuildContext context) {
    var settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Window Style",
            style: FluentTheme.of(context).typography.subtitle),
        spacer,
        RadioButton(
          checked: settingsProvider.windowStyle == "opaque",
          onChanged: (value) {
            if (value) settingsProvider.setWindowStyle("opaque");
          },
          content:
              Text("Opaque", style: FluentTheme.of(context).typography.body),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.windowStyle == "transparent",
          onChanged: (value) {
            if (value) settingsProvider.setWindowStyle("transparent");
          },
          content: Text("Transparent"),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.windowStyle == "aero",
          onChanged: (value) {
            if (value) settingsProvider.setWindowStyle("aero");
          },
          content: Text("Aero"),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.windowStyle == "acrylic",
          onChanged: (value) {
            if (value) settingsProvider.setWindowStyle("acrylic");
          },
          content: Text("Acrylic"),
        ),
        spacer,
        RadioButton(
          checked: settingsProvider.windowStyle == "mica",
          onChanged: (value) {
            if (value) settingsProvider.setWindowStyle("mica");
          },
          content: Text("Mica"),
        ),
        biggerSpacer
      ],
    );
  }
}

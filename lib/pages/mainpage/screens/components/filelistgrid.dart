import 'package:arthurmorgan/pages/mainpage/screens/components/filebuttonwidget.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class FileListGrid extends StatelessWidget {
  const FileListGrid({super.key});

  @override
  Widget build(BuildContext context) {
    var gdriveProvider = Provider.of<GDriveProvider>(context);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      //height: double.infinity,
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 100,
              maxCrossAxisExtent: 100,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: gdriveProvider.getFiles.length,
          itemBuilder: ((context, index) {
            return FileButtonWidget(
              gdriveProvider: gdriveProvider,
              index: index,
            );
          })),
    );
  }
}

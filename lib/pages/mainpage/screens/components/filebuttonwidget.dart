import 'dart:developer';
import 'dart:typed_data';

import 'package:arthurmorgan/functions/filehandler.dart';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/providers/fileinfosheet_provider.dart';
import 'package:arthurmorgan/providers/gdrive_provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class FileButtonWidget extends StatefulWidget {
  FileButtonWidget(
      {Key? key, required this.gdriveProvider, required this.index})
      : super(key: key);

  final GDriveProvider gdriveProvider;
  final int index;

  @override
  State<FileButtonWidget> createState() => _FileButtonWidgetState();
}

class _FileButtonWidgetState extends State<FileButtonWidget> {
  List<int> encryptedPreviewData = [];
  Uint8List? previewData;

  void loadAndDecryptPreview() async {
    if (!widget.gdriveProvider.getFiles[widget.index].mimeType
        .startsWith("image")) return;
    var stream = await GlobalData.gDriveManager!
        .downloadThumbnail(widget.gdriveProvider.getFiles[widget.index]);
    stream.listen((data) {
      encryptedPreviewData.insertAll(encryptedPreviewData.length, data);
    }, onDone: () {
      log("DL Done");
      previewData =
          FileHandler.decryptUintList(Uint8List.fromList(encryptedPreviewData));
      setState(() {});
    }, onError: (error) {
      log("Some Error");
    });
  }

  Widget getFileIconWidget() {
    GFile file = widget.gdriveProvider.getFiles[widget.index];

    if (file.mimeType == null) {
      return const Center(
        child: Icon(FluentIcons.file_bug),
      );
    } else if (file.mimeType!.startsWith("image")) {
      if (previewData == null) {
        return const Center(
          child: ProgressRing(),
        );
      } else {
        return Image.memory(previewData!);
      }
    }

    return const Center(
      child: Icon(FluentIcons.user_window),
    );
  }

  @override
  void initState() {
    super.initState();
    loadAndDecryptPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: () {
        Provider.of<FileInfoSheetProvider>(context, listen: false)
            .setCurrentGFile(widget.gdriveProvider.getFiles[widget.index]);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Column(
          children: [
            Expanded(
              child: getFileIconWidget(),
            ),
            Text(
              widget.gdriveProvider.getFiles[widget.index].name,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:arthurmorgan/global_data.dart';
import 'package:arthurmorgan/models/encrypted_file.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/utils.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:libmorgan/libmorgan.dart';
import 'package:mime/mime.dart';

class FileHandler {
  static bool init(String password, String verifyString) {
    GlobalData.gMorgan = Morgan(password, 16);
    return GlobalData.gMorgan!.init(verifyString);
  }

  static Future<List<File>?> getFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      return files;
    }

    return null;
  }

  static Future<Stream<List<int>>> getStreamFromFile(File file) async {
    // var binary = await file.readAsBytes();
    // final Stream<List<int>> mediaStream =
    //     Future.value(binary).asStream().asBroadcastStream();
    return file.openRead();
  }

  // static Future<EncryptedFile?> encryptFile(File file) async {
  //   String? mimeType = lookupMimeType(file.path);

  //   if (mimeType!.startsWith("image")) {
  //     String fileName =
  //         GlobalData.gMorgan!.encryptFileName(file.path.split('\\').last);
  //     var imageBytes = GlobalData.gMorgan!.packImage(file);
  //     File("temp.file").writeAsBytesSync(imageBytes);
  //     return EncryptedFile(fileName, imageBytes.length, File("temp.file"));
  //   }
  // }

  static Future<GFile> decryptGfile(GFile gfile) async {
    var decryptedGfile = GFile(
        gfile.id,
        GlobalData.gMorgan!.decryptFileName(gfile.name),
        lookupMimeType(GlobalData.gMorgan!.decryptFileName(gfile.name)),
        gfile.size,
        gfile.createdTime);
    log(decryptedGfile.name);
    return decryptedGfile;
  }

  static Uint8List decryptUintList(Uint8List bytes) {
    return Uint8List.fromList(GlobalData.gMorgan!.getThumbnail(bytes));
  }
}

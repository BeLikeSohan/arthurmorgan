import 'dart:developer';
import 'dart:io';
import 'package:arthurmorgan/models/encrypted_file.dart';
import 'package:arthurmorgan/models/gfile.dart';
import 'package:arthurmorgan/utils.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class FileHandler {
  static FileCryptor? fileCryptor;
  static encrypt.Encrypter? encrypter;
  static encrypt.Key? key;
  static encrypt.IV? iv;

  static void init(String password) {
    fileCryptor = FileCryptor(
      key: Utils.padPassToKey(password),
      iv: 16,
      dir: "example",
    );

    key = encrypt.Key.fromUtf8(Utils.padPassToKey(password));
    iv = encrypt.IV.fromLength(16);

    encrypter = encrypt.Encrypter(encrypt.AES(key!, mode: encrypt.AESMode.cbc));
  }

  static bool checkPassword(String password, String verify) {
    final key = encrypt.Key.fromUtf8(Utils.padPassToKey(password));
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    return encrypter.encrypt("ArthurMorgan", iv: iv).base64 == verify;
  }

  static String createVerifyString(String password) {
    final key = encrypt.Key.fromUtf8(Utils.padPassToKey(password));
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    return encrypter.encrypt("ArthurMorgan", iv: iv).base64;
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

  static Future<EncryptedFile> encryptFile(File file) async {
    final encryptedFileName =
        encrypter!.encrypt(file.path.split("\\").last, iv: iv);

    // String encryptedFileName = String.fromCharCodes(
    //     fileCryptor.encryptUint8List(
    //         data: Uint8List.fromList(file.path
    //             .split("/")
    //             .last
    //             .codeUnits))); // what in the name of fuck is this?

    //String fileName = file.path.split("\\").last;
    File encryptedFile = await fileCryptor!.encrypt(inputFile: file.path);

    return EncryptedFile(encryptedFileName.base64, encryptedFile.lengthSync(),
        encryptedFile); // TODO: not sure if using base64 as filename is a good idea. need to find some algorithm which gives small enough output to use as filename;
  }

  static Future<GFile> decryptGfile(GFile gfile) async {
    var decryptedGfile = GFile(
        gfile.id,
        encrypter!.decrypt64(gfile.name, iv: iv),
        gfile.size,
        gfile.createdTime);
    log(decryptedGfile.name);
    return decryptedGfile;
  }

  static Uint8List decryptUintList(Uint8List bytes) {
    var decryptedBytes = fileCryptor!.decryptUint8List(data: bytes);
    return decryptedBytes;
  }
}

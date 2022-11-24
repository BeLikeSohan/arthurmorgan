import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:desktop_experiments/models/encrypted_file.dart';
import 'package:desktop_experiments/models/gfile.dart';
import 'package:file_cryptor/file_cryptor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

import 'dart:convert';

class FileHandler {
  static Future<File?> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    }

    return null;
  }

  static Future<Stream<List<int>>> getStreamFromFile(File file) async {
    // var binary = await file.readAsBytes();
    // final Stream<List<int>> mediaStream =
    //     Future.value(binary).asStream().asBroadcastStream();
    return file.openRead();
  }

  static Future<EncryptedFile> encryptFile(File file, String password) async {
    FileCryptor fileCryptor = FileCryptor(
      key: "Your 32 bit key.................",
      iv: 16,
      dir: "example",
    );

    final key = encrypt.Key.fromUtf8("Your 32 bit key.................");
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encryptedFileName =
        encrypter.encrypt(file.path.split("\\").last, iv: iv);

    // String encryptedFileName = String.fromCharCodes(
    //     fileCryptor.encryptUint8List(
    //         data: Uint8List.fromList(file.path
    //             .split("/")
    //             .last
    //             .codeUnits))); // what in the name of fuck is this?

    //String fileName = file.path.split("\\").last;
    File encryptedFile = await fileCryptor.encrypt(inputFile: file.path);

    return EncryptedFile(encryptedFileName.base64, encryptedFile.lengthSync(),
        encryptedFile); // TODO: not sure if using base64 as filename is a good idea. need to find some algorithm which gives small enough output to use as filename;
  }

  static Future<GFile> decryptGfile(GFile gfile) async {
    log(gfile.name);
    final key = encrypt.Key.fromUtf8("Your 32 bit key.................");
    final iv = encrypt.IV.fromLength(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    var decryptedGfile = GFile(gfile.id,
        encrypter.decrypt64(gfile.name, iv: iv), gfile.size, gfile.createdTime);
    log(decryptedGfile.name);
    return decryptedGfile;
  }
}

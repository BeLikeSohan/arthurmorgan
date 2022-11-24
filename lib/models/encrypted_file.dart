import 'dart:io';

class EncryptedFile {
  String encryptedName;
  int length;
  File encryptedFile;

  EncryptedFile(this.encryptedName, this.length, this.encryptedFile);
}

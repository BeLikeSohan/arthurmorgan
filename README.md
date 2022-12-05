# arthurmorgan

<a title="Made with Flutter" href="https://github.com/flutter">
  <img
    src="https://img.shields.io/badge/Made%20with-Flutter-blueviolet"
  >
</a>

<a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
  <img
    src="https://img.shields.io/badge/Fluent-Design-blue"
  >
</a>

<a><img src="https://img.shields.io/github/license/belikesohan/arthurmorgan"></a>

A Cross-Platform Google Drive client with encryption support.

![Screenshot](https://raw.githubusercontent.com/BeLikeSohan/arthurmorgan/main/screenshots/screenshot0.png)

---
## Features implemented
 - [X] Google OAuth2
 - [X] Upload Files
 - [X] Download Single Files
 - [X] Upload to shared folder
 - [X] Encrypt/Decrypt Image files
 - [X] Show Preview
 - [ ] Download Multiple Files
 - [ ] Create/Upload Folder
 - [ ] Image Thumbnail

## Installation
Only Windows builds are available to download right now. To run on any other platform you need to build it yourself for now.
Download the binary from the release section, create a Google Cloud Console Project, Enable Google Drive API V3, Setup OAuth, Create credentials for Desktop App, download the client-secret json file and paste it in the root folder of the application.

## Building from source
 - Install Flutter and configure the desktop build tools for your platform
 - Clone this repo
 - run ``` flutter pub get ```
 - run ``` flutter run ```

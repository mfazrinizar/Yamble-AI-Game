import 'dart:io';

class UserYamble {
  File? profilePictureFile;
  String userId;
  String userName;
  String name;
  String? profilePictureUrl;

  UserYamble({
    required this.userId,
    required this.userName,
    required this.name,
    this.profilePictureUrl,
    this.profilePictureFile,
  });
}

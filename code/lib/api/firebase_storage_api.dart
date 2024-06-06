import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseStorageApi {
  static final FirebaseStorage storage = FirebaseStorage.instance;

  // Method for adding a file
  Future<String> uploadFile(File? file, String path) async {
    try {
      // Define a reference
      final Reference reference = storage.ref().child(path);
      UploadTask uploadTask = reference.putFile(file!);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      String dlURL = await storageTaskSnapshot.ref.getDownloadURL();
      return dlURL;
    } on FirebaseException catch (e) {
      return "Report unsuccessfully sent ${e.code}: ${e.message}";
    }
  }

  // Method for updating a file
  Future<String> updateFile(File? file, String path) async {
    try {
      // Define a reference
      final Reference reference = storage.ref().child(path);
      // Delete the old file and replace with a new one
      await storage.ref().child(path).delete();
      UploadTask uploadTask = reference.putFile(file!);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      String dlURL = await storageTaskSnapshot.ref.getDownloadURL();
      return dlURL;
    } on FirebaseException catch (e) {
      return "Report unsuccessfully sent ${e.code}: ${e.message}";
    }
  }

  // Method for deleting a folder
  Future<String> deleteFolder(String path) async {
    try {
      final Reference folderRef = storage.ref().child(path);

      // List all files and directories in the folder
      ListResult result = await folderRef.listAll();

      // Delete each file in the folder
      for (Reference ref in result.items) {
        await ref.delete();
      }

      // Delete each sub-directory in the folder recursively
      for (Reference ref in result.prefixes) {
        await deleteFolder(ref.fullPath);
      }

      return "Folder successfully deleted";
    } on FirebaseException catch (e) {
      return "Error deleting folder ${e.code}: ${e.message}";
    }
  }

  // Method for deleting a file
  Future<String> deleteFIle(String path) async {
    try {
      final Reference fileRef = storage.ref().child(path);

      // Delete the file
      await fileRef.delete();

      return "File successfully deleted";
    } on FirebaseException catch (e) {
      return "Error deleting file ${e.code}: ${e.message}";
    }
  }
}

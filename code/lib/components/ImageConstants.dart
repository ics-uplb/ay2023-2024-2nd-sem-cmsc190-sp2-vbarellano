import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'dart:io';

// Components
import 'Buttons.dart';

// Asynchronous Function for Picking an Image
Future<File?> pickImageFromGallery() async {
  final returnImage = await ImagePicker().getImage(source: ImageSource.gallery);
  if (returnImage == null) return null;

  return File(returnImage.path);
}

// Asynchronous Function for Picking an Image
Future<File?> pickImageFromCamera() async {
  final returnImage = await ImagePicker().getImage(source: ImageSource.camera);
  if (returnImage == null) return null;

  return File(returnImage.path);
}

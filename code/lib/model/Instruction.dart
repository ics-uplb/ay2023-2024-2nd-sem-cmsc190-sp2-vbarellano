import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Components
import '../components/TextField.dart';

class Instruction {
  final int _instructionNumber;
  int get instructionNumber => _instructionNumber;
  final TextEditingController controller = TextEditingController();
  // Instruction Number
  Padding? _label;
  Padding? get label => _label;
  // Textfield
  Widget? _textfield;
  Widget? get textfield => _textfield;
  // Image
  File? image;
  String? image_url;
  bool isShowImageURL = false;
  bool hasImage = false;

  // Constructor
  Instruction(this._instructionNumber) {
    controller.addListener(() {});
    _label = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Instruction $_instructionNumber:",
            style: BODY_TEXT_ITALIC,
          ),
        ));
  }

  removeImage() {
    image = null;
  }

  // Disposing the controller when instruction is removed
  dispose() {
    controller.dispose();
  }

  setImage(String url) {
    image_url = url;
    hasImage = true;
  }
}

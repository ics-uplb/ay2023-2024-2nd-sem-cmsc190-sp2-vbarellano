import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Model
import '../model/Instruction.dart';

class Path {
  List instructionNumbers = [];
  final int _pathNumber;
  int get pathNumber => _pathNumber;
  List<Instruction> _path = [];
  List<Instruction> get path => _path;
  Widget? _widget;
  Widget? get widget => _widget;

  Path(this._pathNumber) {
    _widget = Column(children: [
      Align(
        alignment: Alignment.topLeft,
        child: Text(
          "Path $_pathNumber:",
          style: BODY_TEXT_17,
        ),
      ),
    ]);
  }

  setPath(List<Instruction> instructions) {
    _path = instructions;
  }

  // Checker if it has instructions. Returns true if path has
  bool hasInstruction() {
    return path.isNotEmpty;
  }

  // Dispose Instruction
  disposeInstructions() {
    // Loop for every controller in the last controllers and dispose
    for (Instruction instruction in _path) {
      instruction.dispose();
      instruction.removeImage();
    }
  }

  // Add Instruction
  addInstruction() {
    Instruction newInstruction = Instruction(_path.length + 1);
    path.add(newInstruction);
  }

  // Remove Instruction
  removeInstruction() {
    // Dispose first before removing
    if (_path.isNotEmpty) _path.last.dispose();
    _path.removeLast();
  }
}

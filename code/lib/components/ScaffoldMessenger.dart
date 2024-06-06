import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Returns and displays a display message
ScaffoldFeatureController showScafolledMessage(
    BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: SOURCE_SANS_PRO,
    ),
    duration: const Duration(seconds: 1, milliseconds: 100),
    backgroundColor: BLUE,
  ));
}

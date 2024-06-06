import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Header navigation (arrow with title)
Widget headerNavigation(String headerName, VoidCallback action) {
  return Expanded(
    child: Row(children: [
      // ARROW BACK
      IconButton(
          padding: EdgeInsets.zero,
          color: GREEN,
          iconSize: 40,
          onPressed: action,
          icon: const Icon(Icons.arrow_back)),
      // BUILDING NAMEE
      Flexible(
          child: Text(
        headerName,
        style: HEADER_GREEN_26,
      )),
    ]),
  );
}

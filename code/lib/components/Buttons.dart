import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Elevated Button with background color
Widget elevatedButton(
  String title,
  Color color,
  VoidCallback onPressed,
) {
  return ElevatedButton(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 0))),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Text(
        title,
        style: BUTTON_TITLE,
      ),
    ),
    onPressed: onPressed,
  );
}

// Text Button with assigned color
TextButton textButton(String title, Color color, double size, String fontFamily,
    VoidCallback onPressed) {
  return TextButton(
      onPressed: onPressed,

      // This style ensures that the color remains white regardless if pressed
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.pressed)) {
            // Return the color you want when the button is pressed
            return Colors.transparent;
          }
          // Return the default color when the button is not pressed
          return Colors.transparent;
        }),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),

      // Text
      child: Text(
        title,
        style: TextStyle(
            color: color,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            fontSize: size,
            height: 0),
      ));
}

// A text button with icon
TextButton textButtonWithIcon(
  String title,
  Icon icon,
  Color color,
  double size,
  String fontFamily,
  bool isBold,
  bool isUnderline,
  VoidCallback onPressed,
) {
  return TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: 5), // Adjust the space between icon and text as needed
        Text(
          title,
          style: TextStyle(
            color: color,
            fontFamily: fontFamily,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            decoration:
                isUnderline ? TextDecoration.underline : TextDecoration.none,
            fontSize: size,
          ),
        ),
      ],
    ),
  );
}

// Search Button (Search Bar with Search icon acting as a search button)
Widget SearchButton(String label, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
          border: Border.all(color: BLUE, width: 1.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: BODY_TEXT,
              ),
            ),
            Icon(Icons.search, color: BLUE),
          ],
        ),
      ),
    ),
  );
}

// Implementation for zoom buttons for mapping
Container zoomButton(MapController mapController) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(2, 2),
        ),
      ],
    ),
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Zoom in
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: GREEN,
                ),
                onPressed: () => mapController.move(
                    mapController.center, mapController.zoom + 1)),
          ),
        ),
        // Zoom out
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: IconButton(
                icon: Icon(
                  Icons.remove,
                  color: GREEN,
                ),
                onPressed: () => mapController.move(
                    mapController.center, mapController.zoom - 1)),
          ),
        ),
      ],
    ),
  );
}

// Implementation of floating buttons
Widget floatingActionButton(Icon icon, VoidCallback action) {
  return FloatingActionButton(
    onPressed: action,
    backgroundColor: BLUE,
    child: icon,
  );
}

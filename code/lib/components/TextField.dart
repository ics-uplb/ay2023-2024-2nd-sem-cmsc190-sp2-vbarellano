import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Regular Textfield which is the default textfield design
Widget textField(
  TextEditingController controller,
  String label,
  String? Function(String?)? validator,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        validator: validator,
        decoration: InputDecoration(
          errorStyle: VALIDATE_TEXT,
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          labelText: label,
          labelStyle: BODY_TEXT,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: BLUE, width: 1.0),
          ),
        ),
        controller: controller,
      ),
    ],
  );
}

Widget textFieldPassword(TextEditingController controller, String label,
    bool isObscure, String? Function(String?)? validator, VoidCallback action) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        validator: validator,
        obscureText: isObscure,
        decoration: InputDecoration(
          errorStyle: VALIDATE_TEXT,
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          labelText: label,
          labelStyle: BODY_TEXT,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: BLUE, width: 1.0),
          ),
          suffixIcon: IconButton(
            splashColor: Colors.transparent,
            // If true, select show eye, else, do not show eye
            icon: isObscure
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            color: BLUE,
            onPressed: action,
          ),
        ),
        controller: controller,
      ),
    ],
  );
}

// A textfield but may have several lines depending on user
Widget textFieldWithLines(
  TextEditingController controller,
  String label,
  int lines,
  String? Function(String?)? validator,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        maxLines: lines,
        validator: validator,
        decoration: InputDecoration(
          errorStyle: VALIDATE_TEXT,
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          labelText: label,
          labelStyle: BODY_TEXT,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: GREEN, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the radius as needed
            borderSide: BorderSide(color: BLUE, width: 1.0),
          ),
        ),
        controller: controller,
      ),
    ],
  );
}

// A textfield used for searching
Widget searchBar(
  TextEditingController controller,
  String label,
  void Function(String)? onChangeAction,
  VoidCallback onTapAction,
) {
  return Container(
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
    ),
    child: TextFormField(
      onChanged: onChangeAction,
      controller: controller,
      decoration: InputDecoration(
        errorStyle: VALIDATE_TEXT,
        fillColor: Colors.white,
        filled: true,
        // Color when not active
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: BLUE, width: 1.0),
          borderRadius: BorderRadius.circular(50.0),
        ),
        // Color when active
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.0),
          borderRadius: BorderRadius.circular(50.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: BODY_TEXT, // Change to your BODY_TEXT style
        suffixIcon: IconButton(
          splashColor: Colors.transparent,
          icon: const Icon(Icons.search),
          color: BLUE,
          onPressed: onTapAction,
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Choices for colleges
Map<String, String> COLLEGES = {
  "---": "---",
  "CAS": "CAS",
  "CEM": "CEM",
  "CEAT": "CEAT",
  "CFNR": "CFNR",
  "CAFS": "CAFS",
  "CHE": "CHE",
  "CDC": "CDC",
  "CVM": "CVM",
  "CPAD": "CPAD",
  "SESAM": "SESAM",
  "Graduate School": "Graduate School",
};

Widget dropdownMap<T>(
  T value,
  Map<T, T> choices,
  Function(T) onChanged,
  String? Function(T?)? validator,
) {
  return DropdownButtonFormField<T>(
    validator: validator,
    value: value,
    icon: const Icon(Icons.keyboard_arrow_down),
    items: choices.entries.map((item) {
      return DropdownMenuItem<T>(
        value: item.key,
        child: Text(
          item.value.toString(),
          style: BODY_TEXT,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
    onChanged: (T? newValue) {
      if (newValue != null) {
        onChanged(newValue);
      }
    },
    decoration: InputDecoration(
      fillColor: Colors.white,
      filled: true,
      // Color when not active
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: BLUE, width: 1.0),
        borderRadius: BorderRadius.circular(50.0),
      ),
      // Color when active
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: BLUE, width: 1.0),
        borderRadius: BorderRadius.circular(50.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(50.0),
      ),
      alignLabelWithHint: true,
      errorStyle: VALIDATE_TEXT,
      labelStyle: BODY_TEXT,
    ),
    dropdownColor: Colors.white,
    style: BODY_TEXT,
    isDense: true,
  );
}

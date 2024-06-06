import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

Widget noContentFiller(String text) {
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 80,
            width: 80,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/logo.png'),
            )),
        Opacity(
          opacity: 0.5,
          child: Text(
            text,
            style: BODY_TEXT,
          ),
        )
      ]);
}

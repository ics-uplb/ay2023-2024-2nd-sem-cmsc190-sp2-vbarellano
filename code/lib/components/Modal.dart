import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Components
import 'package:hanap/components/Buttons.dart';

void modal(
  BuildContext context,
  String title,
  String text,
  VoidCallback action,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$title',
              style: HEADER_BLUE,
            ),
            SizedBox(height: 16),
            Flexible(
              child: Text(
                '$text',
                style: BODY_TEXT,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: elevatedButton("Cancel", Colors.red, () {
                    Navigator.pop(context);
                  }),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: elevatedButton("Confirm", GREEN, action),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

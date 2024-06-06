import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

class Floormap {
  // Attributes
  int _floorlevel = 1;
  int get floorlevel => _floorlevel;
  File? image;
  String? _imageURL;
  String? get imageURL => _imageURL;
  bool? showImageURL = false;

  setInput(int floorlevel, File? _image, String? url) {
    _floorlevel = floorlevel;
    image = _image;
    _imageURL = url;
  }

  Widget getFloorlevelWidget(
    VoidCallback add,
    VoidCallback sub,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: BLUE, width: 1.0),
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Floor level
            Expanded(
                child: Text(
              "Floor Level: ${_floorlevel}",
              style: BODY_TEXT,
            )),
            // Add Button
            ClipOval(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    icon: Icon(
                      Icons.add,
                      color: GREEN,
                    ),
                    onPressed: add),
              ),
            ),
            // Remove Button
            ClipOval(
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: GREEN,
                    ),
                    onPressed: sub),
              ),
            )
          ],
        ),
      ),
    );
  }

  removeImage() {
    image = null;
  }

  setImageURL(String url) => _imageURL = url;

  showURL() => showImageURL = true;
  hideURL() => showImageURL = false;

  setLevel(int level) => _floorlevel = level;

  addFloor() {
    _floorlevel++;
    if (_floorlevel == 0) _floorlevel = 1;
  }

  decFloor() {
    _floorlevel--;
    if (_floorlevel == 0) _floorlevel = -1;
  }
}

import 'dart:io';

import 'package:hanap/model/Floormap.dart';

class Building {
  // BUILDING DETAILS
  String? building_id;
  String name;
  String? _popular_names;
  String? get popular_names => _popular_names;
  String college;
  String description;
  String address;
  double? latitude = 0;
  double? longitude = 0;
  File? image;
  String? image_url;
  List<Floormap> floormaps = [];
  bool isBookmarked = false;

  // USER DETAILS
  String contributed_by;
  bool? is_nonadmin_contribution = false;
  String status;

  // Approved by and timestamp is needed when user is
  // Non-Admin user
  String? approved_by;
  String? datetime_approved;

  // Constructor
  Building(
    this.building_id,
    this.name,
    this._popular_names,
    this.college,
    this.description,
    this.address,
    this.image,
    this.image_url,
    this.floormaps,
    this.status,
    this.contributed_by,
  );

  setLatLong(double lat, double long) {
    latitude = lat;
    longitude = long;
  }

  void markBookmarked() {
    isBookmarked = true;
  }

  void unmarkBookmark() {
    isBookmarked = false;
  }
}

import 'dart:io';

// Model
import 'Path.dart';

class Room {
  // ROOM DETAILS
  String? room_id;
  String name;
  String code;
  String address;
  String description;
  String college;
  // BUILDING DETAILS
  String building_id;
  String building_name;
  int floor_level;
  File? image;
  String? image_url;
  List<Path> directions;
  bool isBookmarked = false;
  // Add handler for direction

  // USER AND CONTRIBUTOR DETAILS
  String contributed_by;
  bool? is_nonadmin_contribution = false;
  String status;

  String? approved_by;
  String? timestamp;

  // Constructor
  Room(
      // ROOM DETAILS
      this.room_id,
      this.name,
      this.code,
      this.address,
      this.description,
      this.college,
      // BUILDING DETAILS
      this.building_id,
      this.building_name,
      this.floor_level,
      this.image,
      this.image_url,
      this.directions,
      this.contributed_by,
      this.status);

  void markBookmarked() {
    isBookmarked = true;
  }

  void unmarkBookmark() {
    isBookmarked = false;
  }
}

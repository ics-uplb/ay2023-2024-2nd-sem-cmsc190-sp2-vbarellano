import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hanap/model/Floormap.dart';
import 'package:hanap/model/Instruction.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// API
import 'package:hanap/api/firebase_room_api.dart';
import 'package:hanap/api/firebase_storage_api.dart';
import 'package:hanap/api/firebase_log_api.dart';
import 'package:hanap/api/firebase_building_api.dart';

// Model
import '../model/Building.dart';
import '../model/Room.dart';
import '../model/Path.dart';
import '../model/Log.dart';

// Constants
String APPROVED = "approved";
String REJECTED = "rejected";
String FOR_APPROVAL = "for_approval";

class RoomsProvider extends ChangeNotifier {
  // API
  late FirebaseRoomAPI dbAPI;
  late FirebaseBuildingAPI bldgAPI;
  late FirebaseStorageApi storage;
  late FirebaseLogAPI logsAPI;

  // Handler for rooms
  late Stream<QuerySnapshot> _approvedRooms;
  Stream<QuerySnapshot> get approvedRooms => _approvedRooms;
  late Stream<QuerySnapshot> _forApprovalRooms;
  Stream<QuerySnapshot> get forApprovalRooms => _forApprovalRooms;
  late Stream<QuerySnapshot> _rejectedRooms;
  Stream<QuerySnapshot> get rejectedRooms => _rejectedRooms;

  // Handler for searched buildings
  late Stream<QuerySnapshot> _searchedRooms;
  Stream<QuerySnapshot> get searchedRooms => _searchedRooms;

  // Handler for Buildings
  List<Building> bldgs = [];
  // List<String> BUILDINGS_CHOICES = ["---"];
  Map<String, String> BUILDINGS_CHOICES = {"---": "----"};

  Map<String, String> FLOORMAP_CHOICES = {"---": "----"};

  // CONSTRUCTOR
  RoomsProvider() {
    dbAPI = FirebaseRoomAPI();
    storage = FirebaseStorageApi();
    logsAPI = FirebaseLogAPI();
    bldgAPI = FirebaseBuildingAPI();
    searchRooms('', []);
    fetchApprovedRooms();
    fetchForApprovalRooms();
    fetchRejectedRooms();
  }

  // Method for fetching approved rooms
  fetchApprovedRooms() {
    _approvedRooms = dbAPI.fetchApprovedRooms();
    notifyListeners();
  }

  // Method for fetching approved rooms
  fetchForApprovalRooms() {
    _forApprovalRooms = dbAPI.fetchForApprovalRooms();
    notifyListeners();
  }

  fetchRejectedRooms() {
    _rejectedRooms = dbAPI.fetchRejectedRooms();
    notifyListeners();
  }

  // Method for fetching buildings given college
  fetchBuildingsPerCollege(String college) async {
    bldgs = await bldgAPI.fetchBuildingsPerCollege(college);
    // BUILDINGS_CHOICES = ["---"];
    BUILDINGS_CHOICES = {"---": "----"};
    FLOORMAP_CHOICES = {"---": "----"};
    if (bldgs.isNotEmpty) {
      for (Building bldg in bldgs) {
        // BUILDINGS_CHOICES.add(bldg.name);
        BUILDINGS_CHOICES[bldg.building_id!] = bldg.name;
      }
    }
    notifyListeners();
  }

  // Method for fetching floorlevels given building
  fetchFloorlevelPerBldg(String id) {
    for (Building building in bldgs) {
      if (building.building_id == id) {
        FLOORMAP_CHOICES = {"---": "----"};
        if (building.floormaps.isNotEmpty) {
          for (Floormap floormap in building.floormaps) {
            FLOORMAP_CHOICES[floormap.floorlevel.toString()] =
                floormap.floorlevel.toString();
          }
        } else {
          FLOORMAP_CHOICES = {"---": "-- Floormap Unavailable --"};
        }
      }
    }
    notifyListeners();
  }

  // Method for adding a room
  addRoom(
    String name,
    String code,
    String address,
    String description,
    String college,
    String bldg_id,
    String floorlevel,
    File? image,
    List<Path> directions,
    bool is_approved,
    String contributed_by,
  ) async {
    // Get the id of this room
    String id = await dbAPI.addRoom();

    // Get the building name
    Building? bldg;
    for (Building building in bldgs) {
      if (building.building_id == bldg_id) {
        bldg = building;
      }
    }

    // Get image url
    String imageURL = await storage.uploadFile(image, "rooms/$id/image.jpg");

    var formattedDirections = [];

    // Get image url for every path if available
    for (Path path in directions) {
      // Format all instructions
      List instructions = [];
      for (Instruction instruction in path.path) {
        if (instruction.image != null) {
          instruction.setImage(await storage.uploadFile(
            instruction.image,
            "rooms/$id/path_${path.pathNumber}/instruction_${instruction.instructionNumber}",
          ));
        }
        var instructionFormatted = {
          "instruction_number": instruction.instructionNumber,
          "instruction": instruction.controller.text,
          "has_image": instruction.hasImage,
          if (instruction.hasImage) "image_url": instruction.image_url
        };
        instructions.add(instructionFormatted);
      }
      formattedDirections.add({
        "path_number": path.pathNumber,
        "instructions": instructions,
      });
    }

    // Create an instance of room
    Room room = Room(
      id,
      name,
      code,
      address,
      description,
      college,
      bldg_id,
      bldg!.name,
      int.parse(floorlevel),
      image,
      imageURL,
      [],
      contributed_by,
      is_approved ? APPROVED : FOR_APPROVAL,
    );

    // Update content of the building
    await dbAPI.updateRoom(id, {
      "name": room.name,
      "code": room.code,
      "address": room.address,
      "description": room.description,
      "college": room.college,
      "building_id": room.building_id,
      "building_name": bldg.name,
      "floorlevel": room.floor_level,
      "image_url": room.image_url,
      "directions": formattedDirections,
      "status": is_approved ? APPROVED : FOR_APPROVAL,
      "is_nonadmin_contribution": !is_approved,
      "contributed_by": room.contributed_by,
    });

    // Add entry to Firebase Logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributed_by,
      is_approved ? "added room $id." : "contributed $id.",
    ));

    notifyListeners();
  }

  updateRoom(
    String id,
    String name,
    String code,
    String address,
    String description,
    String college,
    String bldg_id,
    String floorlevel,
    File? image,
    String? image_url,
    List<Path> directions,
    List initPathNumbers,
    bool is_approved,
    String contributed_by,
  ) async {
    // Get the building name
    Building? bldg;
    for (Building building in bldgs) {
      if (building.building_id == bldg_id) {
        bldg = building;
      }
    }

    // Update image url if available
    // image_url ??= await storage.updateFile(image, "rooms/$id/image.jpg");

    // Update image
    var formattedDirections = [];
    for (Path path in directions) {
      List instructions = [];
      for (Instruction instruction in path.path) {
        // If show image url is false
        if (!instruction.isShowImageURL && instruction.image != null) {
          // Check if the instruction is already existing
          if (path.instructionNumbers.contains(instruction.instructionNumber)) {
            instruction.setImage(await storage.updateFile(
              instruction.image,
              "rooms/$id/path_${path.pathNumber}/instruction_${instruction.instructionNumber}",
            ));
            path.instructionNumbers.remove(instruction.instructionNumber);
            // Check if the instruction is new
          } else {
            instruction.setImage(await storage.uploadFile(
              instruction.image,
              "rooms/$id/path_${path.pathNumber}/instruction_${instruction.instructionNumber}",
            ));
          }
        }
        var instructionFormatted = {
          "instruction_number": instruction.instructionNumber,
          "instruction": instruction.controller.text,
          "has_image": instruction.hasImage,
          if (instruction.hasImage) "image_url": instruction.image_url
        };
        instructions.add(instructionFormatted);
      }
      formattedDirections.add({
        "path_number": path.pathNumber,
        "instructions": instructions,
      });
    }

    // Create an instance of room
    Room room = Room(
        id,
        name,
        code,
        address,
        description,
        college,
        bldg_id,
        bldg!.name,
        int.parse(floorlevel),
        image,
        image_url,
        [],
        contributed_by,
        is_approved ? APPROVED : FOR_APPROVAL);

    // Update content of the building
    await dbAPI.updateRoom(id, {
      "name": room.name,
      "code": room.code,
      "address": room.address,
      "description": room.description,
      "college": room.college,
      "building_id": room.building_id,
      "building_name": bldg.name,
      "floorlevel": room.floor_level,
      "image_url": room.image_url,
      "directions": formattedDirections,
    });

    // Add entry to Firebase Logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributed_by,
      "updated room $id.",
    ));

    notifyListeners();
  }

  deleteRoom(String id, String contributedBy) async {
    // Delete the room from firestore
    await dbAPI.deleteRoom(id);

    // Delete the room from storage
    await storage.deleteFolder('rooms/$id');

    // Add log in the systems logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributedBy,
      "deleted room $id.",
    ));
    notifyListeners();
  }

  approveRoom(String id, String approvedBy) async {
    await dbAPI.updateRoom(id, {
      "status": APPROVED,
      "approved_by": approvedBy,
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      approvedBy,
      "approved room $id.",
    ));
  }

  rejectRoom(String id, String rejectedBy) async {
    await dbAPI.updateRoom(id, {
      "status": REJECTED,
      "rejected_by": rejectedBy,
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      rejectedBy,
      "rejected room $id.",
    ));
  }

  // Method for fetching contributed approved buildings
  fetchContributedApprovedRooms(String id) {
    return dbAPI.fetchContAppRooms(id);
  }

  // Method for fetching contributed approved buildings
  fetchContributedForApprovalRooms(String id) {
    return dbAPI.fetchContForAppRooms(id);
  }

  // Method for fetching contributed approved buildings
  fetchContributedRejectedRooms(String id) {
    return dbAPI.fetchContRejRooms(id);
  }

  // Method for fetching room by id
  Future<DocumentSnapshot> fetchRoomByID(String id) async {
    DocumentSnapshot room = await dbAPI.fetchRoomByID(id);
    return room;
  }

  searchRooms(String keyword, List<String> college) {
    _searchedRooms = dbAPI.searchRooms(keyword, college);
    notifyListeners();
  }

  bookmarkRoom(String userID, String roomID) async {
    await dbAPI.bookmark(userID, roomID);
  }

  unBookmarkRoom(String userID, String roomID) async {
    await dbAPI.unBookMark(userID, roomID);
  }
}

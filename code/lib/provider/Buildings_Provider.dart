import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// API
import 'package:hanap/api/firebase_building_api.dart';
import 'package:hanap/api/firebase_storage_api.dart';
import 'package:hanap/api/firebase_log_api.dart';

// Model
import '../model/Building.dart';
import '../model/Floormap.dart';
import '../model/Log.dart';

class BuildingsProvider extends ChangeNotifier {
  // Constants
  String APPROVED = "approved";
  String REJECTED = "rejected";
  String FOR_APPROVAL = "for_approval";

  // API
  late FirebaseBuildingAPI dbAPI;
  late FirebaseStorageApi storage;
  late FirebaseLogAPI logsAPI;

  // Handler for approved buildings
  late Stream<QuerySnapshot> _approvedBldgs;
  Stream<QuerySnapshot> get approvedBldgs => _approvedBldgs;

  // Handler for for approval buildings
  late Stream<QuerySnapshot> _forApprovalBldgs;
  Stream<QuerySnapshot> get forApprovalBldgs => _forApprovalBldgs;

  // Handler for for approval buildings
  late Stream<QuerySnapshot> _rejectedBldgs;
  Stream<QuerySnapshot> get rejectedBldgs => _rejectedBldgs;

  // Handler for searched buildings
  late Stream<QuerySnapshot> _searchedBldgs;
  Stream<QuerySnapshot> get searchedBldgs => _searchedBldgs;

  // Handler for fetching building by ID
  late Stream<DocumentSnapshot> _building;
  Stream<DocumentSnapshot> get building => _building;

  // Handler for logs
  late Stream<QuerySnapshot> _logs;
  Stream<QuerySnapshot> get logs => _logs;

  // CONSTRUCTOR
  BuildingsProvider() {
    dbAPI = FirebaseBuildingAPI();
    storage = FirebaseStorageApi();
    logsAPI = FirebaseLogAPI();
    searchBuilding('', []);
    fetchApprovedBuildings();
    fetchBuildingsForApproval();
    fetchBuildingsRejected();
  }

  // Method for handling add building for admin
  addBuilding(
    // BUILDING DETAILS
    String name,
    String? popular_names,
    String college,
    String description,
    String address,
    double latitude,
    double longitude,
    File? image,
    List<Floormap> floormaps,
    // USER DETAILS
    bool is_approved,
    String contributed_by,
  ) async {
    // Append instance to database buildings to get the id the update the content
    String id = await dbAPI.addBuilding();

    // Add to Firebase Storage images and floormap images
    String imageURL =
        await storage.uploadFile(image, "buildings/$id/image.jpg");
    print(imageURL);

    // Loop for every floormap
    for (Floormap floormap in floormaps) {
      if (!floormap.showImageURL! && floormap.image != null) {
        String floormapImageURL = await storage.uploadFile(
          floormap.image,
          "buildings/$id/floormaps/level_${floormap.floorlevel}.jpg",
        );
        floormap.setImageURL(floormapImageURL);
      }
    }

    // New building
    Building newBldg = Building(
      id, // building_id
      name,
      popular_names,
      college,
      description,
      address,
      image,
      imageURL,
      floormaps,
      is_approved ? APPROVED : FOR_APPROVAL,
      contributed_by,
    );
    // Set LatLong
    newBldg.setLatLong(latitude, longitude);

    // Update the image content
    await dbAPI.updateBuilding(id, {
      "name": newBldg.name,
      "popular_names": newBldg.popular_names,
      "college": newBldg.college,
      "description": newBldg.description,
      "address": newBldg.address,
      "latitude": newBldg.latitude,
      "longitude": newBldg.longitude,
      "image_url": newBldg.image_url,
      "floormaps": newBldg.floormaps.map((floormap) {
        return {
          "level": floormap.floorlevel,
          "image_url": floormap.imageURL,
        };
      }),
      "status": is_approved ? APPROVED : FOR_APPROVAL,
      "is_nonadmin_contribution": !is_approved,
      "contributed_by": newBldg.contributed_by
    });

    // Add entry to Firebase Logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributed_by,
      is_approved
          ? "added $name to buildings."
          : "contributed $name to buildings.",
    ));

    notifyListeners();
  }

  updateBuilding(
    // BUILDING DETAILS
    String? id,
    String name,
    String? popular_names,
    String college,
    String description,
    String address,
    double? latitude,
    double? longitude,
    File? image,
    String? image_url,
    List<int> unique_levels,
    List<Floormap> floormaps,
    // USER DETAILS
    bool is_approved,
    String contributed_by,
  ) async {
    // Get all the levels
    Map floormap = {};

    // Update Firebase Storage building images and floormap images
    image_url ??= await storage.updateFile(image, "buildings/$id/image.jpg");
    for (Floormap floormap in floormaps) {
      if (!floormap.showImageURL! && floormap.image != null) {
        // If floor level is already existing
        if (unique_levels.contains(floormap.floorlevel)) {
          floormap.setImageURL(await storage.updateFile(floormap.image,
              "buildings/$id/floormaps/level_${floormap.floorlevel}.jpg"));
          unique_levels.remove(floormap.floorlevel);
          // If not existing, it is a new floor level
        } else {
          String floormapImageURL = await storage.uploadFile(
            floormap.image,
            "buildings/$id/floormaps/level_${floormap.floorlevel}.jpg",
          );
          floormap.setImageURL(floormapImageURL);
        }
      }
    }

    // Update the image content
    await dbAPI.updateBuilding(id!, {
      "name": name,
      "popular_names": popular_names,
      "college": college,
      "description": description,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "image_url": image_url,
      "floormaps": floormaps.map((floormap) {
        // print("URLLLLL: ${floormap.imageURL}");
        return {
          "level": floormap.floorlevel,
          "image_url": floormap.imageURL,
        };
      }),
    });

    // // Add entry to Firebase Logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributed_by,
      "updated building $name content.",
    ));

    // Notifying listeners.
    notifyListeners();
  }

  deleteBuilding(String id, String contributed_by, String name) async {
    // Delete the building from firestore
    await dbAPI.deleteBuilding(id);

    // Delete the building from storage
    await storage.deleteFolder('buildings/$id');

    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      contributed_by,
      "deleted building $name.",
    ));
    notifyListeners();
  }

  approveBuilding(String id, String name, String approved_by) async {
    await dbAPI.updateBuilding(id, {
      "status": APPROVED,
      "approved_by": approved_by,
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      approved_by,
      "approved building $name.",
    ));
  }

  rejectBuilding(String id, String name, String approved_by) async {
    await dbAPI.updateBuilding(id, {
      "status": REJECTED,
      "approved_by": approved_by,
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      approved_by,
      "rejected building $name.",
    ));
  }

  // Method for fetching approved buildings
  fetchApprovedBuildings() {
    _approvedBldgs = dbAPI.fetchApprovedBuildings();
    notifyListeners();
  }

  // Method for fetching approved buildings
  fetchBuildingsForApproval() {
    _forApprovalBldgs = dbAPI.fetchBldgsForApproval();
    notifyListeners();
  }

  // Method for fetching approved buildings
  fetchBuildingsRejected() {
    _rejectedBldgs = dbAPI.fetchBldgsRejected();
    notifyListeners();
  }

  // Method for fetching contributed approved buildings
  fetchContributedApprovedBuildings(String id) {
    return dbAPI.fetchContAppBldgs(id);
  }

  // Method for fetching contributed approved buildings
  fetchContributedForApprovalBuildings(String id) {
    return dbAPI.fetchContForAppBldgs(id);
  }

  // Method for fetching contributed approved buildings
  fetchContributedRejectedBuildings(String id) {
    return dbAPI.fetchContRejBldgs(id);
  }

  searchBuilding(String keyword, List<String> colleges) {
    _searchedBldgs = dbAPI.searchBuilding(keyword, colleges);
    notifyListeners();
  }

  bookmarkBldg(String userID, String bldgID) async {
    await dbAPI.bookmark(userID, bldgID);
  }

  unBookmarkBldg(String userID, String bldgID) async {
    await dbAPI.unBookMark(userID, bldgID);
  }

  Future<DocumentSnapshot> fetchBuildingByID(String id) async {
    DocumentSnapshot building = await dbAPI.fetchBuildingByID(id);
    return building;
  }
}

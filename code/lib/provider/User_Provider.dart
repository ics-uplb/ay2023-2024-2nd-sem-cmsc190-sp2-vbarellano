import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Model
import 'package:hanap/model/UserModel.dart';
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/Room.dart';
import 'package:hanap/model/Log.dart';

// API
import 'package:hanap/api/firebase_user_api.dart';
import 'package:hanap/api/firebase_building_api.dart';
import 'package:hanap/api/firebase_room_api.dart';
import 'package:hanap/api/firebase_log_api.dart';
import 'package:hanap/api/firebase_storage_api.dart';

// CONSTANTS
bool BUILDING = true;
bool ROOM = false;

class UserProvider with ChangeNotifier {
  // Constants
  String REQUESTED = "requested";
  String REJECTED = "rejected";
  String APPROVED = "approved";
  String REVOKED = "revoked";

  // API
  late FirebaseUserAPI userAPI;
  late FirebaseLogAPI logAPI;
  late FirebaseBuildingAPI bldgAPI;
  late FirebaseStorageApi storage;
  late FirebaseRoomAPI roomAPI;

  // User Handler
  UserModel _user = UserModel("", "", "");
  UserModel get user => _user;

  late Stream<QuerySnapshot> _adminRequests;
  Stream<QuerySnapshot> get adminRequests => _adminRequests;

  late Stream<QuerySnapshot> _adminApproved;
  Stream<QuerySnapshot> get adminApproved => _adminApproved;

  late Stream<QuerySnapshot> _adminRevoked;
  Stream<QuerySnapshot> get adminRevoked => _adminRevoked;

  UserProvider() {
    userAPI = FirebaseUserAPI();
    logAPI = FirebaseLogAPI();
    bldgAPI = FirebaseBuildingAPI();
    storage = FirebaseStorageApi();
    roomAPI = FirebaseRoomAPI();
    fetchAdminRequests();
    fetchAdminApproved();
    fetchAdminRevoked();
    fetchAdminRevoked();
  }

  // Method for adding a user
  addUser(
    String id,
    String first_name,
    String last_name,
  ) async {
    await userAPI.addUser(id, {
      "first_name": first_name,
      "last_name": last_name,
      "is_admin": false, // By default, must be set to false
      "saved_rooms": [],
      "saved_bldgs": [],
      "contributed_rooms": [],
      "contributed_bldgs": [],
    });
  }

  // Method for fetching a user
  Future<Map<String, dynamic>?> fetchUserByID(String id) async {
    Map<String, dynamic>? userData = await userAPI.fetchUserByID(id);
    return userData;
  }

  // Method for setting user data
  setUserData(String id, String email, Map<String, dynamic> userData) {
    if (userData != null) {
      _user = UserModel(
        id,
        userData['first_name'],
        userData['last_name'],
      );
      _user.is_admin = userData['is_admin'];
      _user.is_request_status = userData['is_request_status'];
      _user.is_request_datetime_sent = userData['is_request_datetime_sent'];
      _user.is_request_datetime_confirmed =
          userData['is_request_datetime_confirmed'];
      _user.is_request_confirmed_by = userData['is_request_confirmed_by'];
      _user.email = email;
      // Set saved bldgs and rooms
      if (userData['saved_bldgs'] != null) {
        for (String id in userData['saved_bldgs']) {
          _user.saved_buildings.add(id);
        }
      }
      if (userData['saved_rooms'] != null) {
        for (String id in userData['saved_rooms']) {
          _user.saved_rooms.add(id);
        }
      }
      if (userData['is_superadmin'] != null) {
        _user.is_superadmin = userData['is_superadmin'];
      }
      if (userData['proof'] != null) {
        _user.proof = userData['proof'];
      }
      notifyListeners();
    }
  }

  // Method for setting user saved bldgs
  bool checkIfSaved(bool isBuilding, String id, Map<String, dynamic> userData) {
    // Check if user data is not null
    if (userData != null) {
      // Check if saved ids is not null
      if (isBuilding == BUILDING && userData['saved_bldgs'] != null) {
        // Return if it contains
        return userData['saved_bldgs'].contains(id);
      } else if (isBuilding == ROOM && userData['saved_rooms'] != null) {
        // Return if it contains
        return userData['saved_rooms'].contains(id);
      }
      // Call set saved bldgs before notifying
      return false;
    }
    return false;
  }

  // Method for setting user from sign up
  setNewUser(String id, String firstName, String lastName) async {
    UserModel updatedUser = UserModel(id, firstName, lastName);
    _user = updatedUser;
    notifyListeners();
  }

  // Method for sending admin access request
  requestAdminAccess(String id, File? proof) async {
    _user.is_request_status = REQUESTED;

    String imageURL = await storage.uploadFile(proof, "user/$id/proof.jpg");

    await userAPI.updateUser(id, {
      "is_request_status": REQUESTED,
      "is_request_datetime_sent": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "proof": imageURL,
    });

    // Add entry to Firebase Logs
    await logAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      _user.first_name,
      "requested admin access.",
    ));

    notifyListeners();
  }

  // Method for sending admin access request
  approveAdminAccessRequest(String id) async {
    _user.is_request_status = REQUESTED;

    await userAPI.updateUser(id, {
      "is_request_status": APPROVED,
      "is_request_datetime_confirmed": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "is_request_confirmed_by": "${_user.first_name} ${_user.last_name}",
      "is_admin": true,
    });

    // Add entry to Firebase Logs
    await logAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      _user.first_name,
      "approved admin access request of User $id",
    ));

    notifyListeners();
  }

  // Method for sending admin access request
  rejectAdminAccessRequest(String id) async {
    _user.is_request_status = REQUESTED;

    await userAPI.updateUser(id, {
      "is_request_status": REJECTED,
      "is_request_datetime_confirmed": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "is_request_confirmed_by": "${_user.first_name} ${_user.last_name}",
      "is_admin": false,
    });

    // Add entry to Firebase Logs
    await logAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      _user.first_name,
      "rejected admin access request of User $id",
    ));

    notifyListeners();
  }

  // Method for sending admin access request
  revokeAdminAccess(String id) async {
    _user.is_request_status = REQUESTED;

    await userAPI.updateUser(id, {
      "is_request_status": REVOKED,
      "is_request_datetime_confirmed": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "is_request_confirmed_by": "${_user.first_name} ${_user.last_name}",
      "is_admin": false,
    });

    // Add entry to Firebase Logs
    await logAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      _user.first_name,
      "revoked admin access of User $id",
    ));

    notifyListeners();
  }

  // Method for sending admin access request
  giveSuperadminAccess(String id) async {
    _user.is_request_status = REQUESTED;

    await userAPI.updateUser(id, {
      "is_request_status": REVOKED,
      "is_request_datetime_confirmed": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "is_request_confirmed_by": "${_user.first_name} ${_user.last_name}",
      "is_superadmin": true,
    });

    // Add entry to Firebase Logs
    await logAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      _user.first_name,
      "added User $id as superadmin",
    ));

    notifyListeners();
  }

  // Method for fetching admin approval requests
  fetchAdminRequests() async {
    _adminRequests = userAPI.fetchAdminRequests();
    notifyListeners();
  }

  // Method for fetching admin approval requests
  fetchAdminApproved() async {
    _adminApproved = userAPI.fetchAdminApproved();
    notifyListeners();
  }

  // Method for fetching admin approval requests
  fetchAdminRevoked() async {
    _adminRevoked = userAPI.fetchAdminRevoked();
    notifyListeners();
  }

  // Add to bookmarked entities
  bookmark(bool isBuilding, String id) {
    if (isBuilding) {
      user.saved_buildings.add(id);
    } else {
      user.saved_rooms.add(id);
    }
    notifyListeners();
  }

  unBookmark(bool isBuilding, String id) {
    if (isBuilding) {
      user.saved_buildings.remove(id);
    } else {
      user.saved_rooms.remove(id);
    }
    notifyListeners();
  }

  Stream<List<DocumentSnapshot>> listenToUserSavedDetails(bool isBuilding) {
    if (isBuilding) {
      return bldgAPI.fetchDetails(user.saved_buildings);
    } else {
      return roomAPI.fetchDetails(user.saved_rooms);
    }
  }
}

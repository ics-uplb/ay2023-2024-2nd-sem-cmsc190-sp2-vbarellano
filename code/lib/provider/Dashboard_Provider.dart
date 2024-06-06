import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// API
import 'package:hanap/api/firebase_log_api.dart';
import 'package:hanap/api/firebase_building_api.dart';
import 'package:hanap/api/firebase_room_api.dart';
import 'package:hanap/api/firebase_user_api.dart';
import 'package:hanap/api/firebase_report_api.dart';

// Model
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/Room.dart';

class DashboardProvider extends ChangeNotifier {
  // API
  late FirebaseLogAPI logAPI;
  late FirebaseBuildingAPI bldgAPI;
  late FirebaseRoomAPI roomAPI;
  late FirebaseReportAPI reportAPI;
  late FirebaseUserAPI userAPI;

  // Logs
  late Stream<QuerySnapshot> _systemLogs;
  Stream<QuerySnapshot> get systemLogs => _systemLogs;

  // Constructor
  DashboardProvider() {
    logAPI = FirebaseLogAPI();
    bldgAPI = FirebaseBuildingAPI();
    roomAPI = FirebaseRoomAPI();
    reportAPI = FirebaseReportAPI();
    userAPI = FirebaseUserAPI();
    fetchLogs();
  }

  // Method for fetching logs
  fetchLogs() {
    _systemLogs = logAPI.fetchLogs()!;
    notifyListeners();
  }

  // Methods for fetching rooms counts
  getApprovedRoomCount() async {
    return await roomAPI.fetchApprovedRoomCount();
  }

  getForApprovalRoomCount() async {
    return await roomAPI.fetchForApprovalRoomCount();
  }

  getRejectRoomCount() async {
    return await roomAPI.fetchRejectedRoomCount();
  }

  getTotalRoomCounts() async {
    return await roomAPI.fetchTotalRoomCount();
  }

  // Methods for fetching building counts
  getApprovedBldgount() async {
    return await bldgAPI.fetchApprovedBldgCount();
  }

  getForApprovalBldgCount() async {
    return await bldgAPI.fetchForApprovalBldgCount();
  }

  getRejectedBldgCount() async {
    return await bldgAPI.fetchRejectedBldgCount();
  }

  getTotalBldgCounts() async {
    return await bldgAPI.fetchTotalBldgCount();
  }

  // Methods for fetching user counts
  getAdminUserCount() async {
    return await userAPI.fetchAdminUserCount();
  }

  getNonAdminUserCount() async {
    return await userAPI.fetchNonAdminUserCount();
  }

  getTotalUserCount() async {
    return await userAPI.fetchTotalUserCount();
  }

  // Method for fetching report counts
  getReceivedReportCount() async {
    return await reportAPI.fetchReceivedReportCount();
  }

  getUnderEvalReportCount() async {
    return await reportAPI.fetchUnderEvalReportCount();
  }

  getResolvedReportCount() async {
    return await reportAPI.fetchResolvedReportCount();
  }

  getTotalReportCount() async {
    return await reportAPI.fetchTotalReportCount();
  }
}

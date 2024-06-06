import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// API
import 'package:hanap/api/firebase_report_api.dart';
import 'package:hanap/api/firebase_log_api.dart';

// Model
import 'package:hanap/model/Report.dart';
import 'package:hanap/model/Log.dart';

// Constants
final String RECEIVED = "received";
final String UNDER_EVAL = "under_evaluation";
final String RESOLVED = "resolved";

class ReportProvider extends ChangeNotifier {
  late FirebaseReportAPI reportAPI;
  late FirebaseLogAPI logsAPI;

  late Stream<QuerySnapshot> _receivedReports;
  Stream<QuerySnapshot> get receivedReports => _receivedReports;

  late Stream<QuerySnapshot> _underEvalReports;
  Stream<QuerySnapshot> get underEvalReports => _underEvalReports;

  late Stream<QuerySnapshot> _resolvedReports;
  Stream<QuerySnapshot> get resolvedReports => _resolvedReports;

  // Constructor
  ReportProvider() {
    reportAPI = FirebaseReportAPI();
    logsAPI = FirebaseLogAPI();
    fetchReceivedReports();
    fetchUnderEvalReports();
    fetchResolvedReports();
  }

  // Method for send a report
  sendReport(
    String sender_id,
    String sender_name,
    String description,
  ) async {
    await reportAPI.sendReport({
      "sender_id": sender_id,
      "sender_name": sender_name,
      "status": RECEIVED, // By default, status is received
      "datetime_sent": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "description": description,
    });

    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd\nHH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "$sender_id ($sender_name)",
      "sent a report.",
    ));
    notifyListeners();
  }

  mark_UnderEval(String report_id, String user_id, String user_name) async {
    await reportAPI.updateReport(report_id, {
      "datetime_evaluated": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "evaluated_by": user_name,
      "evaluator_id": user_id,
      "status": UNDER_EVAL
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "$user_id ($user_name)",
      "marked report '$report_id' as under evaluation.",
    ));
    notifyListeners();
  }

  mark_Resolved(String report_id, String user_id, String user_name) async {
    await reportAPI.updateReport(report_id, {
      "datetime_resolved": DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "resolved_by": user_name,
      "resolver_id": user_id,
      "status": RESOLVED
    });
    // Add a log in the system logs
    await logsAPI.addLog(Log(
      // Format the date and time
      DateFormat('yyyy-MM-dd HH:mm')
          .format(Timestamp.now().toDate())
          .toString(),
      "$user_id ($user_name)",
      "marked report '$report_id' as resolved.",
    ));
    notifyListeners();
  }

  // Method for getting received reports
  fetchReceivedReports() {
    _receivedReports = reportAPI.fetchReports(RECEIVED);
    notifyListeners();
  }

  // Method for getting under evaluation reports
  fetchUnderEvalReports() {
    _underEvalReports = reportAPI.fetchReports(UNDER_EVAL);
    notifyListeners();
  }

  // Method for getting resolved reports
  fetchResolvedReports() {
    _resolvedReports = reportAPI.fetchReports(RESOLVED);
    notifyListeners();
  }
}

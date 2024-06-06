import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseReportAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  final String RECEIVED = "received";
  final String UNDER_EVAL = "under_evaluation";
  final String RESOLVED = "resolved";

  // Method used to send a report
  Future<String> sendReport(Map<String, dynamic> report) async {
    try {
      await db.collection("reports").add(report);
      return "Report successfully sent!";
    } on FirebaseException catch (e) {
      return "Report unsuccessfully sent ${e.code}: ${e.message}";
    }
  }

  // Method for fetching a received reports
  Stream<QuerySnapshot> fetchReports(String status) {
    return db
        .collection('reports')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // Method for updating reports
  Future<String> updateReport(String id, Map<String, dynamic> data) async {
    try {
      await db.collection("reports").doc(id).update(data);
      return "Report successfully updated!";
    } on FirebaseException catch (e) {
      return "Report unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for getting the number of received reports
  fetchReceivedReportCount() async {
    var querySnapshot = await db
        .collection("reports")
        .where('status', isEqualTo: RECEIVED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of under evaluation reports
  fetchUnderEvalReportCount() async {
    var querySnapshot = await db
        .collection("reports")
        .where('status', isEqualTo: UNDER_EVAL)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of resolved reports
  fetchResolvedReportCount() async {
    var querySnapshot = await db
        .collection("reports")
        .where('status', isEqualTo: RESOLVED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms
  fetchTotalReportCount() async {
    var querySnapshot = await db.collection("reports").count().get();
    return querySnapshot.count;
  }
}

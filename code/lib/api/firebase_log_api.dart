import 'package:cloud_firestore/cloud_firestore.dart';

// Model
import 'package:hanap/model/Log.dart';

class FirebaseLogAPI {
  static final FirebaseFirestore logs = FirebaseFirestore.instance;

  // Adds a log to the list of logs.
  Future<String> addLog(Log log) async {
    try {
      await logs.collection("logs").add({
        "datetime": log.datetime,
        "doer": log.username,
        "action": log.action,
      });
      return "";
    } on FirebaseException catch (e) {
      return "Report unsuccessfully sent ${e.code}: ${e.message}";
    }
  }

  // Fetch logs
  // Check if logs collection exists and fetch logs
  Stream<QuerySnapshot>? fetchLogs() {
    try {
      return logs
          .collection("logs")
          .orderBy("datetime", descending: true)
          .snapshots();
    } on FirebaseException catch (e) {
      print("Error checking logs collection: ${e.message}");
      return null;
    }
  }
}

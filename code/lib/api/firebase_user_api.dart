import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Method for getting the number of approved rooms
  fetchAdminUserCount() async {
    var querySnapshot = await db
        .collection("user")
        .where('is_admin', isEqualTo: true)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms for approval
  fetchNonAdminUserCount() async {
    var querySnapshot = await db
        .collection("user")
        .where('is_admin', isEqualTo: false)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for fetching user admin requests
  Stream<QuerySnapshot> fetchAdminRequests() {
    Stream<QuerySnapshot> results = db
        .collection('user')
        .where('is_request_status', isEqualTo: "requested")
        .snapshots();
    return results;
  }

  // Method for fetching user admin requests
  Stream<QuerySnapshot> fetchAdminRevoked() {
    Stream<QuerySnapshot> results = db
        .collection('user')
        .where('is_request_status', isEqualTo: "revoked")
        .snapshots();
    return results;
  }

  // Method for fetching user admin requests
  Stream<QuerySnapshot> fetchAdminApproved() {
    Stream<QuerySnapshot> results = db
        .collection('user')
        .where('is_request_status', isEqualTo: "approved")
        .snapshots();
    return results;
  }

  // Method for getting the number of rooms
  fetchTotalUserCount() async {
    var querySnapshot = await db.collection("user").count().get();
    return querySnapshot.count;
  }

  // Method for adding a user in the system
  Future<String> addUser(String id, dynamic content) async {
    try {
      await db.collection("user").doc(id).set(content);
      return "Successfully added!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for updating user
  Future<String> updateUser(String id, dynamic content) async {
    try {
      await db.collection("user").doc(id).update(content);
      return "Successfully updated!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for fetching user=
  Future<Map<String, dynamic>?> fetchUserByID(String id) async {
    DocumentReference userRef = db.collection('user').doc(id);

    try {
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}

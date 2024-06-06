import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

// Model
import 'package:hanap/model/UserModel.dart';

class FirebaseRoomAPI {
  // Constants
  String FOR_APPROVAL = "for_approval";
  String REJECTED = "rejected";
  String APPROVED = "approved";
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Method for adding a Room
  Future<String> addRoom() async {
    try {
      DocumentReference entry = await db.collection("rooms").add({});
      return entry.id;
    } on FirebaseException catch (e) {
      return "Room unsuccessfully added ${e.code}: ${e.message}";
    }
  }

  // Method for updating a room
  Future<String> updateRoom(String id, dynamic content) async {
    try {
      await db.collection("rooms").doc(id).update(content);
      return "Successfully update!";
    } on FirebaseException catch (e) {
      return "Room unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for deleting a room
  Future<String> deleteRoom(String id) async {
    try {
      await db.collection("rooms").doc(id).delete();
      return "Successfully delete!";
    } on FirebaseException catch (e) {
      return "Room unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for fetching all approved buildings and with keyword
  Stream<QuerySnapshot> searchRooms(String keyword, List<String> colleges) {
    if (keyword != "" && colleges.isNotEmpty) {
      return db
          .collection('rooms')
          .where('status', isEqualTo: APPROVED)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: keyword + '\uf8ff')
          .where('college', whereIn: colleges)
          .snapshots();
    } else if (keyword == "" && colleges.isNotEmpty) {
      return db
          .collection('rooms')
          .where('status', isEqualTo: APPROVED)
          .where('college', whereIn: colleges)
          .snapshots();
    } else if (keyword != "" && colleges.isEmpty) {
      return db
          .collection('rooms')
          .where('status', isEqualTo: APPROVED)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: keyword + '\uf8ff')
          .snapshots();
    } else {
      return db
          .collection('rooms')
          .where('status', isEqualTo: APPROVED)
          .snapshots();
    }
  }

  // Method for fetching all approved Rooms
  Stream<QuerySnapshot> fetchApprovedRooms() {
    Stream<QuerySnapshot> results =
        db.collection('rooms').where('status', isEqualTo: APPROVED).snapshots();
    return results;
  }

  // Method for fetching all approved Rooms
  Stream<QuerySnapshot> fetchForApprovalRooms() {
    Stream<QuerySnapshot> results = db
        .collection('rooms')
        .where('status', isEqualTo: FOR_APPROVAL)
        .snapshots();
    return results;
  }

  // Method for fetching all approved Rooms
  Stream<QuerySnapshot> fetchRejectedRooms() {
    Stream<QuerySnapshot> results =
        db.collection('rooms').where('status', isEqualTo: REJECTED).snapshots();
    return results;
  }

  // Method for getting the number of approved rooms
  fetchApprovedRoomCount() async {
    var querySnapshot = await db
        .collection("rooms")
        .where('status', isEqualTo: APPROVED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for fetching approved contributed buildings
  Stream<QuerySnapshot> fetchContAppRooms(String id) {
    Stream<QuerySnapshot> results = db
        .collection('rooms')
        .where('status', isEqualTo: APPROVED)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for fetching for approval contributed buildings
  Stream<QuerySnapshot> fetchContForAppRooms(String id) {
    Stream<QuerySnapshot> results = db
        .collection('rooms')
        .where('status', isEqualTo: FOR_APPROVAL)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for fetching rejected contributed buildings
  Stream<QuerySnapshot> fetchContRejRooms(String id) {
    Stream<QuerySnapshot> results = db
        .collection('rooms')
        .where('status', isEqualTo: REJECTED)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for getting the number of rooms for approval
  fetchForApprovalRoomCount() async {
    var querySnapshot = await db
        .collection("rooms")
        .where('status', isEqualTo: FOR_APPROVAL)
        .count()
        .get();
    return querySnapshot.count;
  }

  fetchRejectedRoomCount() async {
    var querySnapshot = await db
        .collection("rooms")
        .where('status', isEqualTo: REJECTED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms
  fetchTotalRoomCount() async {
    var querySnapshot = await db.collection("rooms").count().get();
    return querySnapshot.count;
  }

  // Method for fetching a room given ID, returns document snapshot
  Future<DocumentSnapshot> fetchRoomByID(String id) {
    print(id);
    Future<DocumentSnapshot> room = db.collection('rooms').doc(id).get();
    return room;
  }

  // Method for bookmarking a building
  Future<String> bookmark(String user_id, String room_id) async {
    try {
      await db.collection('user').doc(user_id).update({
        'saved_rooms': FieldValue.arrayUnion([room_id])
      });
      return "Successfully bookmarked!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully bookmarked ${e.code}: ${e.message}";
    }
  }

  // Method for bookmarking a building
  Future<String> unBookMark(String user_id, String room_id) async {
    try {
      await db.collection('user').doc(user_id).update({
        'saved_rooms': FieldValue.arrayRemove([room_id])
      });
      return "Successfully unbookmarked!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully unbookmarked ${e.code}: ${e.message}";
    }
  }

  // Method for listening to saved to rooms
  Stream<List<String>> listenToSaved(UserModel user) {
    return db.collection('user').doc(user.user_id).snapshots().map((snapshot) {
      List<dynamic> saved = snapshot.data()!['saved_rooms'] ?? [];
      return List<String>.from(saved);
    });
  }

  // Method for fetching bldg details
  Stream<List<DocumentSnapshot>> fetchDetails(List<String> buildingIds) {
    if (buildingIds == null || buildingIds.isEmpty) {
      return Stream.value([]);
    }

    List<Stream<DocumentSnapshot>> streams = buildingIds.map((id) {
      return FirebaseFirestore.instance.collection('rooms').doc(id).snapshots();
    }).toList();

    return Rx.combineLatest(
      streams,
      (List<DocumentSnapshot> snapshots) {
        // Filter out null snapshots
        return snapshots.where((snapshot) => snapshot.exists).toList();
      },
    );
  }
}

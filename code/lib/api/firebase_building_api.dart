import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

// Models
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/Floormap.dart';
import 'package:hanap/model/UserModel.dart';

class FirebaseBuildingAPI {
  // Constants
  String FOR_APPROVAL = "for_approval";
  String REJECTED = "rejected";
  String APPROVED = "approved";

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Method for adding a building
  Future<String> addBuilding() async {
    try {
      DocumentReference entry = await db.collection("building").add({});
      return entry.id;
    } on FirebaseException catch (e) {
      return "Building unsuccessfully added ${e.code}: ${e.message}";
    }
  }

  Future<String> updateBuilding(String id, dynamic content) async {
    try {
      await db.collection("building").doc(id).update(content);
      return "Successfully update!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  Future<String> deleteBuilding(String id) async {
    try {
      await db.collection("building").doc(id).delete();
      return "Successfully delete!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully updated ${e.code}: ${e.message}";
    }
  }

  // Method for fetching all approved buildings
  Stream<QuerySnapshot> fetchApprovedBuildings() {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: APPROVED)
        .snapshots();
    return results;
  }

  // Method for fetching all approved buildings
  Stream<QuerySnapshot> fetchBldgsForApproval() {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: FOR_APPROVAL)
        .snapshots();
    return results;
  }

  // Method for fetching all approved buildings
  Stream<QuerySnapshot> fetchBldgsRejected() {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: REJECTED)
        .snapshots();
    return results;
  }

  // Method for fetching approved contributed buildings
  Stream<QuerySnapshot> fetchContAppBldgs(String id) {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: APPROVED)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for fetching approved contributed buildings
  Stream<QuerySnapshot> fetchContForAppBldgs(String id) {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: FOR_APPROVAL)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for fetching approved contributed buildings
  Stream<QuerySnapshot> fetchContRejBldgs(String id) {
    Stream<QuerySnapshot> results = db
        .collection('building')
        .where('status', isEqualTo: REJECTED)
        .where('contributed_by', isEqualTo: id)
        .snapshots();
    return results;
  }

  // Method for fetching all approved buildings and with keyword
  Stream<QuerySnapshot> searchBuilding(String keyword, List<String> colleges) {
    if (keyword != "" && colleges.isNotEmpty) {
      return db
          .collection('building')
          .where('status', isEqualTo: APPROVED)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: keyword + '\uf8ff')
          .where('college', whereIn: colleges)
          .snapshots();
    } else if (keyword == "" && colleges.isNotEmpty) {
      return db
          .collection('building')
          .where('status', isEqualTo: APPROVED)
          .where('college', whereIn: colleges)
          .snapshots();
    } else if (keyword != "" && colleges.isEmpty) {
      return db
          .collection('building')
          .where('status', isEqualTo: APPROVED)
          .where('name', isGreaterThanOrEqualTo: keyword)
          .where('name', isLessThanOrEqualTo: keyword + '\uf8ff')
          .snapshots();
    } else {
      return db
          .collection('building')
          .where('status', isEqualTo: APPROVED)
          .snapshots();
    }
  }

  // Method for fetching a building given ID, returns document snapshot
  Future<DocumentSnapshot> fetchBuildingByID(String id) {
    Future<DocumentSnapshot> building = db.collection('building').doc(id).get();
    return building;
  }

  // Method for fetching all approved buildings
  Future<List<Building>> fetchBuildingsPerCollege(String college) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('building')
        .where('status', isEqualTo: APPROVED)
        .where('college', isEqualTo: college)
        .get();

    // Loop for every building in the returned snapshot
    List<Building> buildings = [];
    for (var doc in snapshot.docs) {
      // Loop for every floormap in the document
      List<Floormap> floormaps = [];
      if (doc['floormaps'] != null) {
        for (var fm in doc['floormaps']) {
          Floormap newFM = Floormap();
          newFM.setInput(fm['level'], null, fm['image_url']);
          floormaps.add(newFM);
        }
      }

      // Initialize building with contents
      Building building = Building(
        doc.id,
        doc['name'],
        doc['popular_names'],
        college,
        doc['description'],
        doc['address'],
        null,
        null,
        floormaps == null ? [] : floormaps,
        APPROVED,
        doc['contributed_by'],
      );
      // Append the initialized building to the list before returning
      buildings.add(building);
    }
    return buildings;
  }

  // Method for getting the number of approved rooms
  fetchApprovedBldgCount() async {
    var querySnapshot = await db
        .collection("building")
        .where('status', isEqualTo: APPROVED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms for approval
  fetchForApprovalBldgCount() async {
    var querySnapshot = await db
        .collection("building")
        .where('status', isEqualTo: FOR_APPROVAL)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms for approval
  fetchRejectedBldgCount() async {
    var querySnapshot = await db
        .collection("building")
        .where('status', isEqualTo: REJECTED)
        .count()
        .get();
    return querySnapshot.count;
  }

  // Method for getting the number of rooms
  fetchTotalBldgCount() async {
    var querySnapshot = await db.collection("building").count().get();
    return querySnapshot.count;
  }

  // Method for bookmarking a building
  Future<String> bookmark(String user_id, String bldg_id) async {
    try {
      await db.collection('user').doc(user_id).update({
        'saved_bldgs': FieldValue.arrayUnion([bldg_id])
      });
      return "Successfully bookmarked!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully bookmarked ${e.code}: ${e.message}";
    }
  }

  // Method for bookmarking a building
  Future<String> unBookMark(String user_id, String bldg_id) async {
    try {
      await db.collection('user').doc(user_id).update({
        'saved_bldgs': FieldValue.arrayRemove([bldg_id])
      });
      return "Successfully unbookmarked!";
    } on FirebaseException catch (e) {
      return "Building unsuccessfully unbookmarked ${e.code}: ${e.message}";
    }
  }

  // Method for fetching bldg details
  Stream<List<DocumentSnapshot>> fetchDetails(List<String> buildingIds) {
    if (buildingIds == null || buildingIds.isEmpty) {
      return Stream.value([]);
    }

    List<Stream<DocumentSnapshot>> streams = buildingIds.map((id) {
      return FirebaseFirestore.instance
          .collection('building')
          .doc(id)
          .snapshots();
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

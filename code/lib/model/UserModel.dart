// Models
import 'Room.dart';
import 'Building.dart';

class UserModel {
  String user_id = '';
  String first_name = '';
  String last_name = '';
  bool is_admin = false; // Default to be Non-Admin
  bool is_superadmin = false;
  String? email;
  String? is_request_status;
  String? is_request_datetime_sent;
  String? is_request_confirmed_by;
  String? is_request_datetime_confirmed;
  String? proof;
  List<String> saved_rooms = [];
  List<String> saved_buildings = [];
  List<Room> contributed_rooms = [];
  List<Building> contributed_buildings = [];

  // Updates the status of Admin
  void updateAdminStatus() {
    is_admin = !is_admin;
  }

  // Updates the contents of saved rooms of user
  void setSavedRooms(List<String> rooms) {
    saved_rooms = rooms;
  }

  // Updates the contents of saved buildings of user
  void setSavedBuildings(List<String> buildings) {
    saved_buildings = buildings;
  }

  UserModel(
    this.user_id,
    this.first_name,
    this.last_name,
  );
}

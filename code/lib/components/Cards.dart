import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Models
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/Room.dart';
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

// This are cards used in the Dashboard screen
Widget dashboardCards(
    String headerTitle, int headerNumber, List<List<dynamic>> content) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: BLUE, width: 1.0),
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(2, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      // Image
      Container(
          height: 80,
          width: 80,
          child: Opacity(
            opacity: 0.4,
            child: Image.asset('assets/images/logo.png'),
          )),
      // Separator
      const SizedBox(width: 15),
      // Main contents
      Expanded(
          child: Column(
        children: [
          // Number of Entity in Total
          Row(
            children: [
              Expanded(
                child: Text(
                  headerTitle,
                  style: HEADER_BLUE,
                ),
              ),
              Text(
                "$headerNumber",
                style: HEADER_GREEN_52,
              )
            ],
          ),
          // Main contents
          for (List<dynamic> list in content)
            Row(
              children: [
                Expanded(
                  child: Text(
                    list[0],
                    style: BODY_TEXT_16,
                  ),
                ),
                Text(
                  "${list[1]}",
                  style: HEADER_BLUE,
                )
              ],
            ),
        ],
      ))
    ]),
  );
}

Widget room_or_bldg_cards(
  String id,
  String image_url,
  String name,
  String address,
  bool isBuilding,
  UserModel user,
  BuildContext context,
) {
  return GestureDetector(
      onTap: () {
        // If the card is pressed, display the corresponding room or building
        if (isBuilding) {
          // Check if included in the list of saved buildings
          // value.unmarkBookmark();
          // for (Building saved in user.saved_buildings) {
          //   if (saved.building_id == value.building_id) {
          //     value.markBookmarked();
          //     break;
          //   }
          // }
          Navigator.pushNamed(context, '/view-building', arguments: id);
        } else {
          // Check if included in the list of saved
          // value.unmarkBookmark();
          // for (Room saved in user.saved_rooms) {
          //   if (saved.room_id == value.room_id) {
          //     value.markBookmarked();
          //     break;
          //   }
          // }
          Navigator.pushNamed(context, '/view-room', arguments: id);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: BLUE, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1), // Shadow offset
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
            color: Colors.white, // Background color
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Building Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                          width: 80,
                          height: 80,
                          child: image_url != null
                              ? Image(
                                  image: NetworkImage(image_url),
                                  fit: BoxFit.cover,
                                )
                              : Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ))),
                    ),
                    // Building Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Building name
                            Text(
                              name,
                              style: HEADER_GREEN,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Building Address
                            Text(
                              address,
                              style: BODY_TEXT,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
}

Widget savedCard(dynamic value, UserModel user, BuildContext context) {
  return GestureDetector(
      onTap: () {
        // When pressed go to page and mark it as bookmarked
        value.markBookmarked();
        // Check if it is a building or a room
        value is Building
            ? Navigator.pushNamed(context, '/view-building', arguments: value)
            : Navigator.pushNamed(context, '/view-room', arguments: value);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: BLUE, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1), // Shadow offset
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
            color: Colors.white, // Background color
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Building Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          value.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Building Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Building name
                            Text(
                              "${value.name}",
                              style: HEADER_GREEN,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Building Address
                            Text(
                              "${value.address}",
                              style: BODY_TEXT,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Delete Btn
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Show prompt that the chosen building has been removed from bookmarks
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "${value.name} unbookmarked!",
                          style: SOURCE_SANS_PRO,
                        ),
                        duration: const Duration(seconds: 1, milliseconds: 100),
                        backgroundColor: BLUE,
                      ));
                      // value is Building
                      //     ? context
                      //         .read<UserProvider>()
                      //         .deleteSavedBuilding(value.building_id!)
                      //     : context
                      //         .read<UserProvider>()
                      //         .deleteSavedRoom(value.building_id!);
                    },
                    child: Icon(
                      Icons.delete,
                      color: BLUE,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
}

// Card for reports
Widget reportCard(dynamic value, BuildContext context) {
  return GestureDetector(
      onTap: () {
        // When pressed go to page
        // Check if it is a building or a room
        Navigator.pushNamed(context, '/view-report', arguments: value);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: BLUE, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1), // Shadow offset
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
            color: Colors.white, // Background coackground color
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Building Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.report_problem_outlined,
                          color: BLUE,
                          size: 80,
                        ),
                      ),
                    ),
                    // Report Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Report ID
                            Text(
                              value.report_id,
                              style: HEADER_GREEN,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Report Sender
                            Text(
                              "${value.sender_name}",
                              style: BODY_TEXT_ITALIC,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Report Sender
                            Text(
                              "${value.description}",
                              style: BODY_TEXT,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
}

// User Request Card
// Card for reports
Widget adminAccessRequestCard(dynamic value, BuildContext context) {
  return GestureDetector(
      onTap: () {
        // When pressed go to page
        // Check if it is a building or a room
        Navigator.pushNamed(context, '/view-admin-reqs-profile',
            arguments: value);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: BLUE, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1), // Shadow offset
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
            color: Colors.white, // Background coackground color
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Building Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.person_rounded,
                          color: BLUE,
                          size: 80,
                        ),
                      ),
                    ),
                    // Report Details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username
                            Text(
                              "${value.first_name} ${value.last_name}",
                              style: HEADER_GREEN,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Report ID
                            Text(
                              value.user_id,
                              style: BODY_TEXT_ITALIC,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Report Sender
                            Text(
                              "${value.is_request_datetime_sent}",
                              style: BODY_TEXT,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
}

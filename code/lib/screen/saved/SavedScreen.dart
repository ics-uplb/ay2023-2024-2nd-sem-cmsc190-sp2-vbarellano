import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Models
import 'package:hanap/model/UserModel.dart';

// API
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Auth_Provider.dart';

class SavedScreen extends StatefulWidget {
  // final Building building;
  // const ViewBuilding({super.key, required this.building});
  const SavedScreen({super.key});

  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // Bookmark value handling
  bool isBuilding = true; // by default, room is displayed

  // Temporary building data

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;
    return Column(children: [
      // Saved Locations
      Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Text(
            "Saved Locations",
            style: HEADER_BLUE_26,
          )),
      // Rooms and Buildings NavBar
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textButton("Buildings ", isBuilding ? GREEN : BLUE, 20, SourceSansPro,
              () {
            setState(() {
              isBuilding = true;
            });
          }),
          textButton("Rooms", isBuilding ? BLUE : GREEN, 20, SourceSansPro, () {
            setState(() {
              isBuilding = false;
            });
          })
        ],
      ),

      Expanded(
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: context
              .watch<UserProvider>()
              .listenToUserSavedDetails(isBuilding ? BUILDING : ROOM),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error encountered! ${snapshot.error}"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child:
                    circularProgressIndicator(), // Replace with your loading indicator widget
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return noContentFiller(
                  "No buildings to show."); // Replace with your no content filler widget
            }

            List<DocumentSnapshot> data = snapshot.data!;

            // If data is available
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return room_or_bldg_cards(
                  data[index].id,
                  data[index]['image_url'],
                  data[index]['name'],
                  data[index]['address'],
                  isBuilding,
                  user,
                  context,
                );
              },
            );
          },
        ),
      ),
    ]);
  }
}

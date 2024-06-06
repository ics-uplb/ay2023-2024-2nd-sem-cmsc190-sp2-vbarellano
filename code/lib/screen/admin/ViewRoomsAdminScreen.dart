import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Model
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/Rooms_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class ViewRoomAdminScreen extends StatefulWidget {
  // final Building building;
  // const ViewBuilding({super.key, required this.building});
  const ViewRoomAdminScreen({super.key});

  @override
  _ViewRoomAdminScreenState createState() => _ViewRoomAdminScreenState();
}

class _ViewRoomAdminScreenState extends State<ViewRoomAdminScreen> {
  // Bookmark value handling
  String status = APPROVED; // by default, room is displayed

  // Temporary building data

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
      floatingActionButton: floatingActionButton(const Icon(Icons.add), () {
        Navigator.pushNamed(context, '/add-room');
      }),
      body: Container(
          padding: padding,
          child: Column(children: [
            // Saved Locations
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  headerNavigation("Rooms", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
            // Rooms NavBar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textButton(
                    "Approved  ",
                    status == APPROVED
                        ? GREEN
                        : status == FOR_APPROVAL
                            ? BLUE
                            : BLUE,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    status = APPROVED;
                  });
                }),
                textButton(
                    "For Approval  ",
                    status == APPROVED
                        ? BLUE
                        : status == FOR_APPROVAL
                            ? GREEN
                            : BLUE,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    status = FOR_APPROVAL;
                  });
                }),
                textButton(
                    "Rejected",
                    status == APPROVED
                        ? BLUE
                        : status == FOR_APPROVAL
                            ? BLUE
                            : GREEN,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    status = REJECTED;
                  });
                })
              ],
            ),

            Expanded(
                child: StreamBuilder(
              stream: status == APPROVED
                  ? context.watch<RoomsProvider>().approvedRooms
                  : status == FOR_APPROVAL
                      ? context.watch<RoomsProvider>().forApprovalRooms
                      : context.watch<RoomsProvider>().rejectedRooms,
              builder:
                  (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error encountered! ${snapshot.error}"),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: circularProgressIndicator(),
                  );
                } else if (snapshot.data!.docs.isEmpty) {
                  return noContentFiller("No rooms to show.");
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: ((context, index) {
                      var value = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return room_or_bldg_cards(
                          snapshot.data!.docs[index].id,
                          value['image_url'],
                          value['name'],
                          value['address'],
                          false,
                          user,
                          context);
                    }));
              },
            ))
          ])),
    );
  }
}

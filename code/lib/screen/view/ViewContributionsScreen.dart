import 'package:flutter/material.dart';
import 'package:hanap/model/Room.dart';
import 'package:provider/provider.dart';
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
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/Rooms_Provider.dart';

// Constants
String FOR_APPROVAL = "for_approval";
String REJECTED = "rejected";
String APPROVED = "approved";

class ViewContributionsScreen extends StatefulWidget {
  // final Building building;
  // const ViewBuilding({super.key, required this.building});
  const ViewContributionsScreen({super.key});

  @override
  _ViewContributionsScreenState createState() =>
      _ViewContributionsScreenState();
}

class _ViewContributionsScreenState extends State<ViewContributionsScreen> {
  // Bookmark value handling
  bool isBuilding = true; // by default, room is displayed
  bool isApproved = true;
  String status = APPROVED;
  // Temporary building data

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
      body: Container(
          padding: padding,
          child: Column(children: [
            // Saved Locations
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  headerNavigation("View Contributions", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),

            // Rooms and Buildings NavBar
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    textButton("Buildings  ", isBuilding ? GREEN : BLUE, 20,
                        SourceSansPro, () {
                      setState(() {
                        isBuilding = true;
                      });
                    }),
                    textButton(
                        "Rooms", isBuilding ? BLUE : GREEN, 20, SourceSansPro,
                        () {
                      setState(() {
                        isBuilding = false;
                      });
                    })
                  ],
                ),
                // Rooms and Buildings NavBar
                if (!user.is_admin)
                  Padding(
                    padding: const EdgeInsets.only(top: 35),
                    child: Row(
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
                  )
              ],
            ),
            // User contributions
            Expanded(
                child: StreamBuilder(
              stream: user.is_admin
                  ? isBuilding
                      ? context
                          .watch<BuildingsProvider>()
                          .fetchContributedApprovedBuildings(user.user_id)
                      : context
                          .watch<RoomsProvider>()
                          .fetchContributedApprovedRooms(user.user_id)
                  : !isBuilding
                      ? status == APPROVED
                          ? context
                              .watch<RoomsProvider>()
                              .fetchContributedApprovedRooms(user.user_id)
                          : status == FOR_APPROVAL
                              ? context
                                  .watch<RoomsProvider>()
                                  .fetchContributedForApprovalRooms(
                                      user.user_id)
                              : context
                                  .watch<RoomsProvider>()
                                  .fetchContributedRejectedRooms(user.user_id)
                      : status == APPROVED
                          ? context
                              .watch<BuildingsProvider>()
                              .fetchContributedApprovedBuildings(user.user_id)
                          : status == FOR_APPROVAL
                              ? context
                                  .watch<BuildingsProvider>()
                                  .fetchContributedForApprovalBuildings(
                                      user.user_id)
                              : context
                                  .watch<BuildingsProvider>()
                                  .fetchContributedRejectedBuildings(
                                      user.user_id),
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
                  return noContentFiller("No contributions to show.");
                }
                // Listview of cards
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return room_or_bldg_cards(
                        snapshot.data!.docs[index].id,
                        data['image_url'],
                        data['name'],
                        data['address'],
                        isBuilding,
                        user,
                        context);
                  }),
                );
              },
            ))
          ])),
    );
  }
}

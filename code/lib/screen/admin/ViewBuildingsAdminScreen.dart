import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanap/api/firebase_building_api.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/NoContentFiller.dart';

// Models
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

// Constants
String FOR_APPROVAL = "requested";
String REJECTED = "rejected";
String APPROVED = "approved";

class ViewBuildingsAdminScreen extends StatefulWidget {
  const ViewBuildingsAdminScreen({super.key});

  @override
  _ViewBuildingsAdminScreenState createState() =>
      _ViewBuildingsAdminScreenState();
}

class _ViewBuildingsAdminScreenState extends State<ViewBuildingsAdminScreen> {
  // Bookmark value handling
  String status = APPROVED; // by default, Buildings is displayed

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
      floatingActionButton: floatingActionButton(const Icon(Icons.add), () {
        Navigator.pushNamed(context, '/add-building');
      }),
      body: Container(
          padding: padding,
          child: Column(children: [
            // Saved Locations
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  headerNavigation("Buildings", () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
            // Buildingss and Buildings NavBar
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
                  ? context.watch<BuildingsProvider>().approvedBldgs
                  : status == FOR_APPROVAL
                      ? context.watch<BuildingsProvider>().forApprovalBldgs
                      : context.watch<BuildingsProvider>().rejectedBldgs,
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
                  return noContentFiller("No buildings to show.");
                }
                // print(snapshot.data!.docs[0].data());
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
                        true,
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

import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanap/components/Cards.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Buttons.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

// Constants
String APPROVED = "approved";
String REQUESTED = "requested";
String REVOKED = "revoked";

class ViewAdminRequestScreen extends StatefulWidget {
  const ViewAdminRequestScreen({super.key});

  @override
  _ViewAdminRequestState createState() => _ViewAdminRequestState();
}

class _ViewAdminRequestState extends State<ViewAdminRequestScreen> {
  String status = APPROVED;
  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
      body: Padding(
        padding: padding,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // HEADER
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                headerNavigation("Admin Users", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),

          // Reportss and Reports NavBar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              textButton(
                  "Approved  ",
                  status == APPROVED
                      ? GREEN
                      : status == REQUESTED
                          ? BLUE
                          : BLUE,
                  20,
                  SourceSansPro, () {
                setState(() {
                  status = APPROVED;
                });
              }),
              textButton(
                  "Requests  ",
                  status == APPROVED
                      ? BLUE
                      : status == REQUESTED
                          ? GREEN
                          : BLUE,
                  20,
                  SourceSansPro, () {
                setState(() {
                  status = REQUESTED;
                });
              }),
              textButton(
                  "Revoked",
                  status == APPROVED
                      ? BLUE
                      : status == REQUESTED
                          ? BLUE
                          : GREEN,
                  20,
                  SourceSansPro, () {
                setState(() {
                  status = REVOKED;
                });
              })
            ],
          ),

          Expanded(
            child: StreamBuilder(
                stream: status == APPROVED
                    ? context.watch<UserProvider>().adminApproved
                    : status == REQUESTED
                        ? context.watch<UserProvider>().adminRequests
                        : context.watch<UserProvider>().adminRevoked,
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
                    return noContentFiller("Nothing to show");
                  }

                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: ((context, index) {
                        var value = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        UserModel user = UserModel(
                          snapshot.data!.docs[index].id,
                          value['first_name'],
                          value['last_name'],
                        );
                        user.is_request_datetime_sent =
                            value['is_request_datetime_sent'];
                        user.is_request_status = value['is_request_status'];
                        user.is_admin = value['is_admin'];
                        user.proof = value['proof'];
                        if (value['is_superadmin'] != null) {
                          user.is_superadmin = value['is_superadmin'];
                        }
                        return adminAccessRequestCard(user, context);
                      }));
                }),
          ),
        ]),
      ),
    );
  }
}

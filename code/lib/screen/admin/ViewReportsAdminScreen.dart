import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Model
import 'package:hanap/model/Report.dart';
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/Report_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class ViewReportsAdminScreen extends StatefulWidget {
  const ViewReportsAdminScreen({super.key});

  @override
  _ViewReportsAdminScreenState createState() => _ViewReportsAdminScreenState();
}

class _ViewReportsAdminScreenState extends State<ViewReportsAdminScreen> {
  // Bookmark value handling
  String currView = 'received'; // by default, Reports is displayed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: padding,
          child: Column(children: [
            // Saved Locations
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                children: [
                  headerNavigation("Reports", () {
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
                    "Received  ",
                    currView == RECEIVED
                        ? GREEN
                        : currView == UNDER_EVAL
                            ? BLUE
                            : BLUE,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    currView = RECEIVED;
                  });

                  print(currView);
                }),
                textButton(
                    "Under Evaluation  ",
                    currView == RECEIVED
                        ? BLUE
                        : currView == UNDER_EVAL
                            ? GREEN
                            : BLUE,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    currView = UNDER_EVAL;
                  });
                  print(currView);
                }),
                textButton(
                    "Resolved",
                    currView == RECEIVED
                        ? BLUE
                        : currView == UNDER_EVAL
                            ? BLUE
                            : GREEN,
                    20,
                    SourceSansPro, () {
                  setState(() {
                    currView = RESOLVED;
                  });
                  print(currView);
                })
              ],
            ),
            Expanded(
                child: StreamBuilder(
              stream: currView == RECEIVED
                  ? context.watch<ReportProvider>().receivedReports
                  : currView == UNDER_EVAL
                      ? context.watch<ReportProvider>().underEvalReports
                      : context.watch<ReportProvider>().resolvedReports,
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
                  return noContentFiller("No reports to show.");
                }

                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: ((context, index) {
                      var value = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      return reportCard(
                          Report(
                            snapshot.data!.docs[index].id,
                            value['sender_id'],
                            value['sender_name'],
                            value['status'],
                            value['datetime_sent'],
                            value['description'],
                            value['datetime_evaluated'] ?? null,
                            value['evaluated_by'] ?? null,
                            value['evaluator_id'] ?? null,
                            value['datetime_resolved'] ?? null,
                            value['resolved_by'] ?? null,
                            value['resolver_id'] ?? null,
                          ),
                          context);
                    }));
              },
            ))
          ])),
    );
  }
}

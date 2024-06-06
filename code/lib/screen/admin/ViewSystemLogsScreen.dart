import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/provider/User_Provider.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/Dashboard_Provider.dart';

class ViewSysLogScreen extends StatefulWidget {
  const ViewSysLogScreen({super.key});

  @override
  _ViewSysLogState createState() => _ViewSysLogState();
}

class _ViewSysLogState extends State<ViewSysLogScreen> {
  bool _logsExist = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLogsCollection();
  }

  // Check if the 'logs' collection exists
  Future<void> checkLogsCollection() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('logs').limit(1).get();
      setState(() {
        _logsExist = querySnapshot.docs.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print("Error checking logs collection: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handler of System Logs
    Stream<QuerySnapshot> logs = context.watch<DashboardProvider>().systemLogs;

    if (_isLoading) {
      return Center(child: circularProgressIndicator());
    }

    return Scaffold(
        body: Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                headerNavigation("System Logs", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          // Labels
          if (_logsExist)
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Datetime and Action",
                  style: HEADER_BLUE,
                )),
          // List of Logs
          Expanded(
            child: SingleChildScrollView(
              child: _logsExist
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('logs')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error encountered: ${snapshot.error}"),
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: circularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Text(
                            "System log is still empty.",
                            style: BODY_TEXT_ITALIC,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            var value = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Text(
                                        "${value['datetime']}",
                                        style: BODY_TEXT_16_ITALIC,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "User ID ${value['doer']} ${value['action']}",
                                        style: BODY_TEXT_16,
                                      ),
                                    ),
                                  ],
                                ));
                          }),
                        );
                      },
                    )
                  : Center(
                      child: noContentFiller("System log is still empty."),
                    ),
            ),
          ),
        ],
      ),
    ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/provider/Rooms_Provider.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Dashboard_Provider.dart';

// Model
import 'package:hanap/model/UserModel.dart';
import 'package:hanap/model/Log.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Provider
  DashboardProvider provider = DashboardProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    // Check if user is an admin. Must be displayed only if an admin.
    Stream<QuerySnapshot> logs = context.watch<DashboardProvider>().systemLogs;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greetings Widget.
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                  child: Text(
                    "Hello, Admin ${user.first_name}!",
                    style: HEADER_GREEN_26,
                  ),
                ),
                // System Logs and List of Logs
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Logs title
                    Text(
                      "System Logs",
                      style: HEADER_BLUE,
                    ),
                    // List of Logs
                    StreamBuilder(
                      stream: logs,
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
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
                          return Text(
                            "System log is still empty.",
                            style: BODY_TEXT_ITALIC,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length > 5
                              ? 5
                              : snapshot.data!.docs.length,
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
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: textButton(
                      "View System Logs", GREEN, 16, SourceSansPro, () {
                    Navigator.pushNamed(context, '/view-syslogs');
                  }),
                ),

                // Number rooms
                Container(
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
                          opacity: 0.75,
                          child: Icon(
                            Icons.meeting_room_rounded,
                            color: BLUE,
                            size: 80,
                          ),
                        )),
                    // Separator
                    const SizedBox(width: 15),
                    // Main contents
                    Expanded(
                        child: Column(
                      children: [
                        // Number of Rooms in Total
                        _buildTotalRooms(),
                        // Approved Rooms
                        _buildApprovedRooms(),
                        // For Approval Rooms
                        _buildForApprovalRooms(),
                        // Rejected Rooms
                        _buildRejectedRooms(),
                      ],
                    ))
                  ]),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: textButton("View Room List", GREEN, 16, SourceSansPro,
                      () async {
                    context.read<DashboardProvider>().getApprovedRoomCount();
                    Navigator.pushNamed(context, '/view-rooms-admin');
                  }),
                ),
                // Number of Buildings
                Container(
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
                          opacity: 0.75,
                          child: Icon(
                            Icons.other_houses_rounded,
                            color: BLUE,
                            size: 80,
                          ),
                        )),
                    // Separator
                    const SizedBox(width: 15),
                    // Main contents
                    Expanded(
                        child: Column(
                      children: [
                        // Number of Building in Total
                        _buildTotalBldgs(),
                        // Approved Buildings
                        _buildApprovedBldgs(),
                        // For Approval Buildings
                        _buildForApprovalBldgs(),
                        // Rejected Buildings
                        _buildRejectedBldgs(),
                      ],
                    ))
                  ]),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: textButton(
                      "View Building List", GREEN, 16, SourceSansPro, () {
                    Navigator.pushNamed(context, '/view-buildings-admin');
                  }),
                ),
                // Number of Users
                if (user.is_superadmin)
                  Container(
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
                            opacity: 0.75,
                            child: Icon(
                              Icons.people,
                              color: BLUE,
                              size: 80,
                            ),
                          )),
                      // Separator
                      const SizedBox(width: 15),
                      // Main contents
                      Expanded(
                          child: Column(
                        children: [
                          // Number of Building in Total
                          _buildTotalUsers(),
                          // Admin Users
                          _buildAdminUsers(),
                          // Non-admin Users
                          _buildNonAdminUsers(),
                        ],
                      ))
                    ]),
                  ),
                if (user.is_superadmin)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: textButton(
                        "View Admin Requests", GREEN, 16, SourceSansPro, () {
                      Navigator.pushNamed(context, '/view-admin-reqs');
                    }),
                  ),
                // Number of Reports
                Container(
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
                          opacity: 0.75,
                          child: Icon(
                            Icons.report,
                            color: BLUE,
                            size: 80,
                          ),
                        )),
                    // Separator
                    const SizedBox(width: 15),
                    // Main contents
                    Expanded(
                        child: Column(
                      children: [
                        // Number of Reports in Total
                        _buildTotalReports(),
                        // Received Reports
                        _buildReceivedReports(),
                        // Under Evaluation Reports
                        _buildUnderEvalReports(),
                        // Resolved Reports
                        _buildResolvedReports(),
                      ],
                    ))
                  ]),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child:
                      textButton("View Reports", GREEN, 16, SourceSansPro, () {
                    Navigator.pushNamed(context, '/view-reports-admin');
                  }),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTotalBldgs() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Total Number\nof Buildings",
            style: HEADER_BLUE,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getTotalBldgCounts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_GREEN_52,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTotalRooms() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Total Number\nof Rooms",
            style: HEADER_BLUE,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getTotalRoomCounts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_GREEN_52,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildApprovedRooms() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Approved Rooms",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getApprovedRoomCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildForApprovalRooms() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "For Approval",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getForApprovalRoomCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRejectedRooms() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Rejected",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getRejectRoomCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildApprovedBldgs() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Approved Buildings",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getApprovedBldgount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildForApprovalBldgs() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "For Approval",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getForApprovalBldgCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRejectedBldgs() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Rejected",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getRejectedBldgCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTotalUsers() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Total Number\nof Users",
            style: HEADER_BLUE,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getTotalUserCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_GREEN_52,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdminUsers() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Admin Users",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getAdminUserCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNonAdminUsers() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Non-Admin Users",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getNonAdminUserCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTotalReports() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Total Number\nof Reports",
            style: HEADER_BLUE,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getTotalReportCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_GREEN_52,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildReceivedReports() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Received",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getReceivedReportCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildUnderEvalReports() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Under Evaluation",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getUnderEvalReportCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildResolvedReports() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Resolved",
            style: BODY_TEXT_16,
          ),
        ),
        FutureBuilder(
          future: context.read<DashboardProvider>().getResolvedReportCount(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgressIndicator();
            } else if (!snapshot.hasData) {
              return Text(
                "--",
                style: HEADER_BLUE,
              );
            } else {
              return Text(
                "${snapshot.data}",
                style: HEADER_BLUE,
              );
            }
          },
        ),
      ],
    );
  }
}

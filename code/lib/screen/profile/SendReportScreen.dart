import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';

// Provider
import 'package:hanap/provider/Report_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

// Model
import 'package:hanap/model/UserModel.dart';

class SendReport extends StatefulWidget {
  // final Building building;
  // const SendReport({super.key, required this.building});
  const SendReport({super.key});

  @override
  _SendReportState createState() => _SendReportState();
}

class _SendReportState extends State<SendReport> {
  // Bookmark value handling
  bool isBookmarked = false;
  bool _isLoading = false;

  // Controller Declaration
  final TextEditingController _reportDescController = TextEditingController();

  // Initial State
  @override
  void initState() {
    super.initState();
    _reportDescController.addListener(() {});
  }

  // Dispose
  @override
  void dispose() {
    _reportDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        body: Stack(children: [
      Padding(
        padding: padding,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // HEADER
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                headerNavigation("Send a Report", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(children: [
                      // Report Description
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Enter Description",
                              style: HEADER_BLUE,
                            ),
                          )),
                      textFieldWithLines(
                          _reportDescController, "Specify your concern.", 5,
                          (value) {
                        if (value!.isEmpty) {
                          return "Report description is empty.";
                        }
                      }),
                    ]))),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: elevatedButton("Send Report", GREEN, () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });
                await context.read<ReportProvider>().sendReport(
                      user.user_id,
                      "${user.first_name} ${user.last_name}",
                      _reportDescController.text,
                    );
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context);
                showScafolledMessage(context, "Report sent!");
              }
            }),
          )
        ]),
      ),
      if (_isLoading)
        Container(
          color: Colors.white.withOpacity(0.75),
          child: Center(
            child: circularProgressIndicator(),
          ),
        ),
    ]));
  }
}

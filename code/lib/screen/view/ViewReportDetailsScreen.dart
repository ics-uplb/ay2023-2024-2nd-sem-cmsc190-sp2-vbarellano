import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';

// Model
import 'package:hanap/model/Report.dart';
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Report_Provider.dart';

class ViewReportDetails extends StatefulWidget {
  final Report report;
  const ViewReportDetails({super.key, required this.report});

  @override
  _ViewReportDetailsState createState() => _ViewReportDetailsState();
}

class _ViewReportDetailsState extends State<ViewReportDetails> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    // User watching
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
        body: Stack(children: [
      Padding(
        padding: padding,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // Header (Back arrow, bldg name, bookmark button)
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Row(
              children: [
                headerNavigation("Report Details", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
              // REPORT ID
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Report ID",
                  style: HEADER_BLUE,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.report.report_id!,
                      style: BODY_TEXT_16,
                    ),
                  )),

              //  SENDER Details
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Sender Details",
                      style: HEADER_BLUE,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Name: ${widget.report.sender_name}",
                      style: BODY_TEXT_16,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "ID: ${widget.report.sender_id}",
                      style: BODY_TEXT_16,
                    ),
                  )),

              // STATUS
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Status",
                      style: HEADER_BLUE,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.report.status == "received"
                          ? "Received"
                          : widget.report.status == "under_evaluation"
                              ? "Under Evaluation"
                              : "Resolved",
                      style: BODY_TEXT_16,
                    ),
                  )),

              // DATETIME SENT
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Datetime Sent",
                      style: HEADER_BLUE,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.report.datetime_sent,
                      style: BODY_TEXT_16,
                    ),
                  )),

              // REPORT DESCRIPTION
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Description",
                      style: HEADER_BLUE,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.report.description,
                      style: BODY_TEXT_16,
                    ),
                  )),

              // DATETIME EVALUATION
              if (widget.report.datetime_evaluated != null)
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Datetime Marked as Under Evaluation",
                        style: HEADER_BLUE,
                      ),
                    )),
              if (widget.report.datetime_evaluated != null)
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.report.datetime_evaluated!,
                        style: BODY_TEXT_16,
                      ),
                    )),

              // EVALUATED BY
              if (widget.report.evaluated_by != null)
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Evaluated By",
                        style: HEADER_BLUE,
                      ),
                    )),
              if (widget.report.evaluated_by != null)
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Name: ${widget.report.evaluated_by!}",
                        style: BODY_TEXT_16,
                      ),
                    )),
              if (widget.report.evaluated_by != null)
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "ID: ${widget.report.evaluator_id}",
                        style: BODY_TEXT_16,
                      ),
                    )),

              // DATETIME RESOLVED
              if (widget.report.datetime_resolved != null)
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Datetime Marked as Resolved",
                        style: HEADER_BLUE,
                      ),
                    )),
              if (widget.report.datetime_resolved != null)
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.report.datetime_resolved!,
                        style: BODY_TEXT_16,
                      ),
                    )),

              // RESOLVED BY
              if (widget.report.resolved_by != null)
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Resolved By",
                        style: HEADER_BLUE,
                      ),
                    )),
              if (widget.report.resolved_by != null)
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Name: ${widget.report.resolved_by!}",
                        style: BODY_TEXT_16,
                      ),
                    )),

              // TO DO: Implement handling of floor maps
            ])),
          ),
          if (widget.report.status == "received")
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child:
                  elevatedButton("Mark as Under Evaluation", GREEN, () async {
                setState(() {
                  _isLoading = true;
                });
                await context.read<ReportProvider>().mark_UnderEval(
                      widget.report.report_id!,
                      user.user_id,
                      "${user.first_name} ${user.last_name}",
                    );
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context);
                showScafolledMessage(
                    context, "Report marked as under evaluation!");
              }),
            ),

          if (widget.report.status == "under_evaluation")
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: elevatedButton("Mark as Resolved", GREEN, () async {
                setState(() {
                  _isLoading = true;
                });
                await context.read<ReportProvider>().mark_Resolved(
                      widget.report.report_id!,
                      user.user_id,
                      "${user.first_name} ${user.last_name}",
                    );
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context);
                showScafolledMessage(context, "Report marked as resolved!");
              }),
            ),

          if (widget.report.status == "resolved")
            SizedBox(
              height: 20,
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

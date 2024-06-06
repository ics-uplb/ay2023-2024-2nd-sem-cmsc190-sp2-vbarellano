import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfileScreen> {
  bool _logsExist = false;

  @override
  Widget build(BuildContext context) {
    // Handler of User
    UserModel user = context.watch<UserProvider>().user;

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
                headerNavigation("My Profile", () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          // List of Logs
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User ID
                  _buildSection("User ID", user.user_id),
                  // FULL NAME
                  _buildSection(
                      "Full Name", "${user.first_name} ${user.last_name}"),
                  // EMAIL
                  _buildSection("Email", user.email!),
                  // USER TYPE
                  _buildSection(
                      "User Type",
                      user.is_superadmin
                          ? "Superadmin"
                          : user.is_admin
                              ? "Admin"
                              : "Non-Admin"),
                  // REQUEST STATUS
                  if (user.is_request_status != null)
                    _buildSection(
                        "Request Status",
                        user.is_request_status == "revoked"
                            ? "Admin Access - Revoked, now Non-Admin"
                            : user.is_request_status == "requested"
                                ? "Requested"
                                : user.is_request_status == "rejected"
                                    ? "Rejected"
                                    : "Approved"),

                  // DATETIME REQUEST SENT
                  if (user.is_request_datetime_sent != null)
                    _buildSection(
                      "Datetime Sent",
                      user.is_request_datetime_sent!,
                    ),

                  // REQUEST ATTACHMENT
                  if (user.proof != null) _buildSectionProof(user.proof),

                  // APPROVED BY
                  if (user.is_request_confirmed_by != null &&
                      user.is_request_status != "requested")
                    _buildSection(
                      "Evaluated By",
                      user.is_request_confirmed_by!,
                    ),
                  // DATETIME EVALUATED
                  if (user.is_request_datetime_confirmed != null &&
                      user.is_request_status != "requested")
                    _buildSection(
                      "Datetime Evaluated",
                      user.is_request_datetime_confirmed!,
                    ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              title,
              style: HEADER_BLUE,
            )),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            content,
            style: BODY_TEXT_16,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionProof(String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Request Attachment",
              style: HEADER_BLUE,
            )),
        _buildProofImage(imageUrl)
      ],
    );
  }

  Widget _buildProofImage(String? imageUrl) {
    if (imageUrl == null) return const SizedBox();
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 5),
      width: double.infinity,
      child: Image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}

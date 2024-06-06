import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/screen/admin/ViewAdminRequestsScreen.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/Modal.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

class ViewAdminRequestDetailsScreen extends StatefulWidget {
  final UserModel user;
  ViewAdminRequestDetailsScreen({super.key, required this.user});

  @override
  _ViewAdminRequestDetailsState createState() =>
      _ViewAdminRequestDetailsState();
}

class _ViewAdminRequestDetailsState
    extends State<ViewAdminRequestDetailsScreen> {
  bool _isLoading = false;

  // Handler of User
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    UserModel myUser = context.watch<UserProvider>().user;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(
                16.0), // Assuming padding is defined somewhere
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User ID
                        Text(
                          "User ID",
                          style: HEADER_BLUE,
                        ),
                        _buildSectionContent(user.user_id),
                        // FULL NAME
                        _buildSectionHeader("Full Name"),
                        _buildSectionContent(
                            "${user.first_name} ${user.last_name}"),
                        // USER TYPE
                        _buildSectionHeader("User Type"),
                        _buildSectionContent(
                          user.is_superadmin
                              ? "Superadmin"
                              : user.is_admin
                                  ? "Admin"
                                  : "Non-Admin",
                        ),
                        // REQUEST STATUS
                        if (user.is_request_status != null)
                          _buildSectionHeader("Request Status"),
                        if (user.is_request_status != null)
                          _buildSectionContent(
                              user.is_request_status == "requested"
                                  ? "Requested"
                                  : "Approved"),
                        // DATETIME REQUEST SENT
                        if (user.is_request_datetime_sent != null)
                          _buildSectionHeader("Datetime Request Sent"),
                        if (user.is_request_datetime_sent != null)
                          _buildSectionContent(user.is_request_datetime_sent!),
                        if (user.proof != null)
                          _buildSectionHeader("Request Attachment"),
                        if (user.proof != null) _buildProofImage(user.proof),
                        // APPROVED BY
                        if (user.is_request_confirmed_by != null)
                          _buildSectionHeader("Evaluated By"),
                        if (user.is_request_confirmed_by != null)
                          _buildSectionContent(user.is_request_confirmed_by!),
                        // APPROVED BY
                        if (user.is_request_datetime_confirmed != null)
                          _buildSectionHeader("Datetime Evaluated"),
                        if (user.is_request_datetime_confirmed != null)
                          _buildSectionContent(
                              user.is_request_datetime_confirmed!),
                      ],
                    ),
                  ),
                ),
                if (user.is_request_status == "requested")
                  _buildAdminControlBtns(),
                if (user.is_request_status == "approved")
                  _buildSuperadminControlBtns(),
                if (user.is_request_status == "revoked")
                  const SizedBox(height: 20)
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.75),
              child: Center(
                child: circularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProofImage(String? imageUrl) {
    if (imageUrl == null) return Container();
    return Container(
      padding: const EdgeInsets.only(top: 5),
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: HEADER_BLUE,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        content,
        style: BODY_TEXT_16,
      ),
    );
  }

  Widget _buildAdminControlBtns() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        Expanded(
            child: elevatedButton("Reject", Colors.red, () {
          modal(context, "Reject Admin Access",
              "Are you sure you want to reject admin request of this user?",
              () async {
            Navigator.pop(context);
            setState(() {
              _isLoading = true;
            });
            await context
                .read<UserProvider>()
                .rejectAdminAccessRequest(user.user_id);
            setState(() {
              _isLoading = false;
            });
            showScafolledMessage(context, "Admin access request rejected!");
            Navigator.pop(context);
          });
        })),
        const SizedBox(width: 10),
        Expanded(
            child: elevatedButton("Approve", GREEN, () {
          modal(context, "Approve Admin Access?",
              "By approving this request, you understand that the user will have access to all admin features.",
              () async {
            Navigator.pop(context);
            setState(() {
              _isLoading = true;
            });
            await context
                .read<UserProvider>()
                .approveAdminAccessRequest(user.user_id);
            setState(() {
              _isLoading = false;
            });
            showScafolledMessage(context, "Admin access request approved!");
            Navigator.pop(context);
          });
        }))
      ]),
    );
  }

  Widget _buildSuperadminControlBtns() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(children: [
        elevatedButton("Add as Superadmin", GREEN, () {
          if (user.is_admin && !user.is_superadmin) {
            modal(context, "Add as Superadmin",
                "Are you sure you want to make this user as superadmin? This action cannot be undone.",
                () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              await context
                  .read<UserProvider>()
                  .giveSuperadminAccess(user.user_id);
              setState(() {
                _isLoading = false;
              });
              showScafolledMessage(
                  context, "User ${user.first_name} now superadmin!");
              Navigator.pop(context);
            });
          } else {
            showScafolledMessage(context, "User is already a superadmin.");
          }
        }),
        const SizedBox(height: 5),
        elevatedButton("Revoke Admin Access", Colors.redAccent, () {
          if (user.is_admin && !user.is_superadmin) {
            modal(context, "Revoke Admin Access",
                "Are you sure you want to revoke admin access of this user? This will remove all admin access of the user.",
                () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              await context
                  .read<UserProvider>()
                  .revokeAdminAccess(user.user_id);
              setState(() {
                _isLoading = false;
              });
              showScafolledMessage(
                  context, "Admin access of ${user.first_name} revoked!");
              Navigator.pop(context);
            });
          } else {
            showScafolledMessage(context, "You cannot revoke a superadmin");
          }
        }),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        children: [
          headerNavigation("Request Profile", () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}

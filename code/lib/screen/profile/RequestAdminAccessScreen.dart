import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Components
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/Modal.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';
import 'dart:io';
import 'package:hanap/components/ImageConstants.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';

// Model
import 'package:hanap/model/UserModel.dart';

class RequestAdminAccess extends StatefulWidget {
  const RequestAdminAccess({super.key});

  @override
  _RequestAdminAccessState createState() => _RequestAdminAccessState();
}

class _RequestAdminAccessState extends State<RequestAdminAccess> {
  // Bookmark value handling
  bool isBookmarked = false;
  bool _isLoading = false;
  File? proof;

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
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(children: [
                      // Opening paragraph
                      _buildSectionHeader("What are admin users?"),
                      _buildSectionParagraph(
                          "Admin users ensure and manage the accuracy and correctness of data in the app. The following summarizes the roles and responsibilities of admin users:"),
                      // Roles and responsibilities
                      _buildSectionHeader("Roles and Responsibilties"),
                      // Rooms and Building Data Management
                      _buildSubsectionHeader(
                          "Rooms and Building Data Management"),
                      _buildSectionParagraph(
                          "Data Approval and Rejection: The application relies on crowd-sourced data contributions. Admin users are responsible for approving or rejecting these contributions to ensure data accuracy and correctness."),
                      _buildSectionParagraph(
                          "Direct Contributions: Admin users may directly contribute to the system and manage existing data to maintain data integrity."),
                      // Report Management
                      _buildSubsectionHeader("Report Management"),
                      _buildSectionParagraph(
                          "Issue Resolution: Non-admin users can send reports to admins regarding any problems or inaccuracies in the system. Admin users are responsible for evaluating these reports and resolving the issues."),
                      // Requirements
                      _buildSectionHeader("Requirements"),
                      _buildSectionParagraph(
                          "To become an admin user, a non-admin user must be a faculty member, utility staff, or a university-affiliated official. Proof of this affiliation must be provided."),
                      _buildImageProof(),
                      _buildSectionProofBtns(),
                      // By proceeding...
                      _buildSectionHeader("By proceeding, you agree that:"),
                      _buildSectionParagraph(
                          "1. You understand the roles and responsibilities of an admin user."),
                      _buildSectionParagraph(
                          "2. You assure that any documents attached as proof are correct and valid."),
                      _buildSectionParagraph(
                          "3. You acknowledge that failure to fulfill your roles and responsibilities may result in the revocation of your admin access."),
                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: elevatedButton("Send Request", GREEN, () async {
                          if (proof != null) {
                            modal(context, "Request Admin Access",
                                "By proceeding, I assure that I have read and understand the roles and responsibilities of an admin. I also assure that the proof is correct and accurate.",
                                () async {
                              Navigator.pop(context);
                              setState(() {
                                _isLoading = true;
                              });
                              await context
                                  .read<UserProvider>()
                                  .requestAdminAccess(user.user_id, proof);
                              setState(() {
                                _isLoading = true;
                              });
                              showScafolledMessage(context, "Request Sent");
                              Navigator.pop(context);
                            });
                          } else {
                            showScafolledMessage(context,
                                "Please attach proof for admin validation.");
                          }
                        }),
                      )
                    ]))),
          ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        children: [
          headerNavigation("Request Admin Access", () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: HEADER_BLUE_23,
        ),
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: HEADER_BLUE,
        ),
      ),
    );
  }

  Widget _buildSectionParagraph(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          content,
          style: BODY_TEXT_16,
        ),
      ),
    );
  }

  Widget _buildImageProof() {
    return Column(
      children: [
        // Exterior Image
        proof != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(
                        proof!,
                        fit: BoxFit.cover,
                      ),
                    )))
            : const SizedBox(),

        if (proof == null)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please upload proof for admin access validation.",
                style: VALIDATE_TEXT,
              )),
      ],
    );
  }

  Widget _buildSectionProofBtns() {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                // Display take picture from camera
                textButton(
                    proof == null
                        ? "Capture proof using camera"
                        : "Change proof using camera",
                    GREEN,
                    15,
                    SourceSansPro, () async {
                  // Call pick image from gallery
                  final returnedImage = await pickImageFromCamera();
                  if (returnedImage != null) {
                    setState(() {
                      proof = returnedImage;
                    });
                  }
                }),
                // Pick image from gallery
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: textButton(
                      proof == null
                          ? "Pick proof from gallery"
                          : "Change picked proof from gallery",
                      GREEN,
                      15,
                      SourceSansPro, () async {
                    // Call pick image from gallery
                    final returnedImage = await pickImageFromGallery();
                    if (returnedImage != null) {
                      setState(() {
                        proof = returnedImage;
                      });
                    }
                  }),
                ),
                // Display reset picture
                if (proof != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: textButton(
                        "Remove proof image", GREEN, 15, SourceSansPro, () {
                      // Reset image to null
                      setState(() {
                        proof = null;
                      });
                    }),
                  )
              ],
            )),
      ],
    );
  }
}

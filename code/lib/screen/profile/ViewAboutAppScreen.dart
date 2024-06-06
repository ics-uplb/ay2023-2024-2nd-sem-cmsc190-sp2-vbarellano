import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutAppScreen> {
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
          _buildHeader(context),
          // List of Logs
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APP TITLE
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Hanap", style: HEADER_GREEN),
                        Text("UPLB Class Venue Finder", style: BODY_TEXT),
                        Text("Mobile Application", style: BODY_TEXT),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                _buildSectionParagraph(
                    "Hanap is a mobile application designed to assist students and faculty at the University of the Philippines Los Baños (UPLB) in finding their class assignments. By providing a user-friendly platform that displays instructions, Hanap aims to enhance wayfinding efficiency, reduce stress, and improve the overall experience in wayfinding. Users can search for and bookmark rooms and buildings, contribute new information, and report issues for admin review."),
                // DEVELOPER
                const SizedBox(height: 10),
                _buildSectionHeader("Developer"),
                _buildSectionParagraph(
                    "Von Michael B. Arellano\nBS Computer Science\nUniversity of the Philippines Los Baños (UPLB)"),
                const SizedBox(height: 10),
              ],
            ),
          )),
        ],
      ),
    ));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        children: [
          headerNavigation("About the Application", () {
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
}

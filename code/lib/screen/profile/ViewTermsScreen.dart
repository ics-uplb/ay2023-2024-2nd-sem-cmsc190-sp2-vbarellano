import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditionsScreen> {
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
                _buildSectionParagraph(
                    "Welcome to Hanap: UPLB Class Venue Finder Mobile Application (\"Hanap\" or the \"App\"), owned and operated by Von Michael B. Arellano (\"we,\" \"us,\" or \"our\"). By accessing or using Hanap, you agree to be bound by the following Terms and Conditions (\"Terms\"). If you do not agree to these Terms, please refrain from using Hanap."),
                // PURPOSE
                _buildSectionHeader("Purpose"),
                _buildSectionParagraph(
                    "Hanap aims to assist users in locating rooms within UPLB for wayfinding purposes."),
                // USER INTERACTION
                _buildSectionHeader("User Interaction"),
                _buildSectionParagraph(
                    "Users may interact with Hanap by searching through the app. Both admins and non-admins have access to location information. Users can contribute to the system by adding buildings and rooms, though non-admin contributions require admin approval. Admins are responsible for managing building and room data. Users may also submit reports for admin review. Additionally, non-admin users have the ability to bookmark content."),
                // DATA COLLECTION
                _buildSectionHeader("Data Collection"),
                _buildSectionParagraph(
                    "Hanap collects various types of data from users, including location data, bookmarked buildings, names, email addresses, passwords, and usage data."),
                // USER CONTENT
                _buildSectionHeader("User Content"),
                _buildSectionParagraph(
                    "Users can contribute content to Hanap by adding buildings and rooms. Images are required and can be captured via the camera or selected from the gallery."),
                // MONETIZATION
                _buildSectionHeader("Monetization"),
                _buildSectionParagraph(
                    "Hanap does not include any monetization features such as in-app purchases, subscriptions, or ads."),
                // THIRD-PARTY SERVICES
                _buildSectionHeader("Third-Party Services"),
                _buildSectionParagraph(
                    "Hanap utilizes third-party services including the geolocator, Firebase Firestore for authentication and storage, and the Mapbox API."),
                // USER CONDUCT
                _buildSectionHeader("User Conduct"),
                _buildSectionParagraph(
                    "Users and contributors must provide accurate information as the app relies on crowdsourcing for data accuracy."),
                // LIABILITY
                _buildSectionHeader("Liability"),
                _buildSectionParagraph(
                    "We disclaim any liabilities arising from the use of Hanap. Users are solely responsible for their interactions and contributions within the app."),
                // MODIFICATIONS
                _buildSectionHeader("Modifications"),
                _buildSectionParagraph(
                    "We reserve the right to modify or update these Terms at any time. Continued use of Hanap after any such changes constitutes acceptance of the revised Terms."),
                // GOVERNING LAW
                _buildSectionHeader("Governing Law"),
                _buildSectionParagraph(
                    "These Terms are governed by and construed in accordance with the laws of Philippines, without regard to its conflict of law provisions."),
                // CONTACT US
                _buildSectionHeader("Contact Us"),
                _buildSectionParagraph(
                    "If you have any questions about these Terms, please contact us at app.hanap@gmail.com."),
                const SizedBox(height: 10),
                _buildSectionParagraph(
                    "By using Hanap, you acknowledge that you have read, understood, and agree to be bound by these Terms."),
                const SizedBox(height: 10),
                _buildSectionParagraph("Last Updated: June 2, 2024, 16:00 PST"),
                const SizedBox(height: 20),
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
          headerNavigation("Terms and Conditions", () {
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

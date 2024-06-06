import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Auth_Provider.dart';

class ProfileScreen extends StatefulWidget {
  final Function(int) changeScreen; // Callback to change the screen
  final Function(int) changeIndex; // Callback to change the screen

  const ProfileScreen({
    Key? key,
    required this.changeScreen,
    required this.changeIndex,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;
    bool _isLoading = false;

    return Stack(children: [
      !user.is_admin
          // NON-ADMIN BUTTONS
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PROFILE ICON
                Center(
                  // Center the icon horizontally
                  child: Icon(
                    Icons.person,
                    color: BLUE,
                    size: 80,
                  ),
                ),
                // NAME
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    user.first_name,
                    style: HEADER_GREEN_26,
                  ),
                ),
                // ROLE - NON ADMIN
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Non-Admin",
                    style: BODY_TEXT,
                  ),
                ),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // VIEW PROFILE
                textButtonWithIcon(
                    "View My Profile",
                    Icon(Icons.person_pin_circle, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-my-profile');
                }),
                // VIEW SAVED LOCATIONNS
                textButtonWithIcon(
                    "View Saved Locations",
                    Icon(Icons.bookmark, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  widget.changeScreen(2);
                }),
                // VIEW MY CONTRIBUTIONS
                textButtonWithIcon(
                    "View My Contributions",
                    Icon(Icons.my_library_add_outlined, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-my-contributions');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // ADD A BUILDING
                textButtonWithIcon(
                    "Contribute a Bulding",
                    Icon(Icons.domain_add_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/add-building');
                }),
                textButtonWithIcon(
                    "Contribute a Room",
                    Icon(Icons.door_back_door_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/add-room');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // SEND A REPORT
                textButtonWithIcon(
                    "Send a Report",
                    Icon(Icons.flag, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  print(user.first_name);
                  Navigator.pushNamed(context, '/send-report');
                }),
                textButtonWithIcon(
                    "Request Admin Access",
                    Icon(Icons.flag, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/request-admin-access');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // VIEW TERMS AND CONDITIONS
                textButtonWithIcon(
                    "Terms and Conditions",
                    Icon(Icons.file_copy_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-terms-and-conditions');
                }),
                // VIEW ABOUT THE APPLICATION
                textButtonWithIcon(
                    "About the Application",
                    Icon(Icons.info_outline, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-about-app');
                }),
              ],
            )
          // ADMIN BUTTONS
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PROFILE ICON
                Center(
                  // Center the icon horizontally
                  child: Icon(
                    Icons.person,
                    color: BLUE,
                    size: 80,
                  ),
                ),
                // NAME
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    user.first_name,
                    style: HEADER_GREEN_26,
                  ),
                ),
                // ROLE - NON ADMIN
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    user.is_superadmin ? "Superadmin" : "Admin",
                    style: BODY_TEXT,
                  ),
                ),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // VIEW PROFILE
                textButtonWithIcon(
                    "View My Profile",
                    Icon(Icons.person_pin_circle, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-my-profile');
                }),
                // VIEW MY CONTRIBUTIONS
                textButtonWithIcon(
                    "View My Contributions",
                    Icon(Icons.my_library_add_outlined, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-my-contributions');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // ADD A BUILDING
                textButtonWithIcon(
                    "Add a Building",
                    Icon(Icons.domain_add_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/add-building');
                }),
                textButtonWithIcon(
                    "Add a Room",
                    Icon(Icons.door_back_door_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/add-room');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // SEND A REPORT
                textButtonWithIcon(
                    "View System Reports",
                    Icon(Icons.report, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-reports-admin');
                }),
                textButtonWithIcon(
                    "View System Logs",
                    Icon(Icons.description_outlined, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-syslogs');
                }),
                // -------------------------------------------------------------------
                // DIVIDER
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Divider(
                      color: BLUE,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    )),
                // VIEW TERMS AND CONDITIONS
                textButtonWithIcon(
                    "Terms and Conditions",
                    Icon(Icons.file_copy_sharp, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-terms-and-conditions');
                }),
                // VIEW ABOUT THE APPLICATION
                textButtonWithIcon(
                    "About the Application",
                    Icon(Icons.info_outline, color: BLUE, size: 20),
                    BLUE,
                    16,
                    "Quicksand",
                    false,
                    true, () {
                  Navigator.pushNamed(context, '/view-about-app');
                }),
              ],
            ),

      // LOG OUT BUTTON
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.center,
            child: textButtonWithIcon(
                "Log Out",
                Icon(Icons.logout, color: GREEN, size: 22),
                GREEN,
                24,
                "Source Sans Pro",
                true,
                false, () async {
              widget.changeIndex(0);
              setState(() {
                _isLoading = true;
              });
              await context.read<AuthProvider>().signOut();
            }),
          )
        ],
      ),
      // CIRCULAR PROGRESS INDICATOR
      if (_isLoading)
        Container(
          color: Colors.white.withOpacity(0.75),
          child: Center(
            child: circularProgressIndicator(),
          ),
        ),
    ]);
  }
}

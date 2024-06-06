import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Themes
import 'package:hanap/Themes.dart';

// Components
import 'package:hanap/components/NavBar.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Screens
import 'package:hanap/screen/explore/ExploreScreen.dart';
import 'package:hanap/screen/explore/MapScreen.dart';
import 'package:hanap/screen/saved/SavedScreen.dart';
import 'package:hanap/screen/profile/ProfileScreen.dart';
import 'package:hanap/screen/admin/DashboardScreen.dart';
import 'package:hanap/screen/user_authentication/LogInScreen.dart';

// Models
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Auth_Provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int selectedIndex;
  bool isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _changeIndex(int index) {
    selectedIndex = index;
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    authProvider.authService.getUser().listen((User? user) async {
      if (user != null) {
        setState(() {
          isLoading = true;
        });
        var data = await userProvider.fetchUserByID(user.uid);
        userProvider.setUserData(user.uid, user.email!, data!);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to admin status
    UserModel user = context.watch<UserProvider>().user;
    Stream<User?> userStream = context.watch<AuthProvider>().uStream;

    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Text("Error encountered! ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                  circularProgressIndicator()
                ]),
          );
        } else if (!snapshot.hasData) {
          return LogIn();
        }

        return isLoading
            ? Scaffold(
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                Text("UPLB Class Venue Finder",
                                    style: BODY_TEXT),
                                Text("Mobile Application", style: BODY_TEXT),
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: circularProgressIndicator(),
                      )
                    ]),
              )
            : Scaffold(
                bottomNavigationBar: BottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: _onItemTapped,
                ),
                // Customized padding for specific screens
                body: Padding(
                  padding: user.is_admin
                      ? selectedIndex == 1
                          ? EdgeInsets.zero
                          : padding
                      : selectedIndex == 0
                          ? EdgeInsets.zero
                          : padding,
                  child: user.is_admin
                      ? _buildScreenAdmin(selectedIndex)
                      : _buildScreenNonAdmin(selectedIndex),
                ),
              );
      },
    );
  }

  // Method to build the appropriate screen based on the selected index
  Widget _buildScreenNonAdmin(int index) {
    switch (index) {
      case 0:
        return MapsScreen(changeScreen: _onItemTapped);
      case 1:
        return ExploreScreen();
      case 2:
        return SavedScreen();
      case 3:
        return ProfileScreen(
          changeScreen: _onItemTapped,
          changeIndex: _changeIndex,
        );
      default:
        return Container(); // Return empty container if index is out of range
    }
  }

  // Method to build the appropriate screen based on the selected index
  Widget _buildScreenAdmin(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return MapsScreen(changeScreen: _onItemTapped);
      case 2:
        return ExploreScreen();
      case 3:
        return ProfileScreen(
          changeScreen: _onItemTapped,
          changeIndex: _changeIndex,
        );
      default:
        return Container(); // Return empty container if index is out of range
    }
  }
}

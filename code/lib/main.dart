import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Themes
import 'package:hanap/Themes.dart';

// Models
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/Room.dart';

// Application Screens
import 'screen/user_authentication/LogInScreen.dart';
import 'screen/user_authentication/SignUpScreen.dart';
import 'screen/view/ViewBldgDetailsScreen.dart';
import 'screen/view/ViewRoomDetailsScreen.dart';
import 'screen/view/ViewReportDetailsScreen.dart';
import 'screen/view/ViewProfileScreen.dart';
import 'screen/view/ViewContributionsScreen.dart';
import 'screen/view/ViewBldgMapScreen.dart';
import 'screen/saved/SavedScreen.dart';
import 'screen/profile/SendReportScreen.dart';
import 'screen/profile/RequestAdminAccessScreen.dart';
import 'screen/profile/ViewTermsScreen.dart';
import 'screen/profile/ViewAboutAppScreen.dart';
import 'screen/create/AddBuildingScreen.dart';
import 'screen/create/AddRoomScreen.dart';
import 'screen/home/HomeScreen.dart';
import 'screen/admin/DashboardScreen.dart';
import 'screen/admin/ViewSystemLogsScreen.dart';
import 'screen/admin/ViewRoomsAdminScreen.dart';
import 'screen/admin/ViewBuildingsAdminScreen.dart';
import 'screen/admin/ViewAdminRequestsScreen.dart';
import 'screen/admin/ViewReportsAdminScreen.dart';
import 'screen/admin/ViewAdminRequestDetailsScreen.dart';
import 'screen/edit/EditBldgDetailsScreen.dart';
import 'screen/edit/EditRoomDetailsScreen.dart';

// Models
import 'model/Building.dart';
import 'model/Report.dart';
import 'model/Room.dart';
import 'model/UserModel.dart';

// Providers
import 'provider/User_Provider.dart';
import 'provider/Rooms_Provider.dart';
import 'provider/Buildings_Provider.dart';
import 'provider/Dashboard_Provider.dart';
import 'provider/Report_Provider.dart';
import 'provider/Rooms_Provider.dart';
import 'provider/Auth_Provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => RoomsProvider()),
    ChangeNotifierProvider(create: (context) => BuildingsProvider()),
    ChangeNotifierProvider(create: (context) => DashboardProvider()),
    ChangeNotifierProvider(create: (context) => ReportProvider()),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
  ], child: Hanap()));
}

class Hanap extends StatelessWidget {
  const Hanap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hanap: UPLB Class Venue Finder Mobile Application',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LogIn());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUp());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/saved':
            return MaterialPageRoute(builder: (context) => SavedScreen());
          case '/send-report':
            return MaterialPageRoute(builder: (context) => SendReport());
          case '/request-admin-access':
            return MaterialPageRoute(
                builder: (context) => RequestAdminAccess());
          case '/view-room':
            return MaterialPageRoute(
                builder: (context) => ViewRoom(
                      id: args as String,
                    ));
          case '/view-building':
            return MaterialPageRoute(
                builder: (context) => ViewBuilding(
                      id: args as String,
                    ));
          case '/view-report':
            return MaterialPageRoute(
                builder: (context) => ViewReportDetails(
                      report: args as Report,
                    ));
          case '/view-syslogs':
            return MaterialPageRoute(builder: (context) => ViewSysLogScreen());
          case '/view-rooms-admin':
            return MaterialPageRoute(
                builder: (context) => ViewRoomAdminScreen());
          case '/view-buildings-admin':
            return MaterialPageRoute(
                builder: (context) => ViewBuildingsAdminScreen());
          case '/view-building-map':
            return MaterialPageRoute(
                builder: (context) => ViewBldgMapScreen(
                      bldgDetails: args as Map<String, dynamic>,
                    ));

          case '/view-admin-reqs':
            return MaterialPageRoute(
                builder: (context) => ViewAdminRequestScreen());
          case '/view-admin-reqs-profile':
            return MaterialPageRoute(
                builder: (context) => ViewAdminRequestDetailsScreen(
                      user: args as UserModel,
                    ));
          case '/view-reports-admin':
            return MaterialPageRoute(
                builder: (context) => ViewReportsAdminScreen());
          case '/view-my-profile':
            return MaterialPageRoute(builder: (context) => ViewProfileScreen());
          case '/view-terms-and-conditions':
            return MaterialPageRoute(
                builder: (context) => TermsAndConditionsScreen());
          case '/view-about-app':
            return MaterialPageRoute(builder: (context) => AboutAppScreen());
          case '/view-my-contributions':
            return MaterialPageRoute(
                builder: (context) => ViewContributionsScreen());
          case '/edit-building':
            return MaterialPageRoute(
                builder: (context) => EditBuilding(
                      building: args as Building,
                    ));
          case '/edit-room':
            return MaterialPageRoute(
                builder: (context) => EditRoom(
                      room: args as Room,
                    ));
          case '/add-building':
            return MaterialPageRoute(builder: (context) => AddBuilding());
          case '/add-room':
            return MaterialPageRoute(builder: (context) => AddRoom());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => DashboardScreen());

          // builder: (context) => ViewBuilding(building: args as Building));
        }
      },
    );
  }
}

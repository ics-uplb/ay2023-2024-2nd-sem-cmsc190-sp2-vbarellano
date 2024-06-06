import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/Maps.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/Modal.dart';

// Model
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/UserModel.dart';
import 'package:hanap/model/Floormap.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Auth_Provider.dart';

// Constants
String FOR_APPROVAL = "for_approval";
String REJECTED = "rejected";
String APPROVED = "approved";

class ViewBuilding extends StatefulWidget {
  final String id;
  const ViewBuilding({super.key, required this.id});

  @override
  _ViewBuildingState createState() => _ViewBuildingState();
}

class _ViewBuildingState extends State<ViewBuilding> {
  late MapController mapController;
  bool isBookmarked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
      body: FutureBuilder(
        future: context.read<BuildingsProvider>().fetchBuildingByID(widget.id),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen(context);
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoContentScreen(context, "Building not found.");
          }

          var value = snapshot.data!.data() as Map<String, dynamic>;
          Building building = _buildBuildingObject(value, snapshot.data!.id);

          isBookmarked = user.saved_buildings.contains(widget.id);

          return Stack(
            children: [
              Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildHeader(context, user, building),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildBldgDetails(context, building, user),
                            if (user.is_admin &&
                                building.is_nonadmin_contribution! &&
                                building.status == FOR_APPROVAL)
                              _buildApproveButton(context, building, user),
                            if (user.is_admin)
                              _buildAdminActions(context, building),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBldgDetails(
      BuildContext context, Building building, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBuildingImage(building.image_url),
        if (user.is_admin) ...[
          _buildSectionHeader("Building ID"),
          _buildSectionContent(building.building_id!),
        ],
        _buildSectionHeader("Popular Name"),
        _buildSectionContent(building.popular_names ?? "None",
            italic: building.popular_names == null),
        _buildSectionHeader("Address"),
        _buildSectionContent(building.address),
        _buildSectionHeader("College"),
        _buildSectionContent(building.college),
        _buildSectionHeader("Building Description"),
        _buildSectionContent(building.description),
        _buildSectionHeader("Building Map"),
        _buildBuildingMap(
          building.latitude!,
          building.longitude!,
          building.name,
        ),
        _buildSectionHeader("Building Floormap"),
        _buildFloorMaps(building),
        const SizedBox(height: 20)
      ],
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Row(
              children: [
                headerNavigation("", () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: circularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentScreen(BuildContext context, String message) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Row(
              children: [
                headerNavigation("", () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: noContentFiller(message),
            ),
          ),
        ],
      ),
    );
  }

  Building _buildBuildingObject(Map<String, dynamic> value, String id) {
    List<Floormap> floormaps = [];

    for (var floormapData in value["floormaps"]) {
      Floormap newFloormap = Floormap();
      newFloormap.setLevel(floormapData["level"]);
      newFloormap.setImageURL(floormapData["image_url"]);
      newFloormap.showURL();
      floormaps.add(newFloormap);
    }

    Building building = Building(
      id,
      value['name'],
      value['popular_names'],
      value['college'],
      value['description'],
      value['address'],
      null,
      value['image_url'],
      floormaps,
      value['status'],
      value['contributed_by'],
    );
    building.setLatLong(value['latitude'], value['longitude']);
    building.is_nonadmin_contribution = value['is_nonadmin_contribution'];

    return building;
  }

  Widget _buildHeader(BuildContext context, UserModel user, Building building) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        children: [
          headerNavigation(building.name, () => Navigator.pop(context)),
          if (!user.is_admin && building.status == APPROVED)
            _buildBookmarkButton(
              context,
              user,
              building.name,
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton(
      BuildContext context, UserModel user, String name) {
    return IconButton(
      padding: EdgeInsets.zero,
      color: BLUE,
      iconSize: 40,
      onPressed: () async {
        setState(() {
          isBookmarked = !isBookmarked;
          _isLoading = true;
        });

        if (isBookmarked) {
          await context
              .read<BuildingsProvider>()
              .bookmarkBldg(user.user_id, widget.id);
          context.read<UserProvider>().bookmark(BUILDING, widget.id);
        } else {
          await context
              .read<BuildingsProvider>()
              .unBookmarkBldg(user.user_id, widget.id);
          context.read<UserProvider>().unBookmark(BUILDING, widget.id);
        }

        showScafolledMessage(
            context, "$name ${!isBookmarked ? "bookmarked" : "unbookmarked"}!");

        setState(() {
          _isLoading = false;
        });
      },
      icon:
          Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline_outlined),
    );
  }

  Widget _buildBuildingImage(String? imageUrl) {
    if (imageUrl == null) return Container();
    return Container(
      width: double.infinity,
      height: 200,
      child: Image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: title == "Building Floormap"
          ? const EdgeInsets.only(top: 5)
          : const EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: HEADER_BLUE,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, {bool italic = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          content,
          style: italic ? BODY_TEXT_ITALIC : BODY_TEXT_16,
        ),
      ),
    );
  }

  Widget _buildBuildingMap(double latitude, double longitude, String name) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: viewBuildingMaps(latitude, longitude),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: textButton("View Map in Detail", GREEN, 15, SourceSansPro, () {
            latLng.LatLng bldgLatlng = latLng.LatLng(latitude, longitude);
            Navigator.pushNamed(context, '/view-building-map', arguments: {
              'bldgLatLng': bldgLatlng, // Example coordinates
              'bldgName': name,
            });
          }),
        )
      ],
    );
  }

  Widget _buildFloorMaps(Building building) {
    if (building.floormaps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Floormaps unavailable",
            style: BODY_TEXT_ITALIC,
          ),
        ),
      );
    }

    return Column(
      children: building.floormaps.map((floormap) {
        return Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Floor Level: ${floormap.floorlevel}",
                style: BODY_TEXT_16,
              ),
            ),
            if (floormap.imageURL == null)
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Unable to load image.",
                  style: VALIDATE_TEXT,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Image(
                  image: NetworkImage(floormap.imageURL!),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildApproveButton(
      BuildContext context, Building building, UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: elevatedButton("Approve Building", GREEN, () {
        modal(context, "Approve Building",
            "Are you sure you want to approve this building?", () async {
          Navigator.pop(context);
          setState(() {
            _isLoading = true;
          });
          await context.read<BuildingsProvider>().approveBuilding(
              building.building_id!, building.name, user.user_id);
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        });
      }),
    );
  }

  Widget _buildAdminActions(BuildContext context, Building building) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: elevatedButton(
                building.status != FOR_APPROVAL ? "Remove" : "Reject",
                Colors.red, () {
              modal(
                  context,
                  building.status != FOR_APPROVAL
                      ? "Delete Building"
                      : "Reject Building",
                  "Are you sure you want to ${building.status != FOR_APPROVAL ? "delete" : "reject"} this building?",
                  () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                building.status != FOR_APPROVAL
                    ? await context.read<BuildingsProvider>().deleteBuilding(
                          building.building_id!,
                          building.contributed_by,
                          building.name,
                        )
                    : await context.read<BuildingsProvider>().rejectBuilding(
                          building.building_id!,
                          building.contributed_by,
                          building.name,
                        );
                setState(() {
                  _isLoading = false;
                });
                Navigator.pop(context);
              });
            }),
          ),
          if (building.status != REJECTED) const SizedBox(width: 10),
          if (building.status != REJECTED)
            Expanded(
              child: elevatedButton("Edit", BLUE, () {
                Navigator.pushNamed(context, '/edit-building',
                    arguments: building);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.75),
      child: Center(
        child: circularProgressIndicator(),
      ),
    );
  }
}

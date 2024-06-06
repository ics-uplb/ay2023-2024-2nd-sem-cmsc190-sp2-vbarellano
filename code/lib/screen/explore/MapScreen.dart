import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hanap/Themes.dart';

// Components
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/Maps.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Buildings_Provider.dart';

class MapsScreen extends StatefulWidget {
  final Function(int) changeScreen; // Callback to change the screen
  const MapsScreen({Key? key, required this.changeScreen}) : super(key: key);

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  double initLatitude = 14.16499631828768;
  double initLongitude = 121.24155639638963;
  final MapController _mapController = MapController();
  double _currentZoom = 16.0; // Initial zoom level
  latLng.LatLng? _currentLocation;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = latLng.LatLng(position.latitude, position.longitude);
        _mapController.move(_currentLocation!, _currentZoom);
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get current location: $e';
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom++;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom--;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _currentZoom);
    }
  }

  void _centerOnOble() {
    _mapController.move(
        latLng.LatLng(initLatitude, initLongitude), _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;
    Stream<QuerySnapshot> approvedBldgs =
        context.watch<BuildingsProvider>().approvedBldgs;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Stream build so that it will listen to the approved buildings in the database
              StreamBuilder<QuerySnapshot>(
                stream: approvedBldgs,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error encountered! ${snapshot.error}"),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: circularProgressIndicator(),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentLocation ??
                            latLng.LatLng(initLatitude, initLongitude),
                        minZoom: 10.0,
                        maxZoom: 18.0,
                        zoom: _currentZoom,
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate: urlTemplate,
                          additionalOptions: {
                            'accessToken': accessToken,
                            'id': mapboxSatelliteID,
                          },
                        ),
                        MarkerLayerOptions(markers: []),
                      ],
                    );
                  }

                  // Create a list of markers containing the details
                  List<Marker> markers = snapshot.data!.docs.map((doc) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: latLng.LatLng(doc['latitude'], doc['longitude']),
                      builder: (ctx) => Transform.rotate(
                        angle: -_mapController.rotation * pi / 180,
                        child: GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Card(
                                child: Padding(
                                  padding: padding,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // BUILDING IMAGE
                                      _buildModalImage(doc),
                                      // BUILDING NAME
                                      _buildModalName(doc),
                                      // BUILDING ADDRESS
                                      _buildModalAddress(doc),
                                      // BUILDING DESCRIPTION
                                      _buildModalDesc(doc),
                                      // BUILDING DETAILS BUTTON
                                      _buildModalBtn(doc),
                                      // Fillers
                                      const SizedBox(height: 15)
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          child: Icon(Icons.pin_drop, color: BLUE, size: 40),
                        ),
                      ),
                    );
                  }).toList();

                  // Add current location marker if available
                  if (_currentLocation != null) {
                    markers.add(
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _currentLocation!,
                        builder: (ctx) => Transform.rotate(
                          angle: -_mapController.rotation * pi / 180,
                          child: Icon(Icons.emoji_people_rounded,
                              color: Colors.red, size: 40),
                        ),
                      ),
                    );
                  }
                  markers.add(
                    Marker(
                      point: latLng.LatLng(initLatitude, initLongitude),
                      builder: (ctx) => Transform.rotate(
                        angle: -_mapController.rotation * pi / 180,
                        child: Image.asset(
                          'assets/images/oble_maroon.png',
                          width: 1000,
                        ),
                      ),
                    ),
                  );

                  return _buildMap(markers);
                },
              ),

              // Reconfigure Center
              _buildReconfCenter(),
              _buildOble(),
              // Zoom controls
              _buildZoomBtns(),

              // Search Bar
              _buildSearchBtn(user),

              // Show location error if any
              // if (_locationError.isNotEmpty) _buildErrorMapMsg()
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOble() {
    return Positioned(
      bottom: 190,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.zero,
        child: IconButton(
          icon: Image.asset(
            'assets/images/oble_maroon.png',
            width: 40,
            height: 40,
          ),
          onPressed: _centerOnOble,
        ),
      ),
    );
  }

  Widget _buildModalImage(QueryDocumentSnapshot<Object?> doc) {
    return SizedBox(
        width: double.infinity,
        height: 200,
        child: doc["image_url"] != null
            ? Image(
                image: NetworkImage(doc["image_url"]),
                fit: BoxFit.cover,
              )
            : Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                )));
  }

  Widget _buildModalName(QueryDocumentSnapshot<Object?> doc) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      alignment: Alignment.topLeft,
      child: Text(
        "${doc["name"]}",
        style: HEADER_GREEN_26,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildModalAddress(QueryDocumentSnapshot<Object?> doc) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.topLeft,
      child: Text(
        "${doc["address"]}",
        style: BODY_TEXT_16_ITALIC,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildModalDesc(QueryDocumentSnapshot<Object?> doc) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      alignment: Alignment.topLeft,
      child: Text(
        "${doc["description"]}",
        style: BODY_TEXT_17,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildModalBtn(QueryDocumentSnapshot<Object?> doc) {
    return Align(
      alignment: Alignment.topLeft,
      child: textButton("View Building Details", BLUE, 16, SourceSansPro, () {
        Navigator.popAndPushNamed(context, '/view-building', arguments: doc.id);
      }),
    );
  }

  Widget _buildMap(List<Marker> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentLocation ?? latLng.LatLng(initLatitude, initLongitude),
        minZoom: 10.0,
        maxZoom: 18.0,
        zoom: _currentZoom,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: urlTemplate,
          additionalOptions: {
            'accessToken': accessToken,
            'id': mapboxSatelliteID,
          },
        ),
        MarkerLayerOptions(markers: markers),
      ],
    );
  }

  Widget _buildZoomBtns() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.green,
              ),
              onPressed: _zoomIn,
            ),
            IconButton(
              icon: const Icon(
                Icons.remove,
                color: Colors.green,
              ),
              onPressed: _zoomOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconfCenter() {
    return Positioned(
      bottom: 130,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: EdgeInsets.zero,
        child: IconButton(
          icon: const Icon(
            Icons.my_location,
            color: Colors.redAccent,
          ),
          onPressed: _centerOnLocation,
        ),
      ),
    );
  }

  Widget _buildSearchBtn(UserModel user) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: SearchButton("Search a building or room", () {
        if (user.is_admin) {
          widget.changeScreen(2);
        } else {
          widget.changeScreen(1);
        }
      }),
    );
  }

  Widget _buildErrorMapMsg() {
    print(_locationError);
    return Positioned(
      top: 20,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.redAccent,
        child: Text(
          _locationError,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

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
import 'package:hanap/components/HeaderNavigation.dart';

import 'package:hanap/components/Maps.dart';

// Model
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Buildings_Provider.dart';

class ViewBldgMapScreen extends StatefulWidget {
  final Map<String, dynamic> bldgDetails;
  const ViewBldgMapScreen({
    Key? key,
    required this.bldgDetails,
  }) : super(key: key);

  @override
  _ViewBldgMapScreenState createState() => _ViewBldgMapScreenState();
}

class _ViewBldgMapScreenState extends State<ViewBldgMapScreen> {
  double initLatitude = 14.16499631828768;
  double initLongitude = 121.24155639638963;
  final MapController _mapController = MapController();
  double _currentZoom = 16.0; // Initial zoom level
  latLng.LatLng? _currentLocation;
  String _locationError = '';
  List<Marker> markers = [];

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

    if (widget.bldgDetails['bldgLatLng'] != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: widget.bldgDetails['bldgLatLng']!,
          builder: (ctx) => Transform.rotate(
            angle: -_mapController.rotation * pi / 180,
            child: Icon(
              Icons.pin_drop,
              color: BLUE,
              size: 40,
            ),
          ),
        ),
      );
    }

    if (_currentLocation != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentLocation!,
          builder: (ctx) => Transform.rotate(
            angle: -_mapController.rotation * pi / 180,
            child: const Icon(
              Icons.emoji_people_rounded,
              color: Color.fromARGB(255, 247, 35, 20),
              size: 40,
            ),
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

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                _buildMap(markers),
                _buildReconfCenter(),
                _buildOble(),
                _buildZoomBtns(),
                // if (_locationError.isNotEmpty) _buildErrorMapMsg(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: Row(
        children: [
          headerNavigation(widget.bldgDetails['bldgName'], () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildMap(List<Marker> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.bldgDetails['bldgLatLng'] ??
            _currentLocation ??
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

  Widget _buildErrorMapMsg() {
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

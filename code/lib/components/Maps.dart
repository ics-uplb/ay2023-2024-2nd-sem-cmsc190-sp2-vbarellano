import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hanap/Themes.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';

// Model
import 'package:hanap/model/Building.dart';

// Map Constants
const String accessToken =
    "pk.eyJ1IjoidmJhcmVsbGFubyIsImEiOiJjbHBqcDE2bTMwMXhsMmlteHdybDJrZ3VyIn0.p3lEEvZlSZZy-ndW4W5LWA";
const String urlTemplate =
    "https://api.mapbox.com/styles/v1/vbarellano/clupb4uzp005k01ps5hnkbtk4/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken";
const String mapboxSatelliteID = 'mapbox.satellite';

typedef LatLngUpdateCallback = void Function(latLng.LatLng);

// Implementation for add map markers
class AddMap extends StatefulWidget {
  final Function(latLng.LatLng)? onLatLngUpdate;

  const AddMap({Key? key, this.onLatLngUpdate}) : super(key: key);

  @override
  _AddMapState createState() => _AddMapState();
}

class _AddMapState extends State<AddMap> {
  final MapController _mapController = MapController();
  latLng.LatLng? _tappedLatLng;
  latLng.LatLng? _currentLocation;
  double _currentZoom = 18.0; // Initial zoom level
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

  void _handleTap(latLng.LatLng latLng) {
    setState(() {
      _tappedLatLng = latLng;
    });
    if (widget.onLatLngUpdate != null) {
      widget.onLatLngUpdate!(latLng);
    }
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _currentZoom);
    }
  }

  void _centerOnOble() {
    _mapController.move(
        latLng.LatLng(14.16499631828768, 121.24155639638963), _currentZoom);
  }

  Widget _buildReconfCenter() {
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

  Widget _buildOble() {
    return Positioned(
      bottom: 80,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation ?? latLng.LatLng(14.165487, 121.239025),
            zoom: _currentZoom,
            minZoom: 14.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            onTap: (_, latLng.LatLng latLng) {
              _handleTap(latLng);
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: urlTemplate,
              additionalOptions: {
                'accessToken': accessToken,
                'id': mapboxSatelliteID
              },
            ),
            MarkerLayerOptions(
              markers: [
                if (_tappedLatLng != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _tappedLatLng!,
                    builder: (context) => Icon(
                      Icons.location_pin,
                      color: BLUE,
                      size: 40.0,
                    ),
                  ),
                if (_currentLocation != null)
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
                Marker(
                  point: latLng.LatLng(14.16499631828768, 121.24155639638963),
                  builder: (ctx) => Transform.rotate(
                    angle: -_mapController.rotation * pi / 180,
                    child: Image.asset(
                      'assets/images/oble_maroon.png',
                      width: 1000,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildReconfCenter(),
        _buildOble(),
      ],
    );
  }
}

Widget viewBuildingMaps(double latitude, double longitude) {
  return FlutterMap(
      options: MapOptions(
        center: latLng.LatLng(latitude, longitude),
        minZoom: 10.0,
        zoom: 18.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.none,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: urlTemplate,
          additionalOptions: {
            'accessToken': accessToken,
            'id': mapboxSatelliteID
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(latitude, longitude),
              builder: (context) => Icon(
                Icons.pin_drop,
                color: BLUE,
                size: 40.0,
              ),
            ),
          ],
        ),
      ]);
}

// Implementation for add map markers
class EditMap extends StatefulWidget {
  final LatLngUpdateCallback? onLatLngUpdate;
  final double latitude;
  final double longitude;

  EditMap({
    Key? key,
    this.onLatLngUpdate,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _EditMapState createState() => _EditMapState();
}

class _EditMapState extends State<EditMap> {
  final MapController _mapController = MapController();
  latLng.LatLng? _tappedLatLng;
  latLng.LatLng? _currentLocation;
  double _currentZoom = 18.0; // Initial zoom level
  String _locationError = '';
  @override
  void initState() {
    super.initState();
    _tappedLatLng = latLng.LatLng(widget.latitude, widget.longitude);
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

  void _handleTap(latLng.LatLng latLng) {
    setState(() {
      _tappedLatLng = latLng;
    });
    if (widget.onLatLngUpdate != null) {
      widget.onLatLngUpdate!(latLng);
    }
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _currentZoom);
    }
  }

  void _centerOnOble() {
    _mapController.move(
        latLng.LatLng(14.16499631828768, 121.24155639638963), _currentZoom);
  }

  Widget _buildReconfCenter() {
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

  Widget _buildOble() {
    return Positioned(
      bottom: 80,
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _tappedLatLng ?? latLng.LatLng(14.165487, 121.239025),
            zoom: _currentZoom,
            minZoom: 14.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            onTap: (_, latLng.LatLng latLng) {
              _handleTap(latLng);
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: urlTemplate,
              additionalOptions: {
                'accessToken': accessToken,
                'id': mapboxSatelliteID
              },
            ),
            MarkerLayerOptions(
              markers: [
                if (_tappedLatLng != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _tappedLatLng!,
                    builder: (context) => Icon(
                      Icons.location_pin,
                      color: BLUE,
                      size: 40.0,
                    ),
                  ),
                if (_currentLocation != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _currentLocation!,
                    builder: (ctx) => Transform.rotate(
                      angle: -_mapController.rotation * pi / 180,
                      child: const Icon(Icons.emoji_people_rounded,
                          color: Color.fromARGB(255, 247, 35, 20), size: 40),
                    ),
                  ),
                Marker(
                  point: latLng.LatLng(14.16499631828768, 121.24155639638963),
                  builder: (ctx) => Transform.rotate(
                    angle: -_mapController.rotation * pi / 180,
                    child: Image.asset(
                      'assets/images/oble_maroon.png',
                      width: 1000,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildOble(),
        _buildReconfCenter(),
      ],
    );
  }
}

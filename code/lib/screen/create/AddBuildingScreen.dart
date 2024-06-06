import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latLng;

// Components
import 'package:hanap/components/ImageConstants.dart';
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/Dropdown.dart';
import 'package:hanap/components/Maps.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';
import 'package:hanap/components/Modal.dart';

// Model
import 'package:hanap/model/Floormap.dart';
import 'package:hanap/model/UserModel.dart';

// Provider
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class AddBuilding extends StatefulWidget {
  const AddBuilding({super.key});

  @override
  _AddBuildingState createState() => _AddBuildingState();
}

class _AddBuildingState extends State<AddBuilding> {
  // Handler for circular indicator
  bool _isLoading = false;

  // Choices for colleges
  String college = "---";

  // Controller Declaration
  final TextEditingController _bldgNameController = TextEditingController();
  final TextEditingController _bldgAddressController = TextEditingController();
  final TextEditingController _bldgDescController = TextEditingController();
  final TextEditingController _bldgColqNameController = TextEditingController();
  late MapController _mapController;

  // Exterior Picture
  File? exteriorPicture;
  bool isShow = false;
  List<Floormap> floormaps = [];

  // Initial Latitude and Longitude
  latLng.LatLng updatedLatLng = latLng.LatLng(14.165487, 121.239025);

  // Initial State
  @override
  void initState() {
    super.initState();
    _bldgNameController.addListener(() {});
    _bldgAddressController.addListener(() {});
    _bldgDescController.addListener(() {});
    _bldgColqNameController.addListener(() {});
    _mapController = MapController();
  }

  // Dispose
  @override
  void dispose() {
    _bldgNameController.dispose();
    _bldgAddressController.dispose();
    _bldgDescController.dispose();
    _bldgColqNameController.dispose();

    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Form key
    final _formKey = GlobalKey<FormState>();

    // Handler watching floormaps
    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
        body: Stack(children: [
      Padding(
        padding: padding,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // HEADER
          _buildHeader(context, user),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(children: [
                      // BUILDING NAME
                      _buildSectionName(),
                      // BUILDING COLLOQUIAL NAME
                      _buildSectionPopularNames(),
                      // BUILDING COLLEGE
                      _buildSectionCollege(),
                      // BUILDING DESCRIPTION
                      _buildSectionDescription(),
                      // BUILDING ADDRESS
                      _buildSectionAddress(),
                      // BUILDING PICTURE
                      _buildSectionImage(),
                      _buildSectionImageBtns(),
                      // BUILDING FLOORMAPS
                      _buildSectionFloormapImage(),
                      _buildSectionFloormapBtns(),
                      // BUILDING LOCATION
                      _buildSectionMaps(),
                      // SAVE BUILDING BUTTON
                      _buildBtn(context, user, _formKey)
                    ]))),
          )
        ]),
      ),
      if (_isLoading) _buildLayoutOverlay()
    ]));
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          headerNavigation(
              user.is_admin ? "Add a Building" : "Contribute a Building", () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        title,
        style: HEADER_BLUE,
      ),
    );
  }

  Widget _buildSectionName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Building Name"),
        textField(_bldgNameController, "Type building name here.", (value) {
          if (value!.isEmpty) {
            return "Please enter the building name";
          }
        }),
      ],
    );
  }

  Widget _buildSectionPopularNames() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Popular Name")),
        textField(
            _bldgColqNameController, "Type popular names for this building.",
            (value) {
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionCollege() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("College")),
        dropdownMap(college, COLLEGES,
            // On change function
            (String newValue) {
          setState(() {
            college = newValue;
          });
        },
            // Validator
            (value) {
          if (value == "---") {
            return "Please choose college";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionDescription() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Building Description")),
        textFieldWithLines(
            _bldgDescController, "Type building description here", 5, (value) {
          if (value!.isEmpty) {
            return "Please enter the building description";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionAddress() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Building Address")),
        textFieldWithLines(
            _bldgAddressController, "Type building address here", 2, (value) {
          if (value!.isEmpty) {
            return "Please enter the building address.";
          }
          return null; // Return null if validation passes
        }),
      ],
    );
  }

  Widget _buildSectionImage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildSectionHeader("Building Picture"),
        ),
        // Exterior Image
        exteriorPicture != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(
                        exteriorPicture!,
                        fit: BoxFit.cover,
                      ),
                    )))
            : const SizedBox(),

        if (exteriorPicture == null)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please upload building image.",
                style: VALIDATE_TEXT,
              )),
      ],
    );
  }

  Widget _buildSectionImageBtns() {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Stack(
              children: [
                // Display take picture from camera
                textButton(
                    exteriorPicture == null
                        ? "Capture image using camera"
                        : "Change image using camera",
                    GREEN,
                    15,
                    SourceSansPro, () async {
                  // Call pick image from gallery
                  final returnedImage = await pickImageFromCamera();
                  if (returnedImage != null) {
                    setState(() {
                      exteriorPicture = returnedImage;
                    });
                  }
                }),
                // Pick image from gallery
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: textButton(
                      exteriorPicture == null
                          ? "Pick image from gallery"
                          : "Change picked image from gallery",
                      GREEN,
                      15,
                      SourceSansPro, () async {
                    // Call pick image from gallery
                    final returnedImage = await pickImageFromGallery();
                    if (returnedImage != null) {
                      setState(() {
                        exteriorPicture = returnedImage;
                      });
                    }
                  }),
                ),
                // Display reset picture
                if (exteriorPicture != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: textButton(
                        "Remove Exterior Image", GREEN, 15, SourceSansPro, () {
                      // Reset image to null
                      setState(() {
                        exteriorPicture = null;
                      });
                    }),
                  )
              ],
            )),
      ],
    );
  }

  Widget _buildSectionFloormapImage() {
    return Column(
      children: [
        _buildSectionHeader("Building Floormaps"),
        for (Floormap floormap in floormaps)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (floormap.image != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(
                        floormap.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (floormap.image == null)
                  Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Please upload floormap image.",
                        style: VALIDATE_TEXT,
                      )),
                // Floor levels
                if (floormap != null)
                  floormap.getFloorlevelWidget(
                    () {
                      setState(() {
                        floormap.addFloor();
                      });
                    },
                    () {
                      setState(() {
                        floormap.decFloor();
                      });
                    },
                  ),
                // Instruction Text Image Plaeholder
                if (floormap.image == null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Select floormap picture by uploading image.",
                        style: BODY_TEXT_ITALIC,
                      ),
                    ),
                  ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: [
                        // Display button for capturing or changing image using camera
                        textButton(
                            floormap.image == null
                                ? "Capture floormap image using camera"
                                : "Change floormap image using camera",
                            GREEN,
                            15,
                            SourceSansPro, () async {
                          // Call pick image from gallery
                          final returnedImage = await pickImageFromCamera();
                          if (returnedImage != null) {
                            setState(() {
                              floormap.image = returnedImage;
                            });
                          }
                        }),
                        // Pick image from gallery button
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: textButton(
                              floormap.image == null
                                  ? "Pick floormap from gallery"
                                  : "Change picked floormap from gallery",
                              GREEN,
                              15,
                              SourceSansPro, () async {
                            // Call pick image from gallery
                            final returnedImage = await pickImageFromGallery();
                            if (returnedImage != null) {
                              setState(() {
                                floormap.image = returnedImage;
                              });
                            }
                          }),
                        ),
                        // Display reset picture
                        if (floormap.image != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: textButton("Remove Exterior Image", GREEN,
                                15, SourceSansPro, () {
                              // Reset image to null
                              setState(() {
                                floormap.image = null;
                              });
                            }),
                          )
                      ],
                    ))
              ],
            ),
            // Add or Remove Floormaps
          ),
        if (floormaps.isEmpty)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please enter floormap for this bulding.",
                style: VALIDATE_TEXT,
              )),
      ],
    );
  }

  Widget _buildSectionFloormapBtns() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Stack(children: [
            // Add a floormap button
            textButton("Add New Floormap", GREEN, 16, SourceSansPro, () {
              // Check if floormap is empty
              if (floormaps.isEmpty) {
                // context.read<BuildingsProvider>().addFloorMap();
                setState(() {
                  floormaps.add(Floormap());
                });
              } else {
                // Check if the floormap present in the list has image
                if (floormaps.last.image == null) {
                  // Cannot add floormap if no map image is present in the previous floormap
                  showScafolledMessage(context,
                      "Cannot add floormap. Upload floormap image first.");
                } else {
                  // context.read<BuildingsProvider>().addFloorMap();
                  setState(() {
                    floormaps.add(Floormap());
                  });
                }
              }
            }),
            // Remove floormap button
            Padding(
              padding: EdgeInsets.only(top: 30),
              child:
                  textButton("Remove Floormap", GREEN, 16, SourceSansPro, () {
                if (floormaps.isEmpty) {
                  // Cannot remove a floormap if no map is present
                  showScafolledMessage(
                      context, "Cannot remove floormap. No floormap present.");
                } else {
                  // context
                  //     .read<BuildingsProvider>()
                  //     .removeFloorMap();
                  setState(() {
                    floormaps.removeLast();
                  });
                }
              }),
            )
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionMaps() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Location in Map")),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Fluttermap implementation
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: double.infinity,
                height: 500,
                child: AddMap(
                  onLatLngUpdate: (latLng) {
                    // Callback function to receive updated coordinates
                    updatedLatLng = latLng;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBtn(BuildContext context, UserModel user, var _formKey) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: elevatedButton(
              user.is_admin ? "Add Building" : "Contribute Building", BLUE,
              () async {
            print(updatedLatLng.latitude);
            // Validate first the texts
            if (_formKey.currentState!.validate()) {
              // Check if building image is available
              if (exteriorPicture != null) {
                // Check if building floormap is empty
                if (floormaps.isNotEmpty) {
                  bool isValid = true;
                  bool isFloormapUnique = true;
                  List levelsChecker = [];
                  for (Floormap floormap in floormaps) {
                    // Ensure each floormaps are unique and not duplicated
                    if (!levelsChecker.contains(floormap.floorlevel)) {
                      levelsChecker.add(floormap.floorlevel);
                    } else {
                      isValid = false;
                      isFloormapUnique = false;
                      showScafolledMessage(context,
                          "Unable to proceed. Please ensure that floormaps are not duplicated.");
                      break;
                    }
                    // Ensure floormap images are not null
                    if (floormap.image == null) {
                      isValid = false;
                      break;
                    }
                  }

                  // Add only when valid
                  if (isValid) {
                    modal(
                        context,
                        user.is_admin ? "Add Building" : "Contribute Building",
                        "By proceeding, I assure that the details are correct and accurate.",
                        () async {
                      Navigator.pop(context);
                      // Initiate loading
                      setState(() {
                        _isLoading = true;
                      });

                      // Append to the building list
                      await context.read<BuildingsProvider>().addBuilding(
                            _bldgNameController.text,
                            _bldgColqNameController.text,
                            college,
                            _bldgDescController.text,
                            _bldgAddressController.text,
                            updatedLatLng.latitude,
                            updatedLatLng.longitude,
                            exteriorPicture!,
                            floormaps,
                            user.is_admin, // Determines if approved or not.
                            user.user_id,
                          );

                      setState(() {
                        _isLoading = false;
                      });

                      // Display success message before popping
                      user.is_admin
                          ? showScafolledMessage(
                              context, "${_bldgNameController.text} added!")
                          : showScafolledMessage(context,
                              "${_bldgNameController.text} contributed. Waiting for approval!");

                      Navigator.pop(context);
                    });
                  } else if (!isValid && isFloormapUnique) {
                    showScafolledMessage(context,
                        "Unable to proceed. Please provide required details.");
                  }
                } else {
                  showScafolledMessage(context,
                      "Unable to proceed. Please provide required details.");
                }
              }
            }
          }),
        ),
      ],
    );
  }

  Widget _buildLayoutOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.75),
      child: Center(
        child: circularProgressIndicator(),
      ),
    );
  }
}

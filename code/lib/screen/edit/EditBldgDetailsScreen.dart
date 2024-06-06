import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
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
import 'package:hanap/model/Building.dart';

// Provider
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class EditBuilding extends StatefulWidget {
  final Building building;
  const EditBuilding({super.key, required this.building});
  @override
  _EditBuildingState createState() => _EditBuildingState();
}

class _EditBuildingState extends State<EditBuilding> {
  // Handler for circular indicator
  bool _isLoading = false;

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
  List<int> unique_levels = [];
  bool showImageURL = true;

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

    // Initialize data based on what is the current data
    _bldgNameController.text = widget.building.name;
    _bldgColqNameController.text = widget.building.popular_names!;
    college = widget.building.college;
    _bldgDescController.text = widget.building.description;
    _bldgAddressController.text = widget.building.address;
    floormaps = widget.building.floormaps;

    // Get unique floor levels
    for (Floormap floormap in floormaps) {
      if (!unique_levels.contains(floormap.floorlevel)) {
        unique_levels.add(floormap.floorlevel);
      }
    }
  }

  // Dispose
  @override
  void dispose() {
    _bldgNameController.dispose();
    _bldgAddressController.dispose();
    _bldgDescController.dispose();
    _bldgColqNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Form key
    final _formKey = GlobalKey<FormState>();

    UserModel user = context.watch<UserProvider>().user;

    return Scaffold(
        body: Stack(children: [
      Padding(
        padding: padding,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // HEADER
          _buildHeader(context),
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
                      _buildBtns(context, user, _formKey),
                    ]))),
          )
        ]),
      ),
      if (_isLoading) _buildLayoutOverlay()
    ]));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          headerNavigation("Edit ${widget.building.name}", () {
            widget.building.image = null;
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
        widget.building.image_url != null && showImageURL
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image(
                        image: NetworkImage(widget.building.image_url!),
                        fit: BoxFit.cover,
                      ),
                    )))
            : const SizedBox(),
        widget.building.image != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(
                        widget.building.image!,
                        fit: BoxFit.cover,
                      ),
                    )))
            : const SizedBox(),
        if (widget.building.image == null && !showImageURL)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please upload an floormap image.",
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
                    widget.building.image_url == null ||
                            widget.building.image == null
                        ? "Capture image using camera"
                        : "Change image using camera",
                    GREEN,
                    15,
                    SourceSansPro, () async {
                  // User must remove the current image first before changing for a new one
                  if (showImageURL == true) {
                    showScafolledMessage(
                        context, "Remove image before taking a new one.");
                  } else {
                    // Call pick image from gallery
                    final returnedImage = await pickImageFromCamera();
                    if (returnedImage != null) {
                      setState(() {
                        showImageURL = false;
                        widget.building.image = returnedImage;
                      });
                    }
                  }
                }),
                // Pick image from gallery
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: textButton(
                      widget.building.image_url == null ||
                              widget.building.image == null
                          ? "Pick image from gallery"
                          : "Change picked image from gallery",
                      GREEN,
                      15,
                      SourceSansPro, () async {
                    // User must remove the current image first before changing for a new one
                    if (showImageURL == true) {
                      showScafolledMessage(
                          context, "Remove image before picking a new one.");
                    } else {
                      // Call pick image from gallery
                      final returnedImage = await pickImageFromGallery();
                      if (returnedImage != null) {
                        setState(() {
                          showImageURL = false;
                          widget.building.image = returnedImage;
                        });
                      }
                    }
                  }),
                ),
                // Display reset picture
                if (showImageURL || widget.building.image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: textButton(
                        "Remove Exterior Image", GREEN, 15, SourceSansPro, () {
                      // Reset image to null
                      setState(() {
                        widget.building.image = null;
                        showImageURL = false;
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
                // Show if floormap image url if it is present and showImageURL is true
                if (floormap.imageURL != null && floormap.showImageURL!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image(
                        image: NetworkImage(floormap.imageURL!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Show error handler if imageURL is null and showImageURL is true
                if (floormap.imageURL == null && floormap.showImageURL!)
                  Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Unable to load image.",
                        style: VALIDATE_TEXT,
                      )),
                // Show if image if it is present and showImageURL is false
                if (floormap.image != null && !floormap.showImageURL!)
                  Container(
                    alignment: Alignment.topLeft,
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
                // If show image is null and showImageURL is false
                if (floormap.image == null && !floormap.showImageURL!)
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
                if (floormap.image == null || !floormap.showImageURL!)
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
                            floormap.image == null || floormap.imageURL == null
                                ? "Capture floormap image using camera"
                                : "Change floormap image using camera",
                            GREEN,
                            15,
                            SourceSansPro, () async {
                          if (floormap.showImageURL == true) {
                            showScafolledMessage(context,
                                "Remove floormap image before taking a new one.");
                          } else {
                            // Call pick image from gallery
                            final returnedImage = await pickImageFromCamera();
                            if (returnedImage != null) {
                              setState(() {
                                floormap.image = returnedImage;
                              });
                            }
                          }
                        }),
                        // Pick image from gallery button
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: textButton(
                              floormap.image == null ||
                                      floormap.imageURL == null
                                  ? "Pick floormap from gallery"
                                  : "Change picked floormap from gallery",
                              GREEN,
                              15,
                              SourceSansPro, () async {
                            if (floormap.showImageURL == true) {
                              showScafolledMessage(context,
                                  "Remove floormap image before picking a new one.");
                            } else {
                              // Call pick image from gallery
                              final returnedImage =
                                  await pickImageFromGallery();
                              if (returnedImage != null) {
                                setState(() {
                                  floormap.image = returnedImage;
                                });
                              }
                            }
                          }),
                        ),
                        // Display reset picture
                        if (floormap.image != null || floormap.showImageURL!)
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: textButton("Remove Exterior Image", GREEN,
                                15, SourceSansPro, () {
                              // Reset image to null
                              setState(() {
                                floormap.image = null;
                                floormap.showImageURL = false;
                              });
                            }),
                          )
                      ],
                    ))
              ],
            ),
          ),
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
                setState(() {
                  floormaps.add(Floormap());
                });
              } else {
                // Check if the floormap present in the list has image
                if (floormaps.last.image == null &&
                    !floormaps.last.showImageURL!) {
                  // Cannot add floormap if no map image is present in the previous floormap
                  showScafolledMessage(context,
                      "Cannot add floormap. Upload floormap image first.");
                } else {
                  setState(() {
                    floormaps.add(Floormap());
                  });
                }
              }
            }),
            // Remove floormap button
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child:
                  textButton("Remove Floormap", GREEN, 16, SourceSansPro, () {
                if (floormaps.isEmpty) {
                  // Cannot remove a floormap if no map is present
                  showScafolledMessage(
                      context, "Cannot remove floormap. No floormap present.");
                } else {
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
            child: _buildSectionHeader("Location in Maps")),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Fluttermap implementation
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                width: double.infinity,
                height: 500,
                child: EditMap(
                  onLatLngUpdate: (latLng) {
                    // Callback function to receive updated coordinates
                    updatedLatLng = latLng;
                  },
                  latitude: widget.building.latitude!,
                  longitude: widget.building.longitude!,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBtns(BuildContext context, UserModel user, var _formKey) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: elevatedButton("Edit Building", BLUE, () async {
            // Validate first the texts
            if (_formKey.currentState!.validate()) {
              // Check if building image is available
              if (widget.building.image == null && !showImageURL) {
                showScafolledMessage(context,
                    "Unable to proceed. Please provide required details.");
              } else {
                // Check if each floormap  is valid
                bool isValid = true;
                bool isFloormapUnique = true;
                List levelsChecker = [];
                for (Floormap floormap in floormaps) {
                  // Ensure that floor levels are unique
                  if (!levelsChecker.contains(floormap.floorlevel)) {
                    levelsChecker.add(floormap.floorlevel);
                  } else {
                    isValid = false;
                    isFloormapUnique = false;
                    showScafolledMessage(context,
                        "Unable to proceed. Please ensure that floormaps are not duplicated.");
                    break;
                  }
                  // IF showImageURL is false and image is null, set validity to false
                  if (!floormap.showImageURL! && floormap.image == null) {
                    isValid = false;
                    break;
                  }
                }

                if (isValid) {
                  modal(context, "Edit Building",
                      "By proceeding, I assure that the changes are correct and accurate.",
                      () async {
                    Navigator.pop(context);
                    // Initiate loading
                    setState(() {
                      _isLoading = true;
                    });
                    // Append to the building list
                    await context.read<BuildingsProvider>().updateBuilding(
                          widget.building.building_id!,
                          _bldgNameController.text,
                          _bldgColqNameController.text,
                          college,
                          _bldgDescController.text,
                          _bldgAddressController.text,
                          updatedLatLng.latitude,
                          updatedLatLng.longitude,
                          // if showImageURL, no changes
                          showImageURL ? null : widget.building.image,
                          showImageURL ? widget.building.image_url : null,
                          unique_levels,
                          floormaps,
                          user.is_admin,
                          user.user_id,
                        );

                    // Display success message before popping
                    showScafolledMessage(
                        context, "${_bldgNameController.text} updated!");

                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                } else if (!isValid && isFloormapUnique) {
                  showScafolledMessage(context,
                      "Unable to proceed. Please provide required details.");
                }
              }
            } else {
              showScafolledMessage(context,
                  "Unable to proceed. Please provide required details.");
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

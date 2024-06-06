import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hanap/model/Room.dart';
import 'package:provider/provider.dart';
import 'package:hanap/Themes.dart';

// Components
import 'package:hanap/components/ImageConstants.dart';
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/Dropdown.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';
import 'package:hanap/components/Modal.dart';

// Model
import 'package:hanap/model/Path.dart';
import 'package:hanap/model/UserModel.dart';
import 'package:hanap/model/Building.dart';

// Provider
import 'package:hanap/provider/Rooms_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class AddRoom extends StatefulWidget {
  // final Building building;
  // const AddRoom({super.key, required this.building});
  const AddRoom({super.key});

  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  String? college;
  String? building;
  String? floorLevel;
  bool _isLoading = false;

  // Directions and Paths
  final List<Path> directions = [];

  // Controller Declaration
  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomAddressController = TextEditingController();
  final TextEditingController _roomDescController = TextEditingController();
  final TextEditingController _roomStepController = TextEditingController();

  // Image
  File? _selectedImage;

  // Initial State
  @override
  void initState() {
    super.initState();
    college = "---";
    building = "---";
    floorLevel = "---";

    _roomStepController.addListener(() {});
    _roomCodeController.addListener(() {});
    _roomNameController.addListener(() {});
    _roomAddressController.addListener(() {});
    _roomDescController.addListener(() {});
  }

  // Dispose
  @override
  void dispose() {
    _roomCodeController.dispose();
    _roomNameController.dispose();
    _roomAddressController.dispose();
    _roomDescController.dispose();
    _roomStepController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // User
    UserModel user = context.watch<UserProvider>().user;
    // Dropdown options
    Map<String, String> BUILDINGS =
        context.watch<RoomsProvider>().BUILDINGS_CHOICES;
    Map<String, String> FLOORLEVELS =
        context.watch<RoomsProvider>().FLOORMAP_CHOICES;

    final _formKey = GlobalKey<FormState>();

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
                      // ROOM NAME
                      _buildSectionName(),
                      // ROOM CODE
                      _buildSectionCode(),
                      // ROOM ADDRESS
                      _buildSectionAddress(),
                      // ROOM DESCRIPTION
                      _buildSectionDescription(),
                      // ROOM COLLEGE
                      _buildSectionCollege(),
                      // ROOM Building
                      _buildSectionBuilding(BUILDINGS),
                      // FLOOR LEVEL
                      _buildSectionFloorlevel(BUILDINGS, FLOORLEVELS),
                      // ROOM PICTURE
                      _buildSectionImage(),
                      _buildSectionImageBtns(),
                      // ROOM DIRECTIONS
                      _buildSectionDirections(),
                      _buildSectionDirectionsBtns(),
                      // SAVE BUILDING BUTTON
                      _buildBtns(
                        context,
                        user,
                        _formKey,
                        BUILDINGS,
                        FLOORLEVELS,
                      )
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
          headerNavigation(user.is_admin ? "Add a Room" : "Contribute a Room",
              () {
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
      children: [
        _buildSectionHeader("Room Name"),
        textField(_roomNameController, "Type room name here.", (value) {
          if (value!.isEmpty) {
            return "Please enter the room name.";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionCode() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Room Code")),
        textField(_roomCodeController, "Type room code here.", (value) {
          if (value!.isEmpty) {
            return "Please enter the room code.";
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
            child: _buildSectionHeader("Room Address")),
        textField(_roomAddressController, "Type room address here.", (value) {
          if (value!.isEmpty) {
            return "Please enter the room address.";
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
            child: _buildSectionHeader("Room Description")),
        textFieldWithLines(_roomDescController, "Type room description here", 5,
            (value) {
          if (value!.isEmpty) {
            return "Please enter the room description.";
          }
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
            child: _buildSectionHeader("Room College")),
        dropdownMap(college!, COLLEGES,
            // On change function
            (String value) {
          setState(() {
            print(value);
            college = value;
            floorLevel = "---";
            building = "---";
          });
          context.read<RoomsProvider>().fetchBuildingsPerCollege(value);
        },
            // Validator
            (value) {
          if (value == "---") {
            return "Please choose college.";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionBuilding(Map<String, String> BUILDINGS) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Room Building")),
        dropdownMap(building!, BUILDINGS,
            // On Change function
            (String newValue) {
          // Returns the building id
          context.read<RoomsProvider>().fetchFloorlevelPerBldg(newValue);
          setState(() {
            floorLevel = "---";
            building = newValue;
          });
        },
            // Validator
            (value) {
          if (college == "---") {
            return "Please choose college first.";
          } else if ((college != "---" &&
              BUILDINGS.length > 1 &&
              value == "---")) {
            return "Please choose building.";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionFloorlevel(
    Map<String, String> BUILDINGS,
    Map<String, String> FLOORLEVELS,
  ) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Room Floorlevel")),
        dropdownMap(floorLevel!, FLOORLEVELS, (String newValue) {
          setState(() {
            floorLevel = newValue;
          });
        },
            // Validator
            (value) {
          if (college == "---") {
            return "Please choose college first.";
          } else if (college != "---" &&
              BUILDINGS.length > 1 &&
              building == "---") {
            return "Please choose building first.";
          } else if (building != "---" &&
              FLOORLEVELS.length > 1 &&
              floorLevel == "---") {
            return "Please choose floorlevel.";
          }
          return null;
        }),
      ],
    );
  }

  Widget _buildSectionImage() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Room Image")),
        _selectedImage != null
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )))
            : const SizedBox(),
        if (_selectedImage == null)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please upload room image.",
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
                    _selectedImage == null
                        ? "Capture image using camera"
                        : "Change image using camera",
                    GREEN,
                    15,
                    SourceSansPro, () async {
                  // Call pick image from gallery
                  final returnedImage = await pickImageFromCamera();
                  if (returnedImage != null) {
                    setState(() {
                      _selectedImage = returnedImage;
                    });
                  }
                }),
                // Pick image from gallery
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: textButton(
                      _selectedImage == null
                          ? "Pick image from gallery"
                          : "Change picked image from gallery",
                      GREEN,
                      15,
                      SourceSansPro, () async {
                    // Call pick image from gallery
                    final returnedImage = await pickImageFromGallery();
                    if (returnedImage != null) {
                      setState(() {
                        _selectedImage = returnedImage;
                      });
                    }
                  }),
                ),
                // Display reset picture
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: textButton(
                        "Remove Room Image", GREEN, 15, SourceSansPro, () {
                      // Reset image to null
                      setState(() {
                        _selectedImage = null;
                      });
                    }),
                  )
              ],
            )),
        // DIRECTIONS
      ],
    );
  }

  Widget _buildSectionDirections() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSectionHeader("Directions")),
        // Display details for directions dynamically
        Column(
          children: [
            for (var path in directions)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  path.widget!,
                  if (!path.hasInstruction())
                    Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Please ensure this path has navigation instruction/s.",
                          style: VALIDATE_TEXT,
                        )),

                  for (var instruction in path.path)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instruction Number
                        instruction.label!,
                        // Instruction Image
                        instruction.image != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: Image.file(
                                    instruction.image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        // Instruction Textfield
                        textFieldWithLines(
                            instruction.controller, "Type room instructions", 3,
                            // Validator
                            (value) {
                          if (value!.isEmpty) {
                            return "Please enter instruction text.";
                          }
                          return null;
                        }),
                        // Instruction Text Buttons
                        Align(
                            alignment: Alignment.topLeft,
                            child: Stack(
                              children: [
                                // Display take picture from camera
                                textButton(
                                    instruction.image == null
                                        ? "Capture image using camera"
                                        : "Change image using camera",
                                    GREEN,
                                    15,
                                    SourceSansPro, () async {
                                  // Call pick image from gallery
                                  final returnedImage =
                                      await pickImageFromCamera();
                                  if (returnedImage != null) {
                                    setState(() {
                                      instruction.image = returnedImage;
                                    });
                                  }
                                }),
                                // Pick image from gallery
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: textButton(
                                      instruction.image == null
                                          ? "Pick image from gallery"
                                          : "Change picked image from gallery",
                                      GREEN,
                                      15,
                                      SourceSansPro, () async {
                                    // Call pick image from gallery
                                    final returnedImage =
                                        await pickImageFromGallery();
                                    if (returnedImage != null) {
                                      setState(() {
                                        instruction.image = returnedImage;
                                      });
                                    }
                                  }),
                                ),
                                // Display reset picture
                                if (instruction.image != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60),
                                    child: textButton("Remove Room Image",
                                        GREEN, 15, SourceSansPro, () {
                                      // Reset image to null
                                      setState(() {
                                        instruction.image = null;
                                      });
                                    }),
                                  )
                              ],
                            )),
                        // DIRECTIONS
                      ],
                    ),
                  // DIVIDER
                  Divider(
                    color: BLUE,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                ],
              ),
          ],
        ),
        if (directions.isEmpty)
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Please enter navigation path and instruction for this room.",
                style: VALIDATE_TEXT,
              )),
      ],
    );
  }

  Widget _buildSectionDirectionsBtns() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              // Add Step Button
              textButton("Add New instruction", GREEN, 16, SourceSansPro, () {
                // Add new instruction if path is present
                if (directions.isNotEmpty) {
                  setState(() {
                    directions.last.addInstruction();
                  });
                } else {
                  // Give a prompt if no path is present
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Cannot add new instruction. Add a path first.",
                      style: SOURCE_SANS_PRO,
                    ),
                    duration: const Duration(seconds: 1, milliseconds: 100),
                    backgroundColor: BLUE,
                  ));
                }
              }),
              // Remove Step Button
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: textButton(
                    "Remove Instruction", GREEN, 16, SourceSansPro, () {
                  // Check if path is present
                  if (directions.isNotEmpty) {
                    // Check if an existing instruction is present
                    if (directions.last.hasInstruction()) {
                      setState(() {
                        directions.last.removeInstruction();
                      });
                    } else {
                      // Give prompt to add instruction first.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Cannot remove instruction. No instruction to remove.",
                          style: SOURCE_SANS_PRO,
                        ),
                        duration: const Duration(seconds: 1, milliseconds: 100),
                        backgroundColor: BLUE,
                      ));
                    }
                  } else {
                    // Give a prompt if no path is present
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "Cannot remove instruction. Add a path first.",
                        style: SOURCE_SANS_PRO,
                      ),
                      duration: const Duration(seconds: 1, milliseconds: 100),
                      backgroundColor: BLUE,
                    ));
                  }
                }),
              ),
              // Add New Path Button
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: textButton("Add New Path", GREEN, 16, SourceSansPro, () {
                  // Check if the current path is not empty
                  if (directions.isNotEmpty) {
                    if (directions.last.hasInstruction()) {
                      // Call provider for adding a new
                      Path newPath = Path(directions.length + 1);
                      setState(() {
                        directions.add(newPath);
                      });
                    } else {
                      // Give a prompt. Adding new path should be possible if previous path entry is not empty.
                      showScafolledMessage(context,
                          "Cannot add a path. Previous path is empty.");
                    }
                  } else {
                    // Add new path to an empty direction list
                    Path newPath = Path(directions.length + 1);
                    setState(() {
                      directions.add(newPath);
                    });
                  }
                }),
              ),
              // Remove Path Button
              Padding(
                padding: const EdgeInsets.only(top: 110.0),
                child: textButton("Remove Path", GREEN, 16, SourceSansPro, () {
                  // Check existence of a path
                  if (directions.isNotEmpty) {
                    // Call provider for removing a path
                    setState(() {
                      if (directions.last.hasInstruction()) {
                        directions.last.disposeInstructions();
                      }
                      // Remove from the list of path
                      directions.removeLast();
                    });
                  } else {
                    // Give a prompt if no path is present
                    showScafolledMessage(
                        context, "Cannot remove path. No path present.");
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBtns(
    BuildContext context,
    UserModel user,
    var _formKey,
    Map<String, String> BUILDINGS,
    Map<String, String> FLOORLEVELS,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: elevatedButton(
          user.is_admin ? "Add Room" : "Contribute Room", BLUE, () {
        // Check form validation for textfields
        if (_formKey.currentState!.validate()) {
          // Ensures that it cannot proceed if building is not present
          if (BUILDINGS.length > 1) {
            // Ensures that it cannot proceed if floorlevel is not present
            if (FLOORLEVELS.length > 1) {
              // Ensure that the room image is available
              if (_selectedImage != null) {
                // Check if all paths and instructions is not null
                if (directions.isNotEmpty) {
                  bool isValid = true;
                  // Check if all path has instructions
                  for (Path path in directions) {
                    if (!path.hasInstruction()) {
                      isValid = false;
                      break;
                    }
                  }

                  if (isValid) {
                    modal(
                        context,
                        user.is_admin ? "Add Room" : "Contribute Room",
                        "By proceeding, I assure that the details are correct and accurate.",
                        () async {
                      // Pop the modal
                      Navigator.pop(context);

                      // Load the progress indicator
                      setState(() {
                        _isLoading = true;
                      });

                      // Call add room from provider
                      await context.read<RoomsProvider>().addRoom(
                          _roomNameController.text,
                          _roomCodeController.text,
                          _roomAddressController.text,
                          _roomDescController.text,
                          college!,
                          building!,
                          floorLevel!,
                          _selectedImage,
                          directions,
                          user.is_admin,
                          user.user_id);

                      // Display success message before popping
                      user.is_admin
                          ? showScafolledMessage(
                              context, "${_roomNameController.text} added!")
                          : showScafolledMessage(context,
                              "${_roomNameController.text} contributed. Waiting for approval!");

                      // Stop the progress indicator
                      setState(() {
                        _isLoading = false;
                      });

                      // Pop the screen
                      Navigator.pop(context);
                    });
                  } else {
                    showScafolledMessage(context,
                        "Unable to proceed. Please provide required details.");
                  }
                } else {
                  showScafolledMessage(context,
                      "Unable to proceed. Please provide required details.");
                }
              } else {
                showScafolledMessage(context,
                    "Unable to proceed. Please provide required details.");
              }
            } else {
              showScafolledMessage(
                  context, "Unable to proceed. Building has no floorlevels.");
            }
          } else {
            showScafolledMessage(
                context, "Unable to proceed. College has no building.");
          }
        } else {
          showScafolledMessage(
              context, "Unable to add. Please provide required details.");
        }
      }),
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

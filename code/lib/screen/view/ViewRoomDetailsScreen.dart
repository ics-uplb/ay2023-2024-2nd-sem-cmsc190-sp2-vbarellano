import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Components
import 'package:hanap/components/NavBar.dart';
import 'package:hanap/components/Modal.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';
import 'package:hanap/components/ScaffoldMessenger.dart';
import 'package:hanap/components/HeaderNavigation.dart';
import 'package:hanap/components/NoContentFiller.dart';

// Model
import 'package:hanap/model/Room.dart';
import 'package:hanap/model/UserModel.dart';
import 'package:hanap/model/Path.dart';
import 'package:hanap/model/Instruction.dart';

// Providers
import 'package:hanap/provider/User_Provider.dart';
import 'package:hanap/provider/Auth_Provider.dart';
import 'package:hanap/provider/Rooms_Provider.dart';

class ViewRoom extends StatefulWidget {
  final String id;

  const ViewRoom({super.key, required this.id});

  @override
  _ViewRoom createState() => _ViewRoom();
}

class _ViewRoom extends State<ViewRoom> {
  bool isBookmarked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;
    return Scaffold(
        body: FutureBuilder(
            future: context.read<RoomsProvider>().fetchRoomByID(widget.id),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(context);
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildNoContentScreen(context, "Room not found.");
              }

              var value = snapshot.data!.data() as Map<String, dynamic>;
              Room room = _buildRoomFromData(snapshot.data!.id, value);

              isBookmarked = user.saved_rooms.contains(widget.id);

              return Stack(children: [
                Padding(
                  padding: padding,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildHeader(context, user, room),
                        Expanded(
                          child: SingleChildScrollView(
                              child: Column(children: [
                            _buildRoomDetails(context, room, user),
                            if (!user.is_admin)
                              const SizedBox(
                                height: 20,
                              ),
                            if (user.is_admin)
                              _buildAdminControls(context, room, user),
                          ])),
                        ),
                      ]),
                ),
                if (_isLoading) _buildLoadingOverlay()
              ]);
            }));
  }

  Room _buildRoomFromData(String id, Map<String, dynamic> value) {
    List<Path> directions = [];
    for (var path in value["directions"]) {
      Path newPath = Path(path["path_number"]);
      List<Instruction> instructions = [];
      for (var instruction in path["instructions"]) {
        Instruction newInstruction =
            Instruction(instruction["instruction_number"]);
        newInstruction.controller.text = instruction["instruction"];
        newInstruction.hasImage = instruction["has_image"];
        if (instruction["has_image"]) {
          newInstruction.image_url = instruction["image_url"];
        }
        instructions.add(newInstruction);
      }
      newPath.setPath(instructions);
      directions.add(newPath);
    }
    Room newRoom = Room(
        id,
        value['name'],
        value['code'],
        value['address'],
        value['description'],
        value['college'],
        value['building_id'],
        value['building_name'],
        value['floorlevel'],
        null,
        value['image_url'],
        directions,
        value['contributed_by'],
        value['status']);
    newRoom.is_nonadmin_contribution = value['is_nonadmin_contribution'];

    return newRoom;
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

  Widget _buildHeader(BuildContext context, UserModel user, Room room) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        children: [
          headerNavigation(room.name, () => Navigator.pop(context)),
          if (!user.is_admin && room.status == APPROVED)
            IconButton(
                padding: EdgeInsets.zero,
                color: BLUE,
                iconSize: 40,
                onPressed: () async {
                  setState(() {
                    isBookmarked = !isBookmarked; // Toggle isBookmarked
                    _isLoading = true;
                  });
                  if (isBookmarked) {
                    await context
                        .read<RoomsProvider>()
                        .bookmarkRoom(user.user_id, widget.id);
                    context.read<UserProvider>().bookmark(ROOM, widget.id);
                  } else {
                    await context
                        .read<RoomsProvider>()
                        .unBookmarkRoom(user.user_id, widget.id);
                    context.read<UserProvider>().unBookmark(ROOM, widget.id);
                  }

                  showScafolledMessage(context,
                      "${room.name} ${!isBookmarked ? "bookmarked" : "unbookmarked"}!");

                  setState(() {
                    _isLoading = false;
                  });
                },
                icon: Icon(isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_outline_outlined)),
        ],
      ),
    );
  }

  Widget _buildRoomDetails(BuildContext context, Room room, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoomImage(room),
        if (user.is_admin) _buildRoomID(room),
        _buildRoomAddress(room),
        _buildRoomCode(room),
        _buildRoomCollegeAndBuilding(context, room),
        _buildRoomFloorLevel(room),
        _buildRoomDescription(room),
        _buildDirections(room),
      ],
    );
  }

  Widget _buildRoomImage(Room room) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Image(
        image: NetworkImage(room.image_url!),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRoomID(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Room ID",
              style: HEADER_BLUE,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              room.room_id!,
              style: BODY_TEXT_16,
            )),
      ],
    );
  }

  Widget _buildRoomAddress(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Address",
              style: HEADER_BLUE,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              room.address,
              style: BODY_TEXT_16,
            )),
      ],
    );
  }

  Widget _buildRoomCode(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Room Code",
              style: HEADER_BLUE,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              room.code,
              style: BODY_TEXT_16,
            )),
      ],
    );
  }

  Widget _buildRoomCollegeAndBuilding(BuildContext context, Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Room College and Building",
              style: HEADER_BLUE,
            )),
        Stack(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "${room.college} - ${room.building_name}",
                  style: BODY_TEXT_16,
                )),
            Container(
              padding: const EdgeInsets.only(top: 25),
              alignment: Alignment.topLeft,
              child: textButton(
                  "View Building Details", GREEN, 16, SourceSansPro, () {
                Navigator.pushNamed(context, "/view-building",
                    arguments: room.building_id);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomFloorLevel(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Floorlevel",
              style: HEADER_BLUE,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              room.floor_level.toString(),
              style: BODY_TEXT_16,
            )),
      ],
    );
  }

  Widget _buildRoomDescription(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Room Description",
              style: HEADER_BLUE,
            )),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              room.description,
              style: BODY_TEXT_16,
            )),
      ],
    );
  }

  Widget _buildDirections(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Directions (How to get there?)",
              style: HEADER_BLUE,
            )),
        for (Path path in room.directions)
          Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 5), child: path.widget),
              for (Instruction instruction in path.path)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: instruction.label!,
                    ),
                    if (instruction.hasImage && instruction.image_url != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 20,
                          bottom: 10,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Image(
                            image: NetworkImage(instruction.image_url!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        instruction.controller.text,
                        style: BODY_TEXT_16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildAdminControls(BuildContext context, Room room, UserModel user) {
    print(room.is_nonadmin_contribution!);
    print(room.status);
    return Column(
      children: [
        if (room.is_nonadmin_contribution! && room.status == FOR_APPROVAL)
          Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 20),
              child: elevatedButton("Approve Building", GREEN, () {
                modal(context, "Approve Building",
                    "Are you sure you want to approve this building?",
                    () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  await context
                      .read<RoomsProvider>()
                      .approveRoom(room.room_id!, user.user_id);
                  setState(() {
                    _isLoading = false;
                  });
                  Navigator.pop(context);
                });
              })),
        Padding(
            padding: room.status != FOR_APPROVAL
                ? const EdgeInsets.only(bottom: 20, top: 20)
                : const EdgeInsets.only(bottom: 20),
            child: Row(children: [
              Expanded(
                child: elevatedButton(
                    room.status != FOR_APPROVAL ? "Remove" : "Reject",
                    Colors.red, () {
                  modal(
                      context,
                      room.status != FOR_APPROVAL
                          ? "Delete Building"
                          : "Reject Building",
                      "Are you sure you want to ${room.status != FOR_APPROVAL ? "delete" : "reject"} this building?",
                      () async {
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    room.status != FOR_APPROVAL
                        ? await context.read<RoomsProvider>().deleteRoom(
                              room.room_id!,
                              user.user_id,
                            )
                        : await context.read<RoomsProvider>().rejectRoom(
                              room.room_id!,
                              user.user_id,
                            );
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context);
                  });
                }),
              ),
              if (room.status != REJECTED)
                const SizedBox(
                  width: 10,
                ),
              if (room.status != REJECTED)
                Expanded(
                    child: elevatedButton("Edit", BLUE, () {
                  List<Path> directions = [];
                  for (Path path in room.directions) {
                    Path newPath = Path(path.pathNumber);
                    List<Instruction> instructions = [];
                    for (Instruction instruction in path.path) {
                      Instruction newInstruct =
                          Instruction(instruction.instructionNumber);
                      newInstruct.controller.text = instruction.controller.text;
                      newInstruct.hasImage = instruction.hasImage;
                      if (instruction.hasImage) {
                        newInstruct.image_url = instruction.image_url;
                      }
                      instructions.add(newInstruct);
                    }
                    newPath.setPath(instructions);
                    directions.add(newPath);
                  }

                  Room newRoom = Room(
                      room.room_id,
                      room.name,
                      room.code,
                      room.address,
                      room.description,
                      room.college,
                      room.building_id,
                      room.building_name,
                      room.floor_level,
                      room.image,
                      room.image_url,
                      directions,
                      room.contributed_by,
                      room.status);
                  room.is_nonadmin_contribution = room.is_nonadmin_contribution;

                  Navigator.pushNamed(context, "/edit-room", arguments: room);
                })),
            ])),
      ],
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

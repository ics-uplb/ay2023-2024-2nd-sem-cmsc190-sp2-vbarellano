import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/components/Dropdown.dart';
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Components
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/NoContentFiller.dart';
import 'package:hanap/components/Cards.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Model
import 'package:hanap/model/Room.dart';
import 'package:hanap/model/Building.dart';
import 'package:hanap/model/UserModel.dart';

// Providers
import 'package:hanap/provider/Rooms_Provider.dart';
import 'package:hanap/provider/Buildings_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class ExploreScreen extends StatefulWidget {
  // final Building building;
  // const ViewBuilding({super.key, required this.building});
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Bookmark value handling
  final TextEditingController _searchController = TextEditingController();

  // Handler if building or not
  bool isBuilding = true;
  String keyword = '';
  List<String> collegeFilter = [];
  bool isCollegeFiltered = false;

  // Provider instantiation
  BuildingsProvider bldgProvider = BuildingsProvider();
  RoomsProvider roomsProvider = RoomsProvider();

  // Initial State
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {});
    bldgProvider.searchBuilding(keyword, collegeFilter);
    roomsProvider.searchRooms(keyword, collegeFilter);
  }

  // Dispose
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = context.watch<UserProvider>().user;

    return Column(children: [
      // Search Bar
      Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: searchBar(
            _searchController,
            "Search a building or room",
            // Validator
            (value) {
              if (isBuilding) {
                context
                    .read<BuildingsProvider>()
                    .searchBuilding(_searchController.text, collegeFilter);
              } else {
                context
                    .read<RoomsProvider>()
                    .searchRooms(_searchController.text, collegeFilter);
              }
            },
            // Icon Button Action
            () {
              if (isBuilding) {
                context
                    .read<BuildingsProvider>()
                    .searchBuilding(_searchController.text, collegeFilter);
              } else {
                context
                    .read<RoomsProvider>()
                    .searchRooms(_searchController.text, collegeFilter);
              }
            },
          )),

      // Rooms and Buildings NavBar
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          textButtonWithIcon(
              "Filters ",
              Icon(
                Icons.filter_list_alt,
                color: isCollegeFiltered ? GREEN : BLUE,
                size: 20,
              ),
              isCollegeFiltered ? GREEN : BLUE,
              20,
              SourceSansPro,
              true,
              true, () {
            if (!isCollegeFiltered) {
              setState(() {
                collegeFilter = [];
              });
            }
            _buildSectionFilter();
          }),
          textButton("Buildings ", isBuilding ? GREEN : BLUE, 20, SourceSansPro,
              () {
            setState(() {
              isBuilding = true;
              collegeFilter = [];
              isCollegeFiltered = false;
            });
            context
                .read<BuildingsProvider>()
                .searchBuilding(_searchController.text, collegeFilter);
          }),
          textButton("Rooms", isBuilding ? BLUE : GREEN, 20, SourceSansPro, () {
            setState(() {
              isBuilding = false;
              collegeFilter = [];
              isCollegeFiltered = false;
            });
            context
                .read<RoomsProvider>()
                .searchRooms(_searchController.text, collegeFilter);
          })
        ],
      ),
      Expanded(
          child: StreamBuilder(
              stream: isBuilding
                  ? context.watch<BuildingsProvider>().searchedBldgs
                  : context.watch<RoomsProvider>().searchedRooms,
              builder:
                  (context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
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
                  return noContentFiller("Search not found.");
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: ((context, index) {
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return room_or_bldg_cards(
                        snapshot.data!.docs[index].id,
                        data['image_url'],
                        data['name'],
                        data['address'],
                        isBuilding,
                        user,
                        context);
                  }),
                );
              }))
    ]);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: HEADER_BLUE,
        ),
      ),
    );
  }

  void _buildSectionFilter() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Card(
                child: Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("College Filters"),
                      Flexible(
                        child: Wrap(
                          children: [
                            for (String key in Map.fromEntries(
                              COLLEGES.entries
                                  .toList()
                                  .getRange(1, COLLEGES.length),
                            ).keys)
                              textButton(
                                COLLEGES[key]!, // Display name
                                collegeFilter.contains(key) ? GREEN : BLUE,
                                16,
                                SourceSansPro,
                                () {
                                  setModalState(() {
                                    if (collegeFilter.contains(key)) {
                                      collegeFilter.remove(key);
                                    } else {
                                      collegeFilter.add(key);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      textButton(
                        "Reset Colleges", // Display name
                        BLUE,
                        17,
                        SourceSansPro,
                        () {
                          setState(() {
                            isCollegeFiltered = false;
                          });
                          setModalState(() {
                            collegeFilter = [];
                          });
                          if (isBuilding) {
                            context.read<BuildingsProvider>().searchBuilding(
                                _searchController.text, collegeFilter);
                          } else {
                            context.read<RoomsProvider>().searchRooms(
                                _searchController.text, collegeFilter);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      elevatedButton("Filter Searches", GREEN, () {
                        if (collegeFilter.isNotEmpty) {
                          setState(() {
                            isCollegeFiltered = true;
                          });
                          if (isBuilding) {
                            context.read<BuildingsProvider>().searchBuilding(
                                _searchController.text, collegeFilter);
                          } else {
                            context.read<RoomsProvider>().searchRooms(
                                _searchController.text, collegeFilter);
                          }
                        }

                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 15)
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mango_app/about_page.dart';
import 'package:mango_app/add_type.dart';
import 'package:mango_app/mandi_settings.dart';
import 'package:mango_app/shimmer/mandi_shimmer.dart';
import 'package:mango_app/services/mango_service.dart';

import 'package:mango_app/edit_mango_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mango_app/utilities/settings_menu.dart';

class Mandi extends StatefulWidget {
  const Mandi({super.key});

  @override
  State<Mandi> createState() => MandiState();
}

class MandiState extends State<Mandi> {
  Map<String, dynamic>? user;
  List<dynamic> mangoes = [];
  List<dynamic> filteredMangoes = [];
  final MangoService _mangoService = MangoService();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");
    if (userJson != null) {
      final parsedUser = jsonDecode(userJson);
      setState(() {
        user = parsedUser;
      });
      _loadMangoTypes();
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadMangoTypes() async {
    final types = await _mangoService.fetchMangoTypes();
    setState(() {
      mangoes = types;
      filteredMangoes = types;
    });
  }

  void _filterMangoes(String query) {
    setState(() {
      filteredMangoes =
          mangoes.where((mango) {
            final typeName = (mango['typeName'] ?? '').toString().toLowerCase();
            return typeName.contains(query.toLowerCase());
          }).toList();
    });
  }

  final GlobalKey _settingsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MandiShimmer();
    }

    final mandiName = user?['mandiname'] ?? "Mandi Name";
    final ownerName = user?['username'] ?? "Owner Name";

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddType()),
            );
            _loadMangoTypes();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
        backgroundColor: Colors.green.shade100,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        mandiName,
                        // textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.green,
                        ),
                      ),

                      IconButton(
                        key: _settingsKey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.green[700],
                          size: 26,
                        ),
                        onPressed: () {
                          SettingsMenu.show(context, _settingsKey);
                        },
                      ),
                    ],
                  ),
                  // const SizedBox(height: 4),
                  Text(
                    "@$ownerName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 10),

            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: _filterMangoes,
                decoration: InputDecoration(
                  hintText: 'Search mango type...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🥭 Mango Grid
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Buying Types",
                      style: TextStyle(color: Colors.green, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    //🟣 Search Bar
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   child: TextField(
                    //     controller: searchController,
                    //     decoration: InputDecoration(
                    //       hintText: "Search by mango type...",
                    //       hintStyle: TextStyle(color: Colors.green),
                    //       prefixIcon: const Icon(
                    //         Icons.search,
                    //         color: Colors.green,
                    //       ),
                    //       filled: true,
                    //       fillColor: Colors.green.shade50,
                    //       contentPadding: const EdgeInsets.symmetric(
                    //         vertical: 0,
                    //         horizontal: 16,
                    //       ),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //         borderSide: BorderSide.none,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            filteredMangoes.isEmpty
                                ? Center(
                                  child: Text(
                                    searchController.text.isEmpty
                                        ? "No mango types added yet"
                                        : "No type found with name '${searchController.text}'",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                                : GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 3 / 4,
                                  children:
                                      filteredMangoes.map<Widget>((mango) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => EditMangoPage(
                                                      mango: mango,
                                                    ),
                                              ),
                                            );
                                            _loadMangoTypes(); // refresh after editing
                                          },
                                          child: Card(
                                            elevation: 2,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                    child: Image.network(
                                                      mango['image'] ?? "",
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        mango['typeName'] ??
                                                            "Unknown Type",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade700,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Rs ${mango['price'] ?? 0}",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                      Text(
                                                        "Capacity: ${mango['buying_capacity'] ?? 0} tons",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

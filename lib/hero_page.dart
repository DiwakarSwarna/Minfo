import 'package:flutter/material.dart';
import 'package:mango_app/search_page.dart';
import 'package:mango_app/shimmer/hero_page_shimmer.dart';
import 'package:mango_app/utilities/settings_menu.dart';
import 'package:mango_app/widgets/flipkart_carousel.dart';
import 'package:mango_app/services/farmer_service.dart';
// Import the search page
// import 'package:mango_app/search_page.dart'; // Add this import

class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  final FarmerService _farmerService = FarmerService();

  List<String> filters = [];
  String? selectedFilter;
  List<Map<String, dynamic>> types = [];
  String searchQuery = "";
  bool shimmerisLoading = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => shimmerisLoading = true);
    final data = await _farmerService.fetchDashboardData(radiusKm: 500);
    if (mounted) {
      setState(() {
        filters = List<String>.from(data["filters"].map((f) => f["typeName"]));
        types = List<Map<String, dynamic>>.from(data["types"]);
        selectedFilter = filters.isNotEmpty ? filters[0] : null;
        isLoading = false;
        shimmerisLoading = false;
      });
    }
  }

  // Navigate to search page
  Future<void> _openSearchPage() async {
    // Get all unique mango types from the data
    final allMangoTypes = filters.toSet().toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(allMangoTypes: allMangoTypes),
      ),
    );

    // If user selected a search term, apply it
    if (result != null && result is String) {
      setState(() {
        searchQuery = result;
      });
    }
  }

  final GlobalKey settingsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (shimmerisLoading) {
      return const HeroPageShimmer();
    }
    final filteredItems =
        types.where((element) {
          if (searchQuery.isNotEmpty) {
            return element['mangoType'].toString().toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }
          return element['mangoType'] == selectedFilter;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFFFFFFFF),
        // elevation: 1,
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Minfo",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  key: settingsKey,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade500,
                    size: 28,
                  ),
                  onPressed: () => AboutMenu.show(context, settingsKey),
                ),
                // Icon(Icons.more_vert, color: Colors.green.shade700, size: 30),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: _openSearchPage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 20),
                      SizedBox(width: 8),
                      Text(
                        searchQuery.isEmpty
                            ? "Search mango type..."
                            : searchQuery,
                        style: TextStyle(
                          color:
                              searchQuery.isEmpty
                                  ? Colors.grey[500]
                                  : Colors.grey[800],
                          fontSize: 16,
                          fontWeight:
                              searchQuery.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Carousel Section
          AmazonCarousel(
            items: [
              CarouselItem(
                imageUrl:
                    'https://images.unsplash.com/photo-1734163075572-8948e799e42c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fG1hbmdvZXN8ZW58MHwwfDB8fHww',
                title: 'Fresh Mangoes',
                subtitle: 'Premium Quality - 100% Organic',
              ),
              CarouselItem(
                imageUrl:
                    'https://plus.unsplash.com/premium_photo-1675715402966-627154aa4ab2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bWFuZ29lc3xlbnwwfDB8MHx8fDA%3D',
                title: 'New Season Arrivals',
                subtitle: 'Best Quality Mangoes',
              ),
              CarouselItem(
                imageUrl:
                    'https://images.unsplash.com/photo-1744565172191-7d880276a6c5?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fG1hbmdvZXN8ZW58MHwwfDB8fHww',
                title: 'Mobile Free Operations',
                subtitle: 'Seamless Selling Experience',
              ),
              CarouselItem(
                imageUrl:
                    'https://images.unsplash.com/photo-1676391170519-2410dc108f6c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzR8fG1hbmdvZXN8ZW58MHwwfDB8fHww',

                title: 'Connect Nationwide',
                subtitle: 'All Over India Trade',
              ),
              CarouselItem(
                imageUrl:
                    "https://plus.unsplash.com/premium_photo-1682126502529-69dbbd1de6fa?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bWFuZ29lcyUyMGNyYXRlc3xlbnwwfDB8MHx8fDA%3D",
                title: "Safe Trading",
                subtitle: "Hassle-free Transactions",
              ),
            ],
            height: 200.0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 2),
            margin: EdgeInsets.all(16),
          ),

          // Filter Section (only show if no search query)
          if (searchQuery.isEmpty)
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Type:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            filters.map((filter) {
                              final isSelected = selectedFilter == filter;
                              return Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedFilter = filter;
                                    });
                                  },
                                  selectedColor: Colors.green[100],
                                  checkmarkColor: Colors.green[700],
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.green[700]
                                            : Colors.grey[600],
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? Colors.green[700]!
                                            : Colors.grey[300]!,
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

          SizedBox(height: 8),

          // Results count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  searchQuery.isNotEmpty
                      ? '${filteredItems.length} results for "$searchQuery"'
                      : '${filteredItems.length} mandis found buying $selectedFilter',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchQuery = "";
                      });
                    },
                    child: Text('Clear'),
                  ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // List Section
          Expanded(
            child:
                filteredItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchQuery.isNotEmpty
                                ? "No results found for \"$searchQuery\""
                                : "No mandis available buying $selectedFilter",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final String title = item['mandiName'] ?? 'Mandi Name';
                        final int price =
                            int.tryParse(item['price'].toString()) ?? 0;
                        final int capacity =
                            int.tryParse(item['capacity'].toString()) ?? 0;

                        return Card(
                          elevation: 2,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Price: ₹$price/kg",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      if (capacity > 0)
                                        Text(
                                          "Buying Capacity: $capacity tons",
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        )
                                      else
                                        const Text(
                                          "Not available",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "2km",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

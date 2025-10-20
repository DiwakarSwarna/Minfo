import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final List<String> allMangoTypes;

  const SearchPage({super.key, required this.allMangoTypes});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];
  List<String> recentSearches = [];
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      if (mounted) {
        setState(() {
          recentSearches = searches;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recent searches: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Save a search term to recent searches
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove the query if it already exists (to move it to top)
      recentSearches.remove(query);

      // Add to the beginning of the list
      recentSearches.insert(0, query);

      // Keep only the last N searches
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches = recentSearches.sublist(0, _maxRecentSearches);
      }

      // Save to SharedPreferences
      await prefs.setStringList(_recentSearchesKey, recentSearches);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  // Clear all recent searches
  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      if (mounted) {
        setState(() {
          recentSearches = [];
        });
      }
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // Delete a single recent search
  Future<void> _deleteRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      recentSearches.remove(query);
      await prefs.setStringList(_recentSearchesKey, recentSearches);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error deleting recent search: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        searchResults = [];
      } else {
        searchResults =
            widget.allMangoTypes
                .where(
                  (type) => type.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _selectSearch(String query) async {
    // Save to recent searches before returning
    await _saveRecentSearch(query);
    if (mounted) {
      Navigator.pop(context, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search mango type...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600]),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: Colors.grey[300]),

          if (_searchController.text.isEmpty) ...[
            // Recent Searches Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (recentSearches.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Clear Recent Searches'),
                                content: Text(
                                  'Are you sure you want to clear all recent searches?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _clearRecentSearches();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    ),
                ],
              ),
            ),
            // Recent Searches List
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : recentSearches.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No recent searches',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: recentSearches.length,
                        itemBuilder: (context, index) {
                          final search = recentSearches[index];
                          return ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Colors.grey[600],
                            ),
                            title: Text(search),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () => _deleteRecentSearch(search),
                                  padding: EdgeInsets.all(8),
                                  constraints: BoxConstraints(),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.north_west,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ],
                            ),
                            onTap: () => _selectSearch(search),
                          );
                        },
                      ),
            ),
          ] else ...[
            // Search Results
            Expanded(
              child:
                  searchResults.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            title: Text(searchResults[index]),
                            trailing: Icon(
                              Icons.north_west,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            onTap: () => _selectSearch(searchResults[index]),
                          );
                        },
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

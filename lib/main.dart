import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Price List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: PriceListScreen(),
    );
  }
}

class PriceListScreen extends StatefulWidget {
  @override
  _PriceListScreenState createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  List<Map<String, String>> items = [];
  List<Map<String, String>> filteredItems = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await ApiService.fetchData();
      setState(() {
        items = data;
        filteredItems = data;
        isLoading = false;
      });
    } catch (e) {
      // If offline, load cached data
      final cachedData = await ApiService.getCachedData();
      setState(() {
        items = cachedData;
        filteredItems = cachedData;
        isLoading = false;
      });
    }
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['Item Name']!.toLowerCase().contains(query.toLowerCase()) ||
              item['Category']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filteredItems = items
          .where((item) => item['Category']!.toLowerCase() == category.toLowerCase())
          .toList();
    });
  }

  void clearFilters() {
    setState(() {
      selectedCategory = '';
      filteredItems = items;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price List'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filterItems,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      // "All" category button
                      FilterChip(
                        label: Text('All'),
                        selected: selectedCategory.isEmpty,
                        onSelected: (isSelected) {
                          clearFilters();
                        },
                      ),
                      SizedBox(width: 8),
                      // Other category buttons
                      ...items
                          .map((item) => item['Category']!)
                          .toSet()
                          .map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (isSelected) {
                              filterByCategory(category);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['Item Name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Price: \$${item['Price']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Category: ${item['Category']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                item['Description']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
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

import 'package:flutter/material.dart';
import '../database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Price List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MonitorPage(items: []),  // Set MonitorPage as the home screen
    );
  }
}

class MonitorPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  MonitorPage({required this.items});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  String? selectedBrand;
  String? selectedCategory;
  String searchQuery = '';
  List<Map<String, dynamic>> items = [];

  final List<String> brands = ['Hifocus', 'CP Plus', 'Dahua', 'Hikvision', 'OEM'];
  final List<String> categories = ['Camera', 'DVR', 'HDD', 'Connectors', 'Cables'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.readAllItems();
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = items.where((item) {
      if (selectedBrand != null && item['brand'] != selectedBrand) return false;
      if (selectedCategory != null && item['category'] != selectedCategory) return false;
      if (searchQuery.isNotEmpty && !item['name'].toLowerCase().contains(searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Create'),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateItemPage()));
                _loadItems();  // Refresh items after returning from CreateItemPage
              },
            ),
            ListTile(
              title: Text('Update'),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePricePage()));
                _loadItems();  // Refresh items after returning from UpdatePricePage
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Filter by Brand'),
                    value: selectedBrand,
                    onChanged: (value) {
                      setState(() {
                        selectedBrand = value;
                      });
                    },
                    items: brands.map((String brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Filter by Category'),
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Item Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${filteredItems[index]['name']}'),
                  subtitle: Text(
                      'Brand: ${filteredItems[index]['brand']}, '
                          'Category: ${filteredItems[index]['category']}\n'
                          'GST Price: \$${filteredItems[index]['gstPrice']}, '
                          'Cash Price: \$${filteredItems[index]['cashPrice']}'
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




class CreateItemPage extends StatefulWidget {
  @override
  _CreateItemPageState createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String? brand;
  String? category;
  double gstPrice = 0.0;
  double cashPrice = 0.0;

  final List<String> brands = ['Hifocus', 'CP Plus', 'Dahua', 'Hikvision', 'OEM'];
  final List<String> categories = ['Camera', 'DVR', 'HDD', 'Connectors', 'Cables'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Item')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                onSaved: (value) => name = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Brand Name'),
                value: brand,
                onChanged: (value) {
                  setState(() {
                    brand = value;
                  });
                },
                items: brands.map((String brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: category,
                onChanged: (value) {
                  setState(() {
                    category = value;
                  });
                },
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'GST Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => gstPrice = double.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cash Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => cashPrice = double.parse(value!),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await DatabaseHelper.instance.createItem({
                      'name': name,
                      'brand': brand!,
                      'category': category!,
                      'gstPrice': gstPrice,
                      'cashPrice': cashPrice
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





class UpdatePricePage extends StatefulWidget {
  @override
  _UpdatePricePageState createState() => _UpdatePricePageState();
}

class _UpdatePricePageState extends State<UpdatePricePage> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.readAllItems();
    setState(() {
      items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Prices')),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]['name']),
            subtitle: Text(
              'Current GST Price: \$${items[index]['gstPrice'].toStringAsFixed(2)}, '
                  'Current Cash Price: \$${items[index]['cashPrice'].toStringAsFixed(2)}',
            ),
            onTap: () {
              TextEditingController gstPriceController =
              TextEditingController(text: items[index]['gstPrice'].toString());
              TextEditingController cashPriceController =
              TextEditingController(text: items[index]['cashPrice'].toString());

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Update Prices'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: gstPriceController,
                        decoration: InputDecoration(labelText: 'GST Price'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: cashPriceController,
                        decoration: InputDecoration(labelText: 'Cash Price'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        double gstPrice = double.tryParse(gstPriceController.text) ?? items[index]['gstPrice'];
                        double cashPrice = double.tryParse(cashPriceController.text) ?? items[index]['cashPrice'];

                        await DatabaseHelper.instance.updateItem(items[index]['id'], {
                          'gstPrice': gstPrice,
                          'cashPrice': cashPrice,
                        });

                        setState(() {
                          items[index]['gstPrice'] = gstPrice;
                          items[index]['cashPrice'] = cashPrice;
                        });

                        Navigator.pop(context);
                      },
                      child: Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// A stateful widget that represents the home page of the application.
class MyHomePage extends StatefulWidget {
  /// Creates a [MyHomePage] widget.
  ///
  /// The [key] parameter is optional and can be used to control the widget's
  /// state in the widget tree.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// The state for the [MyHomePage] widget.
class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Settings Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          // PartiesListPage(database: widget.database),
          Center(child: _widgetOptions.elementAt(0)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Parties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

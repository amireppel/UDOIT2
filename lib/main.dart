import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hooks/activities_provider.dart';
import 'hooks/running_activity_provider.dart';
import 'hooks/new_activity_provider.dart';
import 'hooks/settings_provider.dart';
import 'components/activities_list.dart';
import 'components/new_activity.dart';
import 'components/settings.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      ActivitiesList(onNewActivityPressed: () {
        _onItemTapped(1);
      }),
      NewActivity(onSaveActivity: () {
        _onItemTapped(0);
      }),
      Settings(),
    ];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ActivitiesProvider()),
        ChangeNotifierProvider(create: (context) => RunningActivityProvider()),
        ChangeNotifierProvider(create: (context) => NewActivityProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<NewActivityProvider>(
        builder: (context, newActivityProvider, child) {
          return MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: Text('Activities App'),
              ),
              body: _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Activities List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: newActivityProvider.editingActivityIndex != null
                        ? 'Edit Activity'
                        : 'New Activity',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
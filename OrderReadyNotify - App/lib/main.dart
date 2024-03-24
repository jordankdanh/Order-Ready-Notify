import 'package:flutter/material.dart';
import 'welcomePage.dart';
import 'profilePage.dart';
import 'orderPage.dart';
import 'sharedData.dart'; // Import the file where SharedData class is defined
import "package:awesome_notifications/awesome_notifications.dart";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'scheduled',
          channelName: "basic_notifications",
          channelDescription: "Notification channel for basic tests",
        ),
      ],
      debug: true);
  runApp(MyApp());
}

Future<void> showNotificationPermissionDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Allow Notifications?'),
        content: Text(
            'Do you want to allow notifications from this app? They allow you to be notified when your next order is placed'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              AwesomeNotifications().requestPermissionToSendNotifications();
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyBottomNavigationBar(),
    );
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;
  final TextEditingController _ipAddressController = TextEditingController();

  final List<Widget> _screens = [
    WelcomePage(),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showNotificationPermissionDialog(context);
      }
    });

    // Use Future.delayed to execute the showIpAddressDialog after the frame has been built
    Future.delayed(Duration.zero, () {
      showIpAddressDialog(context);
    });
  }

  Future<void> showIpAddressDialog(BuildContext context) async {
    final TextEditingController _ipAddressController = TextEditingController();
    final TextEditingController _portController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Server Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _ipAddressController,
                decoration: InputDecoration(hintText: 'IP Address'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Port'),
              ),
              SizedBox(height: 10),
              Text(
                'Please enter the IP address and port from the server. Either of the two IP addresses will work. Do NOT use 0.0.0.0 as the IP address.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Concatenate "http://" with IP address and port
                String ipAddress = _ipAddressController.text;
                String port = _portController.text;
                String combinedAddress = 'http://$ipAddress:$port';

                // Store the combined address in the SharedData class
                SharedData.ipAddress = combinedAddress;

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Welcome',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

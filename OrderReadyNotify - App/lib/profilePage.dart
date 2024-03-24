import 'package:flutter/material.dart';
import 'sharedData.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? emptyCustomerInfo = {
    "customerID": 0,
    "name": "",
    "phone": "",
    "addressline": "",
    "city": "",
    "state": "",
    "zip code": "",
  };
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? foundCustomer = SharedData.customerInfo.firstWhere(
        (customer) => customer['customerID'] == SharedData.customerID,
        orElse: () => emptyCustomerInfo // Use the first item
        );
    String name = foundCustomer?["name"];
    String address =
        "${foundCustomer?["addressline"]}, ${foundCustomer?["city"]}, ${foundCustomer?["state"]}, ${foundCustomer?["zip code"]}";
    String phone = foundCustomer?["phone"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text("Address"),
            subtitle: Text(address),
          ),
          ListTile(
            title: Text("Phone"),
            subtitle: Text(phone),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Note: Only customerIDs 1-10 are registered in the database.",
              style: TextStyle(
                color: Colors
                    .red, // Set the text color to red or any other color you prefer
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showChangeUserDialog(context),
        label: Text('CHANGE USER'),
        icon: Icon(Icons.person),
        backgroundColor: Colors.orange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showChangeUserDialog(BuildContext context) {
    String enteredValue = ''; // Variable to store the entered value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change User"),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              enteredValue = value;
              // Save the entered value when it changes
            },
            decoration: InputDecoration(labelText: "Customer ID"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Set SharedData.customerID to the entered value
                SharedData.customerID = int.tryParse(enteredValue);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text("Change"),
            ),
          ],
        );
      },
    );
  }
}

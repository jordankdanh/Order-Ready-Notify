import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sharedData.dart';
import 'dart:typed_data';
import 'dart:io';

// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

int customerID = 1;

class _OrderPageState extends State<OrderPage> {
  List<dynamic> customerOrders = [];
  Uint8List? pdfData;
  Map<String, dynamic> foundCustomer = {};
  Map<String, dynamic> foundOrders = {};

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    // Cancel timers or dispose of resources here
    super.dispose();
  }

  Future<void> downloadInvoice() async {
    String invoiceUrl = SharedData.ipAddress +
        '/download_invoice'; // Replace with the actual URL to download the invoice
    try {
      final response = await http.post(
        Uri.parse(invoiceUrl),
        body: {
          'CustomerID': SharedData.customerID.toString()
        }, // Send the value in the request body
      );

      if (response.statusCode == 200) {
        setState(() {
          pdfData = response.bodyBytes;
        });
      } else {
        print(
            'Failed to download invoice. Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      print('An error occured while downloading the invoice $e');
    }
  }

  void fetchOrders() async {
    String orderUrl = SharedData.ipAddress + '/api/data';
    try {
      final response =
          await http.get(Uri.parse(orderUrl)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            SharedData.customerInfo = jsonData['CustomerInfo'];
            SharedData.products = jsonData['Products'];
            SharedData.orders = jsonData['Orders'];
            foundCustomer = SharedData.customerInfo.firstWhere(
              (customer) => customer['customerID'] == SharedData.customerID,
              orElse: () => SharedData.customerInfo[0], // Use the first item
            );
            foundOrders = SharedData.orders.firstWhere(
              (customer) => customer['customerID'] == SharedData.customerID,
              orElse: () => SharedData.orders[0], // Use the first item
            );
          });
        }
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      if (e is SocketException || e is TimeoutException) {
        // Handle network-related errors here
        if (mounted) {
          // Check if the widget is still mounted
          print('Network error: $e');
          // Return a suitable fallback value or show an error message
        }
      } else {
        // Handle other exceptions
        if (mounted) {
          // Check if the widget is still mounted
          print('Error: $e');
          // You can choose to rethrow the exception or handle it differently
        }
      }
    }
  }

  String findProductName(String productID) {
    Map<String, dynamic> product = SharedData.products
        .firstWhere((product) => product["productID"] == productID);
    return product["name"];
  }

  String findProductDescription(String productID) {
    Map<String, dynamic> product = SharedData.products
        .firstWhere((product) => product["productID"] == productID);
    return product["description"];
  }

  double findProductPrice(String productID) {
    Map<String, dynamic> product = SharedData.products
        .firstWhere((product) => product["productID"] == productID);
    return product["price"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("${foundCustomer['name']} Order's"),
          backgroundColor: Colors.orange),
      body: foundCustomer.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                foundOrders["items"] != null
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: foundOrders["items"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: Icon(Icons.star),
                              title: Text(
                                'Product: ${findProductName(foundOrders['items'][index]['productID'])} X ${foundOrders['items'][index]['quantity']}',
                              ),
                              subtitle: Text(
                                'Description: ${findProductDescription(foundOrders['items'][index]['productID'])}',
                              ),
                              trailing: Text(
                                "\$ ${findProductPrice(foundOrders['items'][index]['productID']) * foundOrders['items'][index]['quantity']}",
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text("No items found in this order."),
                      ),
                if (pdfData != null)
                  Container(
                    height: 300, // Adjust the height as needed
                    child: PDFView(
                      pdfData: pdfData,
                    ),
                  ),
                ElevatedButton(
                    onPressed: () =>
                        downloadInvoice(), // Call the downloadInvoice method
                    child: Text('Download Invoice'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ) // Set the background color of the button,
                    ),
              ],
            ),
    );
  }
}

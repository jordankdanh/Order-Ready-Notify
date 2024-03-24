import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

int selectedHour = 0;
int selectedMinute = 0;

class WelcomePage extends StatelessWidget {
  triggerNotification() async {
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'scheduled',
        title: 'Order Ready Notify!',
        body: 'Hey! Check on your order!',
      ),
      schedule: NotificationCalendar(
        hour: selectedHour,
        minute: selectedMinute,
        timeZone: localTimeZone,
        repeats: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Order Ready Notify'),
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image goes here
              Image.asset(
                'assets/bell.png', // Replace with the path to your image asset
                height: 100, // Adjust the height as needed
              ),
              SizedBox(
                height: 20,
              ), // Add some space between the image and button
              // ElevatedButton
              ElevatedButton(
                onPressed: () async {
                  await _showTimePickerDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: Text('When do you want to be Notified?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePickerDialog(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      selectedHour = pickedTime.hour;
      selectedMinute = pickedTime.minute;
      // Delay execution to allow UI thread to finish its current frame
      Future.delayed(Duration.zero, () {
        triggerNotification();
      });
      print('Selected time: ${pickedTime.format(context)}');
    }
  }
}

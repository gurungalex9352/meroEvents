import 'dart:convert';
import 'dart:html';

import 'package:clean_nepali_calendar/clean_nepali_calendar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meroEvents',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NepaliCalendarController _nepaliCalendarController =
      NepaliCalendarController();

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize with the current date or any other initial date you want
    NepaliDateTime currentDate = NepaliDateTime.now();
    String formattedDate = currentDate.toString().substring(0, 10);
    _dateController.text = formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final NepaliDateTime first = NepaliDateTime(2069, 10);
    final NepaliDateTime last = NepaliDateTime(2080, 10);

    return Scaffold(
      appBar: AppBar(
        title: Text('meroEvents'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.event), // Replace with your desired icon
            onPressed: () {
              // Implement the action when the icon is pressed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CleanNepaliCalendar(
                headerDayBuilder: (_, index) {
                  return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '$_',
                          style: TextStyle(
                              color: (index == 6) ? Colors.red : null),
                        ),
                      ));
                },

                // headerBuilder: (_,__,___,____,______)=>Text("header"),
                headerDayType: HeaderDayType.fullName,
                controller: _nepaliCalendarController,
                onHeaderLongPressed: (date) {
                  print("header long pressed $date");
                },
                onHeaderTapped: (date) {
                  print("header tapped $date");
                },

                calendarStyle: CalendarStyle(
                  // weekEndTextColor : Colors.green,
                  selectedColor: Colors.deepOrange,
                  dayStyle: TextStyle(fontWeight: FontWeight.bold),
                  todayStyle: TextStyle(
                    fontSize: 20.0,
                  ),
                  todayColor: Colors.orange.shade400,
                  // highlightSelected: true,
                  renderDaysOfWeek: true,
                  highlightToday: true,
                ),
                headerStyle: HeaderStyle(
                  enableFadeTransition: false,
                  centerHeaderTitle: false,
                  titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 15.0),
                ),
                initialDate: NepaliDateTime.now(),
                firstDate: first,
                lastDate: last,
                language: Language.nepali,

                onDaySelected: (day) {
                  String formattedDate = day.toString().substring(0, 10);
                  _dateController.text = formattedDate;
                  print(formattedDate);
                  _checkEventInDatabase(context, formattedDate);
                },

                // display the english date along with nepali date.
                dateCellBuilder: cellBuilder,
              ),
              TextField(
                autofocus: false,
                // decoration:BoxDecoration(
                //   border: 22;
                // ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showEventFormDialog(context);
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkEventInDatabase(BuildContext context, String date) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.69:3000/events/$date'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<dynamic> eventsData = responseData['events'];
        if (eventsData.isNotEmpty) {
          // Events exist for the selected date, show them in a pop-up
          _showEventsDataDialog(context, eventsData);
        }
      } else {
        print('Failed to fetch events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events from the database: $e');
    }
  }

  void _showEventsDataDialog(BuildContext context, List<dynamic> eventsData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Events'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: eventsData.map((event) {
              String eventDate = event['date'].split('T')[0];

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${event['event']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Implement event deletion here using the event ID
                        _deleteEvent(event['id']);
                      },
                    ),
                  ],
                ),
                subtitle: Text('Date: $eventDate'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _deleteEvent(int eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.69:3000/events/$eventId'),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

        print('Event deleted successfully.');
      } else {
        print('Failed to delete event. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  void _showEventFormDialog(BuildContext context) {
    TextEditingController eventDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: AlertDialog(
            title: Text('Add Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                  ),
                  enabled: false,
                ),
                TextField(
                  controller: eventDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Event Description',
                  ),
                )
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  String date = _dateController.text;
                  String eventDescription = eventDescriptionController.text;

                  // Call a method to add the event
                  _addEvent(date, eventDescription);

                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  // void _addEvent(String date, String eventDescription) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://192.168.1.69:3000/events'),
  //       headers: {
  //         'Content-Type': 'application/json', // Adjusted content type to JSON
  //       },
  //       body: jsonEncode({
  //         'event': eventDescription,
  //         'date': date,
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       print('Event added successfully.');
  //     } else {
  //       print('Failed to add event. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error adding event: $e');
  //   }
  // }

  void _addEvent(String date, String eventDescription) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/events'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event': eventDescription,
          'date': date,
        }),
      );

      if (response.statusCode == 201) {
        print('Event added successfully.');
        // Show a pop-up model here for a successful event addition
        _showEventAddedDialog();
      } else {
        print('Failed to add event. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  void _showEventAddedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Event Added'),
          content: Text('The event has been added successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget cellBuilder(isToday, isSelected, isDisabled, nepaliDate, label, text,
      calendarStyle, isWeekend) {
    // print(isSelected);
    Decoration _buildCellDecoration() {
      if (isSelected && isToday) {
        return BoxDecoration(
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.circular(5),
            color: Colors.blue,
            border: Border.all(color: calendarStyle.selectedColor));
      }
      if (isSelected) {
        return BoxDecoration(
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: calendarStyle.selectedColor));
      } else if (isToday && calendarStyle.highlightToday) {
        return BoxDecoration(
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.transparent),
          color: Colors.blue,
        );
      } else {
        return BoxDecoration(
          // shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.transparent),
        );
      }
    }

    return AnimatedContainer(
      padding: EdgeInsets.all(3),
      duration: Duration(milliseconds: 2000),
      decoration: _buildCellDecoration(),
      child: Center(
        child: Column(
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 20, color: isWeekend ? Colors.red : null)),

            // to show events
            // Align(
            //     alignment: Alignment.bottomCenter,
            //     child: CircleAvatar(
            //       radius: 1,
            //     )),
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: Text(nepaliDate.toDateTime().day.toString(),
            //       style: TextStyle(
            //           fontSize: 8, color: isWeekend ? Colors.red : null)),
            // ),
          ],
        ),
      ),
    );
  }
}

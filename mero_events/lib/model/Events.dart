class Event {
  final int? id;
  final String event;
  final String date; // Change the date type to String

  Event({ this.id, required this.event, required this.date });

  Map<String, dynamic> toJson(){
    return{
      'event' : event,
      'date' : date,
    };
  }
}

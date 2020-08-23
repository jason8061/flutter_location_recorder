class NewLocationRecord {
  int recordID;
  String year;
  String month;
  String day;
  String startTime; //HH:MM
  String finishTime;
  double startLat, startLon, finishLat, finishLon;
  String startAddress, finishAddress;
  String distance;
  String comment;

  NewLocationRecord(
      {this.recordID,
      this.year,
      this.month,
      this.day,
      this.startTime,
      this.finishTime,
      this.startLat,
      this.startLon,
      this.finishLat,
      this.finishLon,
      this.startAddress,
      this.finishAddress,
      this.distance,
      this.comment});
  factory NewLocationRecord.fromMap(Map<String, dynamic> json) =>
      NewLocationRecord(
          recordID: json['record_id'],
          year: json['year'],
          month: json['month'],
          day: json['day'],
          startTime: json['start_time'],
          finishTime: json['finish_time'],
          startLat: json['start_lat'],
          startLon: json['start_lon'],
          finishLat: json['finish_lat'],
          finishLon: json['finish_lon'],
          startAddress: json['start_address'],
          finishAddress: json['finish_address'],
          distance: json['distance'],
          comment: json['comment']);

  Map<String, dynamic> toMap() => {
        'record_id': recordID,
        'year': year,
        'month': month,
        'day': day,
        'start_time': startTime,
        'finish_time': finishTime,
        'start_lat': startLat,
        'start_lon': startLon,
        'finish_lat': finishLat,
        'finish_lon': finishLon,
        'start_address': startAddress,
        'finish_address': finishAddress,
        'distance': distance,
        'comment': comment
      };
  /*
        "create table if not exists locationrecord ("
          "id integer primary key autoincrement,"
          "record_id integer,"
          "year char(10),"
          "month char(10),"
          "day char(10),"
          "start_time char(20),"
          "finish_time char(20),"
          "start_lat real,"
          "start_lon real,"
          "finish_lat real,"
          "finish_lon real,"
          "start_address text,"
          "finish_address text,"
          "distance char(30),"
          "comment text"
          ")"
      */

}

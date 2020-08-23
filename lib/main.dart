import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_location_recorder/model.dart';
import 'package:flutter_location_recorder/service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:geolocator/models/location_accuracy.dart';
//import 'package:geolocator/models/position.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Location Recorder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  bool ifStart = false;
  int totalRecords = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkifStart();
  }

  _checkifStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('recordID') != null) {
      ifStart = true;
    }
  }

  void _recordStop() async {
    //retrieve id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var recordID = prefs.getInt('recordID');

    print(recordID);

    var res = await SqliteService.db.retrieveRecord(recordID);

    print('res runtimetype= ${res.runtimeType}');
    if (res is NewLocationRecord) {
      //get current location
      Position currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      DateTime now = DateTime.now();
      var finishTime = now.hour.toString() + ':' + now.minute.toString();
      print('finish time is $finishTime');

      List<Placemark> finishAddress = await Geolocator()
          .placemarkFromCoordinates(
              currentLocation.latitude, currentLocation.longitude);

      //cal distance
      double distanceInMeters = await Geolocator().distanceBetween(
              res.startLat,
              res.startLon,
              currentLocation.latitude,
              currentLocation.longitude) /
          1000;

      /*    var update_res = await SqliteService.db.updateRecord(
          NewLocationRecord(
              recordID: recordID,
              year: res.year,
              month: res.month,
              day: res.day,
              startTime: res.startTime,
              finishTime: finishTime,
              startLat: res.startLat,
              startLon: res.startLon,
              finishLat: currentLocation.latitude,
              finishLon: currentLocation.longitude,
              startAddress: res.startAddress,
              finishAddress: jsonEncode(finishAddress),
              distance: distanceInMeters.toString(),
              comment: _controller.text),
          recordID);

      prefs.clear();
      print('update_res=$update_res');*/
      // setState(() {});
    }
  }

  void _recordStart() async {
    //get current location
    Position currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    //get time point
    var recordID = DateTime.now().millisecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('recordID', recordID);

    DateTime now = DateTime.now();

    var year = now.year.toString();
    var month = now.month.toString();
    var day = now.day.toString();
    var startTime = now.hour.toString() + ':' + now.minute.toString();

    //get address
    List<Placemark> startAddress = await Geolocator().placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);
    /*
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
       
       
       */
    var res = await SqliteService.db.newRecord(NewLocationRecord(
        recordID: recordID,
        year: year,
        month: month,
        day: day,
        startTime: startTime,
        finishTime: '',
        startLat: currentLocation.latitude,
        startLon: currentLocation.longitude,
        finishLat: 0,
        finishLon: 0,
        startAddress: jsonEncode(startAddress),
        finishAddress: '',
        distance: '',
        comment: _controller.text));

    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 150,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButton.icon(
                        onPressed: () async {
                          //   _recordStart();
                          if (!ifStart)
                            _recordStart();
                          else
                            _recordStop();
                          setState(() {
                            ifStart = !ifStart;
                          });
                        },
                        icon: Icon(ifStart ? Icons.pause : Icons.play_arrow),
                        label: Text('Start')),
                    RaisedButton(
                      onPressed: () async {
                        var res = await SqliteService.db.deleteAll();
                        print(res);
                        setState(() {});
                      },
                      child: Text('Delete All'),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        var res =
                            await SqliteService.db.getTotalNumberRecords();
                        totalRecords = res;
                        setState(() {});
                      },
                      child: Text('Totals'),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        var res = await SqliteService.db.retrieveAllRecords();
                        print(res);
                      },
                      child: Text('Retrieve All'),
                    ),
                    Text('total: $totalRecords'),
                  ],
                ),
                TextField(
                  controller: _controller,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: SqliteService.db.retrieveAllRecords(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<NewLocationRecord>> snapshot) {
                // if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<DataRow> listRows = [];

                  snapshot.data.forEach((item) {
                    var startAddress = jsonDecode(item.startAddress)[0];
                    print(item.distance);
                    var finishAddress = jsonDecode(item.finishAddress)[0];
                    var row = DataRow(
                      cells: [
                        DataCell(Text(item.year)),
                        DataCell(Text(item.month)),
                        DataCell(Text(item.day)),
                        DataCell(Text(item.startTime)),
                        DataCell(Text(item.finishTime)),
                        DataCell(Text(
                            'Near  ${startAddress['subThoroughfare']} ${startAddress['thoroughfare']},  ${startAddress['locality']}')),
                        DataCell(Text(
                            'Near  ${finishAddress['subThoroughfare']} ${finishAddress['thoroughfare']},  ${finishAddress['locality']}')),
                        DataCell(Text('${item.distance} KM')),
                        DataCell(Text(item.comment)),
                      ],
                    );
                    listRows.add(row);
                  });

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Year')),
                          DataColumn(label: Text('Month')),
                          DataColumn(label: Text('Day')),
                          DataColumn(label: Text('Start')),
                          DataColumn(label: Text('Finish')),
                          DataColumn(label: Text('Start fr')),
                          DataColumn(label: Text('Stop at')),
                          DataColumn(label: Text('Distance')),
                          DataColumn(label: Text('Comment')),
                        ],
                        rows: listRows,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error);
                } else
                  return Text('No Record found');
                // }
              },
            ),
          )
        ],
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

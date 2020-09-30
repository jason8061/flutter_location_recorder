import 'dart:async';

import 'package:flutter_location_recorder/model.dart';
import 'package:flutter_location_recorder/service.dart';

class BlocDemo {
  final _blocController = StreamController<List<NewLocationRecord>>.broadcast();

  get records => _blocController.stream;

  BlocDemo() {
    getRecords();
  }

  getRecords() async {
    print('run get records');
    _blocController.sink.add(await SqliteService.db.retrieveAllRecords());
  }

  addRecord(NewLocationRecord newRecord) async {
    await SqliteService.db.newRecord(newRecord);
    getRecords();
  }

  updateRecord(NewLocationRecord updateRecord, int recordID) async {
    await SqliteService.db.updateRecord(updateRecord, recordID);
    getRecords();
  }

  deleteRecords() async {
    await SqliteService.db.deleteAll();
    getRecords();
  }

  dispose() {
    _blocController.close();
  }
}

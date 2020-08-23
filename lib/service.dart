import 'package:flutter_location_recorder/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  SqliteService._();

  static final SqliteService db = SqliteService._();
  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, 'locationrecorder.db');
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
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("create table if not exists locationrecord ("
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
          ")");
    });
  }

  deleteAll() async {
    final db = await database;
    var res = await db.delete('locationrecord');
    return res;
  }

  getTotalNumberRecords() async {
    final db = await database;
    var res = await db.query('locationrecord');
    return res.length;
  }

  newRecord(NewLocationRecord newRecord) async {
    final db = await database;
    var res = await db.insert('locationrecord', newRecord.toMap());
    return res;
  }

  retrieveRecord(int recordid) async {
    final db = await database;
    var res = await db
        .query('locationrecord', where: 'record_id=?', whereArgs: [recordid]);

    if (res.isNotEmpty)
      return NewLocationRecord.fromMap(res[0]);
    else
      return 'No Record';
  }

  updateRecord(NewLocationRecord updateRecord, int recordid) async {
    final db = await database;
    var res = await db.update('locationrecord', updateRecord.toMap(),
        where: 'record_id=?', whereArgs: [recordid]);

    return res;
  }

  Future<List<NewLocationRecord>> retrieveAllRecords() async {
    final db = await database;
    List<NewLocationRecord> list = [];

    var res = await db.query('locationrecord', orderBy: 'record_id DESC');

    list = res.isNotEmpty
        ? res.map((e) => NewLocationRecord.fromMap(e)).toList()
        : [];

    return list;
  }
}

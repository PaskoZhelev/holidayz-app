import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/models.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), DB_NAME);

    File dbFile = File(dbPath);

    var exists = await dbFile.exists();

    if (!exists) {
      await resetDb(dbPath);
    }

    // open the database
    return await openDatabase(dbPath, version: DB_VERSION, onUpgrade: _onUpgrade);
  }

  // UPGRADE DATABASE TABLES
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // if (oldVersion < 2) {
    //   db.execute("ALTER TABLE tabEmployee ADD COLUMN newCol TEXT;");
    // }
  }

  Future<void> resetDb(var dbPath) async {
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(join("assets/db", DB_NAME));
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  // Countries
  Future<List<Country>> getCountries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('countries', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Country(
        id: maps[i]['id'],
        name: maps[i]['name'],
        abbreviation: maps[i]['abbreviation'],
      );
    });
  }

  // Regions
  Future<List<Region>> getRegionsByCountry(int countryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'regions',
      where: 'country_id = ?',
      whereArgs: [countryId],
      orderBy: 'name ASC'
    );
    return List.generate(maps.length, (i) {
      return Region(
        id: maps[i]['id'],
        name: maps[i]['name'],
        abbreviation: maps[i]['abbreviation'],
        countryId: maps[i]['country_id'],
      );
    });
  }

  // Holidays

  // Add method to get regions for a specific holiday
  Future<List<int>> getHolidayRegionIds(int holidayId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holiday_regions',
      columns: ['region_id'],
      where: 'holiday_id = ?',
      whereArgs: [holidayId],
    );
    return maps.map((map) => map['region_id'] as int).toList();
  }

  Future<int> countNonGlobalHolidays(int countryId, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM holidays
      WHERE country_id = ? 
        AND strftime('%Y', date) = ?
        AND global = 0
    ''', [countryId, year.toString()]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Holiday>> getHolidaysByYearAndRegion(
      int countryId, int regionId, int year) async {
    final db = await database;

    // This query gets holidays that are either:
    // 1. Global holidays for the country (global = 1)
    // 2. Region-specific holidays for the selected region (global = 0)
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT h.*
      FROM holidays h
      LEFT JOIN holiday_regions hr ON h.id = hr.holiday_id
      WHERE h.country_id = ?
        AND strftime('%Y', h.date) = ?
        AND (h.global = 1 OR (h.global = 0 AND hr.region_id = ?))
      ORDER BY h.date
    ''', [countryId, year.toString(), regionId]);

    return List.generate(maps.length, (i) {
      return Holiday(
        id: maps[i]['id'],
        localName: maps[i]['local_name'],
        englishName: maps[i]['english_name'],
        date: DateTime.parse(maps[i]['date']),
        global: maps[i]['global'] == 1,
        types: maps[i]['types'],
        countryId: maps[i]['country_id'],
      );
    });
  }

  Future<List<Holiday>> getHolidaysByYear(int countryId, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holidays',
      where: 'country_id = ? AND strftime("%Y", date) = ? AND global = 1',
      whereArgs: [countryId, year.toString()],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return Holiday(
        id: maps[i]['id'],
        localName: maps[i]['local_name'],
        englishName: maps[i]['english_name'],
        date: DateTime.parse(maps[i]['date']),
        global: maps[i]['global'] == 1,
        types: maps[i]['types'],
        countryId: maps[i]['country_id'],
      );
    });
  }
}

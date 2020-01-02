/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'dart:async';
import 'package:matokeo_core_flutter/matokeo_core_flutter.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:matokeo_core/matokeo_core.dart' show CachedResultData;
import 'package:meta/meta.dart';

enum CacheType { Psle, Regions, Districts, Results }

//tables
final String _tablePsle = 'Psle';
final String _tableRegions = 'Regions';
final String _tableDistricts = 'Districts';
final String _tableResults = 'Results';

//columns
final String _columnId = '_id';
final String _columnName = 'name';
final String _columnYear = 'year';
final String _columnUrl = 'url';
final String _columnXml = 'xml';

class ResultsCacheException implements Exception {
  final String message;

  ResultsCacheException(this.message);

  @override
  String toString() {
    return message;
  }
}

class ResultsCache extends MagabeDb {
  static final ResultsCache _singleton = ResultsCache._();

  //private contractor
  ResultsCache._();

  static ResultsCache get instance => _singleton;

  @override
  String get name => 'results_cache.db';

  @override
  int get version => 1;

  @override
  FutureOr<void> onCreate(Database database, int version) async {
    await _createTable(database, _tablePsle);
    await _createTable(database, _tableRegions);
    await _createTable(database, _tableDistricts);
    await _createTable(database, _tableResults);
  }

  Future<void> _createTable(Database database, String tableName) async {
    return database.execute('''
          CREATE TABLE $tableName (
          $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_columnName TEXT NOT NULL,
          $_columnYear INTEGER NOT NULL,
          $_columnUrl TEXT NOT NULL,
          $_columnXml TEXT NOT NULL)
          ''');
  }

  Future<CachedResultData> doInsert(
      {@required CacheType cacheType,
      @required CachedResultData cachedResultData}) async {
    if ((cacheType == null) || (cachedResultData == null)) {
      throw ResultsCacheException('cacheType or cachedResultData is null');
    }
    switch (cacheType) {
      case CacheType.Psle:
        var id = await (await db).insert(_tablePsle, cachedResultData.toJson());
        return cachedResultData.copyWith(id: id);
      case CacheType.Regions:
        var id =
            await (await db).insert(_tableRegions, cachedResultData.toJson());
        return cachedResultData.copyWith(id: id);
      case CacheType.Districts:
        var id =
            await (await db).insert(_tableDistricts, cachedResultData.toJson());
        return cachedResultData.copyWith(id: id);
      case CacheType.Results:
        var id =
            await (await db).insert(_tableResults, cachedResultData.toJson());
        return cachedResultData.copyWith(id: id);
    }

    throw ResultsCacheException('Failed to insert $cachedResultData');
  }

  Future<CachedResultData> doGet(
      {@required CacheType cacheType, String name, String url}) async {
    Future<CachedResultData> getting(String table) async {
      if ((name == null) && (url == null)) {
        return null;
      }
      List<Map> maps = await (await db).query(table,
          columns: [
            _columnId,
            _columnName,
            _columnYear,
            _columnUrl,
            _columnXml
          ],
          where: '${(name != null) ? _columnName : _columnUrl} = ?',
          whereArgs: [name ?? url]);
      if (maps.length > 0) {
        return CachedResultData.fromJson(maps.first);
      }
      return null;
    }

    Future<CachedResultData> data;
    switch (cacheType) {
      case CacheType.Psle:
        data = getting(_tablePsle);
        break;
      case CacheType.Regions:
        data = getting(_tableRegions);
        break;
      case CacheType.Districts:
        data = getting(_tableDistricts);
        break;
      case CacheType.Results:
        data = getting(_tableResults);
        break;
    }
    if (data != null) {
      return data;
    } else {
      throw ResultsCacheException('Cache not found');
    }
  }

  Future<int> doDelete(
      {@required CacheType cacheType, String name, String url}) async {
    Future<int> del(String table) async {
      if ((name == null) && (url == null)) {
        return null;
      }
      return (await db).delete(table,
          where: '${(name != null) ? _columnName : _columnUrl} = ?',
          whereArgs: [name ?? url]);
    }

    Future<int> data;
    switch (cacheType) {
      case CacheType.Psle:
        data = del(_tablePsle);
        break;
      case CacheType.Regions:
        data = del(_tableRegions);
        break;
      case CacheType.Districts:
        data = del(_tableDistricts);
        break;
      case CacheType.Results:
        data = del(_tableResults);
        break;
    }
    if (data != null) {
      return data;
    } else {
      return 0;
    }
  }

  Future<int> doUpdate(
      {@required CacheType cacheType,
      @required CachedResultData cachedResultData}) async {
    Future<int> updating(String table) async {
      return (await db).update(table, cachedResultData.toJson(),
          where: '$_columnId = ?', whereArgs: [cachedResultData.id]);
    }

    Future<int> data;
    switch (cacheType) {
      case CacheType.Psle:
        data = updating(_tablePsle);
        break;
      case CacheType.Regions:
        data = updating(_tableRegions);
        break;
      case CacheType.Districts:
        data = updating(_tableDistricts);
        break;
      case CacheType.Results:
        data = updating(_tableResults);
        break;
    }
    if (data != null) {
      return data;
    } else {
      return 0;
    }
  }

  Future doClose() async => (await db).close();
}

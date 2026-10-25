import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class StudyStore {
  StudyStore._();
  static final StudyStore instance = StudyStore._();
  Future<Database>? _opening;

  Future<Database> get db => _opening ??= _open();

  Future<Database> _open() async {
    final base = await getApplicationDocumentsDirectory();
    return openDatabase(
      p.join(base.path, 'ibrahim_study.db'),
      version: 3,
      onCreate: (d, _) async {
        await d.execute(
          'CREATE TABLE subjects(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,color INTEGER NOT NULL,icon INTEGER NOT NULL,notes TEXT NOT NULL DEFAULT "")',
        );
        await d.execute(
          'CREATE TABLE lessons(id INTEGER PRIMARY KEY AUTOINCREMENT,subject_id INTEGER NOT NULL,title TEXT NOT NULL,summary TEXT NOT NULL DEFAULT "",done INTEGER NOT NULL DEFAULT 0,created_at TEXT NOT NULL)',
        );
        await d.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,due TEXT,done INTEGER NOT NULL DEFAULT 0)',
        );
        await d.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,body TEXT NOT NULL,created_at TEXT NOT NULL)',
        );
        await d.execute(
          'CREATE TABLE sessions(day TEXT PRIMARY KEY,minutes INTEGER NOT NULL DEFAULT 0)',
        );
        await d.execute(
          'CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL)',
        );
        await d.execute(
          'CREATE TABLE schedule(id INTEGER PRIMARY KEY AUTOINCREMENT,subject_id INTEGER,topic TEXT NOT NULL,starts_at TEXT NOT NULL,duration INTEGER NOT NULL)',
        );
      },
      onUpgrade: (d, old, _) async {
        if (old < 2)
          await d.execute(
            'CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL)',
          );
        if (old < 3)
          await d.execute(
            'CREATE TABLE schedule(id INTEGER PRIMARY KEY AUTOINCREMENT,subject_id INTEGER,topic TEXT NOT NULL,starts_at TEXT NOT NULL,duration INTEGER NOT NULL)',
          );
      },
    );
  }

  Future<List<Map<String, Object?>>> subjects() async =>
      (await db).query('subjects', orderBy: 'id DESC');
  Future<List<Map<String, Object?>>> lessons(int sid) async => (await db).query(
    'lessons',
    where: 'subject_id=?',
    whereArgs: [sid],
    orderBy: 'id DESC',
  );
  Future<List<Map<String, Object?>>> tasks() async =>
      (await db).query('tasks', orderBy: 'done ASC, id DESC');
  Future<List<Map<String, Object?>>> notes() async =>
      (await db).query('notes', orderBy: 'id DESC');
  Future<List<Map<String, Object?>>> schedule() async =>
      (await db).query('schedule', orderBy: 'starts_at ASC');
  Future<int> addSchedule(
    int? subjectId,
    String topic,
    DateTime startsAt,
    int duration,
  ) async => (await db).insert('schedule', {
    'subject_id': subjectId,
    'topic': topic,
    'starts_at': startsAt.toIso8601String(),
    'duration': duration,
  });
  Future<void> deleteSchedule(int id) async =>
      (await db).delete('schedule', where: 'id=?', whereArgs: [id]);
  Future<String?> getSetting(String key) async {
    final rows = await (await db).query(
      'settings',
      'schedule',
      where: 'key=?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async => (await db).insert(
    'settings',
    {'key': key, 'value': value},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  Future<int> addSubject(
    String name,
    int color,
    int icon,
    String notes,
  ) async => (await db).insert('subjects', {
    'name': name,
    'color': color,
    'icon': icon,
    'notes': notes,
  });
  Future<void> updateSubject(
    int id,
    String name,
    int color,
    int icon,
    String notes,
  ) async => (await db).update(
    'subjects',
    {'name': name, 'color': color, 'icon': icon, 'notes': notes},
    where: 'id=?',
    whereArgs: [id],
  );
  Future<void> deleteSubject(int id) async {
    final d = await db;
    await d.transaction((t) async {
      await t.delete('lessons', where: 'subject_id=?', whereArgs: [id]);
      await t.delete('subjects', where: 'id=?', whereArgs: [id]);
    });
  }

  Future<int> addLesson(int sid, String title, String summary) async =>
      (await db).insert('lessons', {
        'subject_id': sid,
        'title': title,
        'summary': summary,
        'created_at': DateTime.now().toIso8601String(),
      });
  Future<void> updateLesson(Map<String, Object?> row) async =>
      (await db).update(
        'lessons',
        {'title': row['title'], 'summary': row['summary'], 'done': row['done']},
        where: 'id=?',
        whereArgs: [row['id']],
      );
  Future<void> deleteLesson(int id) async =>
      (await db).delete('lessons', where: 'id=?', whereArgs: [id]);
  Future<int> addTask(String title, DateTime? due) async => (await db).insert(
    'tasks',
    {'title': title, 'due': due?.toIso8601String()},
  );
  Future<void> toggleTask(int id, bool value) async => (await db).update(
    'tasks',
    {'done': value ? 1 : 0},
    where: 'id=?',
    whereArgs: [id],
  );
  Future<void> deleteTask(int id) async =>
      (await db).delete('tasks', where: 'id=?', whereArgs: [id]);
  Future<int> addNote(String title, String body) async =>
      (await db).insert('notes', {
        'title': title,
        'body': body,
        'created_at': DateTime.now().toIso8601String(),
      });
  Future<void> deleteNote(int id) async =>
      (await db).delete('notes', where: 'id=?', whereArgs: [id]);
  Future<void> recordStudy(int minutes) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final d = await db;
    await d.rawInsert(
      'INSERT INTO sessions(day,minutes) VALUES(?,?) ON CONFLICT(day) DO UPDATE SET minutes=minutes+excluded.minutes',
      [today, minutes],
    );
  }

  Future<Map<String, dynamic>> stats() async {
    final d = await db;
    final all =
        Sqflite.firstIntValue(
          await d.rawQuery('SELECT COUNT(*) FROM lessons'),
        ) ??
        0;
    final done =
        Sqflite.firstIntValue(
          await d.rawQuery('SELECT COUNT(*) FROM lessons WHERE done=1'),
        ) ??
        0;
    final days =
        Sqflite.firstIntValue(
          await d.rawQuery('SELECT COUNT(*) FROM sessions WHERE minutes>0'),
        ) ??
        0;
    final rows = await d.rawQuery(
      'SELECT s.id,s.name,s.color,COUNT(l.id) total,COALESCE(SUM(CASE WHEN l.done=1 THEN 1 ELSE 0 END),0) done FROM subjects s LEFT JOIN lessons l ON l.subject_id=s.id GROUP BY s.id',
    );
    rows.sort((a, b) {
      final aTotal = a['total'] as int;
      final bTotal = b['total'] as int;
      final aRatio = aTotal == 0 ? 0.0 : (a['done'] as int) / aTotal;
      final bRatio = bTotal == 0 ? 0.0 : (b['done'] as int) / bTotal;
      return bRatio.compareTo(aRatio);
    });
    return {'total': all, 'done': done, 'days': days, 'subjects': rows};
  }

  Future<File> exportBackup() async {
    final d = await db;
    final data = <String, dynamic>{};
    for (final table in [
      'subjects',
      'lessons',
      'tasks',
      'notes',
      'sessions',
      'settings',
      'schedule',
    ]) {
      data[table] = await d.query(table);
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ibrahim_study_backup.json'));
    return file..writeAsString(jsonEncode(data));
  }

  Future<void> importBackup(File file) async {
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final d = await db;
    await d.transaction((t) async {
      for (final table in [
        'lessons',
        'tasks',
        'notes',
        'sessions',
        'settings',
        'schedule',
        'subjects',
      ]) {
        await t.delete(table);
      }
      for (final table in [
        'subjects',
        'lessons',
        'tasks',
        'notes',
        'sessions',
        'settings',
        'schedule',
      ]) {
        for (final row in (data[table] as List? ?? const [])) {
          await t.insert(
            table,
            Map<String, Object?>.from(row as Map),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }
}

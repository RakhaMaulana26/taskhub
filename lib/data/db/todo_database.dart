import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../models/subtask.dart';
import '../models/notification.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();

  static Database? _database;

  TodoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Buat tabel todos
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        deadline TEXT,
        notification INTEGER,
        description TEXT,
        isDone INTEGER NOT NULL
      )
    ''');

    // Buat tabel subtasks
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todoId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        FOREIGN KEY (todoId) REFERENCES todos(id) ON DELETE CASCADE
      )
    ''');

    // Buat tabel Notif
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        todoId INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        isSent INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (todoId) REFERENCES todos(id) ON DELETE CASCADE
      )
    ''');

  }

  // CRUD Todo

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;
    final id = await db.insert('todos', todo.toMap());
    return todo.copyWith(id: id);
  }

  Future<Todo?> readTodo(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'todos',
      columns: ['id', 'title', 'category', 'deadline', 'notification', 'description', 'isDone'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Todo>> readAllTodos() async {
    final db = await instance.database;
    final result = await db.query('todos', orderBy: 'id DESC');
    return result.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instance.database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Subtask

  Future<Subtask> createSubtask(Subtask subtask) async {
    final db = await instance.database;
    final id = await db.insert('subtasks', subtask.toMap());
    return subtask.copyWith(id: id);
  }

  Future<List<Subtask>> readSubtasksByTodoId(int todoId) async {
    final db = await instance.database;
    final result = await db.query(
      'subtasks',
      where: 'todoId = ?',
      whereArgs: [todoId],
      orderBy: 'id ASC',
    );
    return result.map((json) => Subtask.fromMap(json)).toList();
  }

  Future<int> updateSubtask(Subtask subtask) async {
    final db = await instance.database;
    return db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<int> deleteSubtask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'subtasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // NOTIFICATION
  // CREATE
  Future<NotificationModel> createNotification(NotificationModel notif) async {
    final db = await instance.database;
    final id = await db.insert('notifications', notif.toMap());
    return notif.copyWith(id: id);
  }

// READ all notifs by todoId
  Future<List<NotificationModel>> readNotificationsByTodoId(int todoId) async {
    final db = await instance.database;
    final result = await db.query(
      'notifications',
      where: 'todoId = ?',
      whereArgs: [todoId],
    );
    return result.map((json) => NotificationModel.fromMap(json)).toList();
  }

// UPDATE isSent
  Future<int> updateNotification(NotificationModel notif) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      notif.toMap(),
      where: 'id = ?',
      whereArgs: [notif.id],
    );
  }

// DELETE satu notif
  Future<int> deleteNotification(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}

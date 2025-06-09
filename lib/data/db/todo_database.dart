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
      columns: ['id', 'title', 'category', 'deadline', 'description', 'isDone'],
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

  // Ambil semua todo dengan deadline pada tanggal tertentu (tanpa memperhatikan jam)
  Future<List<Todo>> readTodosByDate(DateTime date) async {
    final db = await instance.database;
    // Format tanggal ke yyyy-MM-dd
    final dateString = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.query(
      'todos',
      where: "date(deadline) = ?",
      whereArgs: [dateString],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => Todo.fromMap(json)).toList();
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

  // Hitung progress subtask dan update isDone jika semua selesai
  Future<double> getTodoProgress(int todoId) async {
    final subtasks = await readSubtasksByTodoId(todoId);
    if (subtasks.isEmpty) {
      // Tidak ada subtask, progress 0% atau 100% tergantung isDone
      final todo = await readTodo(todoId);
      if (todo != null && todo.isDone) return 1.0;
      return 0.0;
    }
    final doneCount = subtasks.where((s) => s.isDone).length;
    final progress = doneCount / subtasks.length;
    // Jika semua subtask selesai, update todo utama ke isDone=true
    if (doneCount == subtasks.length && subtasks.isNotEmpty) {
      final todo = await readTodo(todoId);
      if (todo != null && !todo.isDone) {
        await updateTodo(todo.copyWith(isDone: true));
      }
    }
    return progress;
  }

  // Update subtask dan cek apakah semua selesai, jika ya update todo utama
  Future<void> updateSubtaskAndCheckTodo(Subtask subtask) async {
    await updateSubtask(subtask);
    final subtasks = await readSubtasksByTodoId(subtask.todoId);
    final allDone = subtasks.isNotEmpty && subtasks.every((s) => s.isDone);
    if (allDone) {
      final todo = await readTodo(subtask.todoId);
      if (todo != null && !todo.isDone) {
        await updateTodo(todo.copyWith(isDone: true));
      }
    }
  }
}

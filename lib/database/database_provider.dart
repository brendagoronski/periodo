import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  // Construtor singleton
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  static Database? _database;

  // Getter para obter o banco de dados (ou abrir se ainda não estiver aberto)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializa o banco de dados e cria a tabela se não existir
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'historico.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE historico (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            tipo TEXT NOT NULL,
            fluxo TEXT,
            sintomas TEXT,
            coleta TEXT,
            relacao TEXT,
            anticoncepcional TEXT
          )
        ''');
      },
    );
  }
}

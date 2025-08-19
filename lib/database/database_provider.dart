import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Provedor de acesso ao banco SQLite da aplicação (padrão Singleton).
/// Responsável por abrir/criar a base e expor um `Database` reutilizável.
class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  // Construtor singleton
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  static Database? _database;

  /// Obtém a instância do banco (abrindo caso ainda não esteja aberta).
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Inicializa o banco de dados e cria tabelas necessárias na primeira execução.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mestruacao.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Criação da tabela 'historico' para registros de ações/eventos do app.
        await db.execute('''
          CREATE TABLE historico (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT NOT NULL,
            tipo TEXT NOT NULL,
            fluxo TEXT,
            sintomas TEXT,
            coleta TEXT,
            relacao TEXT,
            respostaAnticoncepcional TEXT
          );
        ''');
      },
    );
  }
}

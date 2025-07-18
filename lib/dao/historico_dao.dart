import '../model/historico_model.dart';
import '../database/database_provider.dart';

class HistoricoDao {
  final tableName = 'historico';

  // Inserção de um novo registro no banco
  Future<int> inserir(Historico historico) async {
    final db = await DatabaseProvider().database;
    return await db.insert(tableName, historico.toMap());
  }

  // Listar todos os registros do banco (ordenados por data descendente)
  Future<List<Historico>> listarTodos() async {
    final db = await DatabaseProvider().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'data DESC',
    );
    return List.generate(maps.length, (i) => Historico.fromMap(maps[i]));
  }

  // Atualizar um registro existente no banco
  Future<int> atualizar(Historico historico) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      tableName,
      historico.toMap(),
      where: 'id = ?',
      whereArgs: [historico.id],
    );
  }

  // Deletar um registro do banco por ID
  Future<int> deletar(int id) async {
    final db = await DatabaseProvider().database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}

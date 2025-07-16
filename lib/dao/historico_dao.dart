import '../model/historico_model.dart';
import '../database/database_provider.dart';

class HistoricoDao {
  final tableName = 'historico';

  Future<int> inserir(Historico historico) async {
    final db = await DatabaseProvider().database;
    return await db.insert(tableName, historico.toMap());
  }

  Future<List<Historico>> listarTodos() async {
    final db = await DatabaseProvider().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: 'data DESC');
    return List.generate(maps.length, (i) => Historico.fromMap(maps[i]));
  }

  Future<int> atualizar(Historico historico) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      tableName,
      historico.toMap(),
      where: 'id = ?',
      whereArgs: [historico.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 
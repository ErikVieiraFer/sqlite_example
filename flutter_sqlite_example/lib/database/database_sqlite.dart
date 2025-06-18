import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Define a classe DatabaseSqLite para encapsular a lógica de conexão com o banco de dados.
class DatabaseSqLite {
  // Uma instância estática e privada do banco de dados, para garantir que apenas uma conexão seja aberta.
  // O 'late' significa que a variável será inicializada antes de ser usada.
  static late Database _database;

  // Getter para a instância do banco de dados. Permite acesso ao objeto Database.
  static Database get database => _database;

  // Método assíncrono para abrir a conexão com o banco de dados.
  // Retorna um Future<void> pois a operação é assíncrona e não retorna um valor explícito.
  Future<void> openConnection() async {
    // Obtém o caminho padrão para os bancos de dados no dispositivo.
    // Este caminho é específico da plataforma (e.g., Android, iOS).
    final databasePath = await getDatabasesPath();

    // Combina o caminho do diretório com o nome do arquivo do banco de dados.
    // 'SQLITE_EXAMPLE' será o nome do arquivo .db (e.g., 'SQLITE_EXAMPLE.db').
    final databaseFinalPath = join(databasePath, 'SQLITE_EXAMPLE.db');

    // Abre (ou cria, se não existir) o banco de dados.
    // Esta é a função principal para interagir com o SQLite.
    _database = await openDatabase(
      databaseFinalPath, // Caminho completo do arquivo do banco de dados.
      version:
          2, // Versão do esquema do banco de dados. Importante para migrações.
      // onConfigure: Este callback é chamado quando a conexão é aberta.
      // É executado antes de onCreate, onUpgrade ou onDowngrade.
      onConfigure: (db) async {
        print('onConfigure sendo chamado');
        // Habilita o suporte a chaves estrangeiras no SQLite.
        // É crucial para garantir a integridade referencial dos dados.
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // onCreate: Este callback é chamado apenas uma vez, quando o banco de dados é criado pela primeira vez.
      // (Ou quando o arquivo .db não existe no caminho especificado).
      onCreate: (Database db, int version) async {
        final batch =
            db.batch(); // Cria um batch para agrupar múltiplas operações SQL.
        print('onCreate Chamado');

        // Adiciona a instrução SQL para criar a tabela 'teste' ao batch.
        // id: Chave primária, auto-incrementável.
        // nome: Campo de texto com limite de 200 caracteres.
        batch.execute('''
          CREATE TABLE teste(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR(200)
          )
        ''');

        // Adiciona a instrução SQL para criar a tabela 'product' ao batch.
        // id: Chave primária, auto-incrementável.
        // nome: Campo de texto com limite de 200 caracteres.
        batch.execute('''
          CREATE TABLE product(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome VARCHAR(200)
          )
        ''');

        // EXEMPLO DE COMO ADICIONAR UMA TERCEIRA TABELA NO FUTURO (versão 3, por exemplo)
        // batch.execute('''
        //   CREATE TABLE category(
        //     id INTEGER PRIMARY KEY AUTOINCREMENT,
        //     nome VARCHAR(200)
        //   )
        // ''');

        // Importante: Executa todas as operações SQL agrupadas no batch.
        // Se este commit faltar, as tabelas não serão criadas.
        await batch.commit();
        print('Tabelas criadas em onCreate.');
      },

      // onUpgrade: Este callback é chamado quando a versão do banco de dados é incrementada.
      // (e.g., de 1 para 2, ou de 2 para 3, etc.).
      // É usado para migrar o esquema do banco de dados (adicionar tabelas/colunas, modificar, etc.).
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        print(
          'onUpgrade Chamado: Old Version $oldVersion, New Version $newVersion',
        );
        final batch =
            db.batch(); // Cria um batch para agrupar operações de atualização.

        // Exemplo de migração: se a versão antiga era 1, e estamos atualizando para a versão 2,
        // garantimos que a tabela 'product' seja criada. (Isso é redundante se já foi criada em onCreate,
        // mas serve como exemplo de lógica de migração.)
        if (oldVersion == 1) {
          batch.execute('''
            CREATE TABLE product(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome VARCHAR(200)
            )
          ''');
          print('Tabela product criada em onUpgrade (de versão 1 para 2).');
        }

        // Exemplo de migração para uma versão futura (e.g., de 2 para 3).
        // Se a versão antiga era 2 (e a nova é 3), adicionaríamos a tabela 'category'.
        // if (oldVersion == 2) {
        //   batch.execute('''
        //     CREATE TABLE category(
        //       id INTEGER PRIMARY KEY AUTOINCREMENT,
        //       nome VARCHAR(200)
        //     )
        //   ''');
        //   print('Tabela category criada em onUpgrade (de versão 2 para 3).');
        // }

        // Executa todas as operações SQL agrupadas no batch de upgrade.
        await batch.commit();
      },

      // onDowngrade: Este callback é chamado quando a versão do banco de dados é decrementada.
      // (e.g., de 3 para 2). Isso geralmente não é recomendado em produção, mas útil para depuração.
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        print(
          'onDowngrade Chamado: Old Version $oldVersion, New Version $newVersion',
        );
        final batch =
            db.batch(); // Cria um batch para agrupar operações de downgrade.

        // Exemplo de downgrade: se a versão antiga era 3 (e a nova é 2),
        // removemos a tabela 'category' (assumindo que ela foi adicionada na versão 3).
        if (oldVersion == 3) {
          batch.execute(
            'DROP TABLE IF EXISTS category',
          ); // 'DROP TABLE IF EXISTS' evita erro se a tabela não existir.
          print(
            'Tabela category removida em onDowngrade (de versão 3 para 2).',
          );
        }

        // Executa todas as operações SQL agrupadas no batch de downgrade.
        await batch.commit();
      },

      // onOpen: Este callback é chamado depois que o banco de dados é aberto com sucesso,
      // após onCreate, onUpgrade ou onDowngrade, se aplicável.
      onOpen: (db) {
        print('onOpen Chamado: Banco de dados aberto com sucesso.');
      },
    );
  }
}

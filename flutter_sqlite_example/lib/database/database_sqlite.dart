import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSqLite {
  // Future<Database> openConnection() async {
  Future<void> openConnection() async {
    final databasePath = await getDatabasesPath();
    final databaseFinalPath = join(databasePath, 'SQLITE_EXAMPLE');

    await openDatabase(
      databaseFinalPath,
      version: 2,
      onConfigure: (db) async {
        print('onConfigure sendo chamado');
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // Chamado somente no momento de criação do banco de dados
      // primeira vez que carrega o aplicativo
      onCreate: (Database db, int version) {
        final batch = db.batch();
        print('onCreate Chamado');

        batch.execute('''
        create table teste(
          id Integer primary key autoincrement
          nome varchar(200)
        )
      ''');
        batch.execute('''
        create table product(
          id Integer primary key autoincrement
          nome varchar(200)
        )
      ''');
        //   batch.execute('''
        //   create table category(
        //     id Integer primary key autoincrement
        //     nome varchar(200)
        //   )
        // ''');
      },

      //Será chamado sempre que houver uma alteração no version incremental (1 -> 2)
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        print('onUpgrade Chamado');
        final batch = db.batch();
        if (oldVersion == 1) {
          batch.execute('''
        create table product(
          id Integer primary key autoincrement
          nome varchar(200)
        )
      ''');

          // batch.execute('''
          //   create table category(
          //     id Integer primary key autoincrement
          //     nome varchar(200)
          //   )
          // ''');
        }

        //   if (oldVersion == 2) {
        //     batch.execute('''
        //   create table category(
        //     id Integer primary key autoincrement
        //     nome varchar(200)
        //   )
        // ''');
        //   }

        batch.commit();
      },

      //Será chamado sempre que houver uma alteração no version decremental (2 -> 1)
      onDowngrade: (Database db, int oldVersion, int newVersion) {
        print('onDowngrade Chamado');
        final batch = db.batch();
        if (oldVersion == 3) {
          batch.execute('''
          drop table category;          
          ''');
        }
        batch.commit();
      },
    );
  }
}

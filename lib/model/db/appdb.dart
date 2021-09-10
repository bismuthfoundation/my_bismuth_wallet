// @dart=2.9

import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:my_bismuth_wallet/model/db/account.dart';
import 'package:my_bismuth_wallet/model/db/contact.dart';
import 'package:my_bismuth_wallet/util/app_ffi/apputil.dart';

class DBHelper {
  static const int DB_VERSION = 4;
  static const String CONTACTS_SQL = """CREATE TABLE Contacts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        address TEXT)""";
  static const String ACCOUNTS_SQL = """CREATE TABLE Accounts( 
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        acct_index INTEGER, 
        selected INTEGER, 
        last_accessed INTEGER,
        private_key TEXT,
        address TEXT,
        balance TEXT,
        dragginatorDna TEXT,
        dragginatorStatus TEXT)""";
  static Database _db;

  static const String ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL_DRAGGINATOR_DNA = """
    ALTER TABLE Accounts ADD dragginatorDna TEXT
    """;

  static const String ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL_DRAGGINATOR_STATUS = """
    ALTER TABLE Accounts ADD dragginatorStatus TEXT
    """;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "bismuth.db");
    var theDb = await openDatabase(path,
        version: DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(CONTACTS_SQL);
    await db.execute(ACCOUNTS_SQL);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL_DRAGGINATOR_DNA);
      await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL_DRAGGINATOR_STATUS);
    } else {
      if (oldVersion == 2 || oldVersion == 3) {
        await db.execute(ACCOUNTS_ADD_ACCOUNT_COLUMN_SQL_DRAGGINATOR_STATUS);
      }
    }
  }

  // Contacts
  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Contacts ORDER BY name');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
        id: list[i]['id'],
        name: list[i]['name'],
        address: list[i]['address'],
      ));
    }
    return contacts;
  }

  Future<List<Contact>> getContactsWithNameLike(String pattern) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Contacts WHERE name LIKE \'%$pattern%\' ORDER BY LOWER(name)');
    List<Contact> contacts = new List();
    for (int i = 0; i < list.length; i++) {
      contacts.add(new Contact(
        id: list[i]['id'],
        name: list[i]['name'],
        address: list[i]['address'],
      ));
    }
    return contacts;
  }

  Future<Contact> getContactWithAddress(String address) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Contacts WHERE address like \'%$address\'');
    if (list.length > 0) {
      return Contact(
        id: list[0]['id'],
        name: list[0]['name'],
        address: list[0]['address'],
      );
    }
    return null;
  }

  Future<Contact> getContactWithName(String name) async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Contacts WHERE name = ?', [name]);
    if (list.length > 0) {
      return Contact(
        id: list[0]['id'],
        name: list[0]['name'],
        address: list[0]['address'],
      );
    }
    return null;
  }

  Future<bool> contactExistsWithName(String name) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Contacts WHERE lower(name) = ?',
        [name.toLowerCase()]));
    return count > 0;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    var dbClient = await db;
    int count = Sqflite.firstIntValue(await dbClient.rawQuery(
        'SELECT count(*) FROM Contacts WHERE lower(address) like \'%$address\''));
    return count > 0;
  }

  Future<int> saveContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawInsert(
        'INSERT INTO Contacts (name, address) values(?, ?)',
        [contact.name, contact.address]);
  }

  Future<int> saveContacts(List<Contact> contacts) async {
    int count = 0;
    for (Contact c in contacts) {
      if (await saveContact(c) > 0) {
        count++;
      }
    }
    return count;
  }

  Future<bool> deleteContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
            "DELETE FROM Contacts WHERE lower(address) like \'%${contact.address.toLowerCase()}\'") >
        0;
  }

  // Accounts
  Future<List<Account>> getAccounts(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts ORDER BY acct_index');
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]['id'],
          name: list[i]['name'],
          index: list[i]['acct_index'],
          lastAccess: list[i]['last_accessed'],
          selected: list[i]['selected'] == 1 ? true : false,
          balance: list[i]['balance'],
          dragginatorDna: list[i]['dragginatorDna'],
          dragginatorStatus: list[i]['dragginatorStatus']));
    }
    accounts.forEach((a) {
      a.address = AppUtil().seedToAddress(seed, a.index);
    });
    return accounts;
  }

  Future<List<Account>> getRecentlyUsedAccounts(String seed,
      {int limit = 2}) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM Accounts WHERE selected != 1 ORDER BY last_accessed DESC, acct_index ASC LIMIT ?',
        [limit]);
    List<Account> accounts = new List();
    for (int i = 0; i < list.length; i++) {
      accounts.add(Account(
          id: list[i]['id'],
          name: list[i]['name'],
          index: list[i]['acct_index'],
          lastAccess: list[i]['last_accessed'],
          selected: list[i]['selected'] == 1 ? true : false,
          balance: list[i]['balance'],
          dragginatorDna: list[i]['dragginatorDna'],
          dragginatorStatus: list[i]['dragginatorStatus']));
    }
    accounts.forEach((a) async {
      a.address = AppUtil().seedToAddress(seed, a.index);
    });
    return accounts;
  }

  Future<Account> addAccount(String seed, {String nameBuilder}) async {
    var dbClient = await db;
    Account account;
    await dbClient.transaction((Transaction txn) async {
      int nextIndex = 1;
      int curIndex;
      List<Map> accounts = await txn.rawQuery(
          'SELECT * from Accounts WHERE acct_index > 0 ORDER BY acct_index ASC');
      for (int i = 0; i < accounts.length; i++) {
        curIndex = accounts[i]['acct_index'];
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
      int nextID = nextIndex + 1;
      String nextName = nameBuilder.replaceAll("%1", nextID.toString());
      account = Account(
          index: nextIndex,
          name: nextName,
          lastAccess: 0,
          balance: "0",
          selected: false,
          address: AppUtil().seedToAddress(seed, nextIndex),
          dragginatorDna: "",
          dragginatorStatus: "");
      await txn.rawInsert(
          'INSERT INTO Accounts (name, acct_index, last_accessed, selected, address, balance, dragginatorDna, dragginatorStatus) values(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            account.name,
            account.index,
            account.lastAccess,
            account.selected ? 1 : 0,
            account.address,
            account.balance,
            account.dragginatorDna,
            account.dragginatorStatus
          ]);
    });
    return account;
  }

  Future<int> deleteAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawDelete(
        'DELETE FROM Accounts WHERE acct_index = ?', [account.index]);
  }

  Future<int> saveAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.rawInsert(
        'INSERT INTO Accounts (name, acct_index, last_accessed, selected, balance, dragginatorDna, dragginatorStatus) values(?, ?, ?, ?, ?, ?, ?)',
        [
          account.name,
          account.index,
          account.lastAccess,
          account.selected ? 1 : 0,
          account.balance,
          account.dragginatorDna,
          account.dragginatorStatus
        ]);
  }

  Future<int> changeAccountName(Account account, String name) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Accounts SET name = ? WHERE acct_index = ?',
        [name, account.index]);
  }

  Future<int> changeAccountDragginatorDna(
      Account account, String dna, String status) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Accounts SET dragginatorDna = ?, dragginatorStatus = ? WHERE acct_index = ?',
        [dna, status, account.index]);
  }

  Future<void> changeAccount(Account account) async {
    var dbClient = await db;
    return await dbClient.transaction((Transaction txn) async {
      await txn.rawUpdate('UPDATE Accounts set selected = 0');
      // Get access increment count
      List<Map> list = await txn
          .rawQuery('SELECT max(last_accessed) as last_access FROM Accounts');
      await txn.rawUpdate(
          'UPDATE Accounts set selected = ?, last_accessed = ? where acct_index = ?',
          [1, list[0]['last_access'] + 1, account.index]);
    });
  }

  Future<void> updateAccountBalance(Account account, String balance) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE Accounts set balance = ? where acct_index = ?',
        [balance, account.index]);
  }

  Future<Account> getSelectedAccount(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts where selected = 1');
    if (list.length == 0) {
      return null;
    }
    Account account = Account(
        id: list[0]['id'],
        name: list[0]['name'],
        index: list[0]['acct_index'],
        selected: true,
        lastAccess: list[0]['last_accessed'],
        balance: list[0]['balance'],
        address: AppUtil().seedToAddress(seed, list[0]['acct_index']),
        dragginatorDna: list[0]['dragginatorDna'],
        dragginatorStatus: list[0]['dragginatorStatus']);
    return account;
  }

  Future<Account> getMainAccount(String seed) async {
    var dbClient = await db;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM Accounts where acct_index = 0');
    if (list.length == 0) {
      return null;
    }
    String address = AppUtil().seedToAddress(seed, list[0]['acct_index']);

    Account account = Account(
        id: list[0]['id'],
        name: list[0]['name'],
        index: list[0]['acct_index'],
        selected: true,
        lastAccess: list[0]['last_accessed'],
        balance: list[0]['balance'],
        address: address,
        dragginatorDna: list[0]['dragginatorDna'],
        dragginatorStatus: list[0]['dragginatorStatus']);
    return account;
  }

  Future<void> dropAccounts() async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM ACCOUNTS');
  }
}

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/util/app_ffi/apputil.dart';

class DBHelper {
  static const String _contactsTable = 'contacts';
  static const String _accountsTable = 'accounts';

  static Future<void> setupDatabase() async {
    if (!kIsWeb) {
      await Hive.initFlutter();
    }
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(AccountAdapter());
  }

  // Contacts
  Future<List<Contact>> getContacts() async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();
    return contactsList;
  }

  Future<List<Contact>> getContactsWithNameLike(String pattern) async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();
    // ignore: prefer_final_locals
    List<Contact> contactsListSelected = List<Contact>.empty(growable: true);
    for (Contact _contact in contactsList) {
      if (_contact.name!.contains(pattern)) {
        contactsListSelected.add(_contact);
      }
    }
    return contactsListSelected;
  }

  Future<Contact> getContactWithAddress(String address) async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();

    Contact? contactSelected;
    for (Contact _contact in contactsList) {
      if (_contact.address!.toLowerCase().contains(address.toLowerCase())) {
        contactSelected = _contact;
      }
    }
    if (contactSelected == null) {
      throw Exception();
    } else {
      return contactSelected;
    }
  }

  Future<Contact> getContactWithName(String name) async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();
    Contact? contactSelected;
    for (Contact _contact in contactsList) {
      if (_contact.name!.toLowerCase() == name.toLowerCase()) {
        contactSelected = _contact;
      }
    }
    if (contactSelected == null) {
      throw Exception();
    } else {
      return contactSelected;
    }
  }

  Future<bool> contactExistsWithName(String name) async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();
    bool contactExists = false;
    for (Contact _contact in contactsList) {
      if (_contact.name!.toLowerCase() == name.toLowerCase()) {
        contactExists = true;
      }
    }
    return contactExists;
  }

  Future<bool> contactExistsWithAddress(String address) async {
    final Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    final List<Contact> contactsList = box.values.toList();
    bool contactExists = false;
    for (Contact _contact in contactsList) {
      if (_contact.address!.toLowerCase().contains(address.toLowerCase())) {
        contactExists = true;
      }
    }
    return contactExists;
  }

  Future<void> saveContact(Contact contact) async {
    // ignore: prefer_final_locals
    Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    box.put(contact.address, contact);
  }

  Future<void> deleteContact(Contact contact) async {
    // ignore: prefer_final_locals
    Box<Contact> box = await Hive.openBox<Contact>(_contactsTable);
    box.delete(contact.address);
  }

  // Accounts
  Future<List<Account>> getAccounts(String seed) async {
    final Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accounts = box.values.toList();
    accounts.forEach((a) {
      a.address = AppUtil().seedToAddress(seed, a.index);
    });
    return accounts;
  }

  Future<List<Account>> getRecentlyUsedAccounts(String seed,
      {int limit = 2}) async {
    final Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accounts = box.values.toList();
    accounts
        .sort((Account a, Account b) => a.lastAccess!.compareTo(b.lastAccess!));

    for (int i = 0; i < accounts.length; i++) {
      accounts[i].address = AppUtil().seedToAddress(seed, accounts[i].index);
      if (i + 1 == limit) {
        break;
      }
    }

    return accounts;
  }

  Future<Account> addAccount(String seed, {String? nameBuilder}) async {
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accountsList = box.values.toList();
    accountsList.sort((Account a, Account b) => a.index!.compareTo(b.index!));
    int nextIndex = 1;
    int curIndex;
    for (Account _account in accountsList) {
      if (_account.index != null && _account.index! > 0) {
        curIndex = _account.index!;
        if (curIndex != nextIndex) {
          break;
        }
        nextIndex++;
      }
    }
    int nextID = nextIndex + 1;
    String nextName = nameBuilder!.replaceAll("%1", nextID.toString());

    Account account = new Account();
    account.index = nextIndex;
    account.name = nextName;
    account.lastAccess = 0;
    account.balance = "0";
    account.selected = false;
    account.address = AppUtil().seedToAddress(seed, nextIndex);
    account.dragginatorDna = "";
    account.dragginatorStatus = "";
    box.put(account.index, account);
    return account;
  }

  Future<void> deleteAccount(Account account) async {
    // ignore: prefer_final_locals
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    box.delete(account.index);
  }

  // Accounts
  Future<void> saveAccount(Account account) async {
    // ignore: prefer_final_locals
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    box.put(account.index, account);
  }

  Future<void> changeAccountName(Account account, String name) async {
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    account.name = name;
    box.putAt(account.index!, account);
  }

  Future<void> changeAccountDragginatorDna(
      Account account, String dna, String status) async {
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    account.dragginatorDna = dna;
    account.dragginatorStatus = status;
    box.putAt(account.index!, account);
  }

  Future<void> changeAccount(Account account) async {
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accountsList = box.values.toList();
    int maxLastAccessed = 0;
    for (Account _account in accountsList) {
      _account.selected = false;
      box.putAt(_account.index!, _account);
      if (_account.lastAccess != null &&
          maxLastAccessed < _account.lastAccess!) {
        maxLastAccessed = _account.lastAccess!;
      }
    }
    account.selected = true;
    account.lastAccess = maxLastAccessed + 1;
    box.putAt(account.index!, account);
  }

  Future<void> updateAccountBalance(Account account, String balance) async {
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    account.balance = balance;
    box.putAt(account.index!, account);
  }

  Future<Account?> getSelectedAccount(String seed) async {
    final Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accountsList = box.values.toList();
    Account? accountSelected;
    for (Account _account in accountsList) {
      if (_account.selected!) {
        accountSelected = _account;
        accountSelected.address =
            AppUtil().seedToAddress(seed, accountSelected.index);
      }
    }
    return accountSelected;
  }

  Future<Account> getMainAccount(String seed) async {
    final Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    final List<Account> accountsList = box.values.toList();
    Account? account;
    for (Account _account in accountsList) {
      if (_account.index! == 0) {
        _account.address = AppUtil().seedToAddress(seed, _account.index);
        _account.selected = true;
        account = _account;
        break;
      }
    }
    return account!;
  }

  Future<void> dropAccounts() async {
    // ignore: prefer_final_locals
    Box<Account> box = await Hive.openBox<Account>(_accountsTable);
    box.clear();
  }

  Future<void> dropAll() async {
    // ignore: prefer_final_locals
    Box<Account> boxAccounts = await Hive.openBox<Account>(_accountsTable);
    // ignore: prefer_final_locals
    Box<Contact> boxContacts = await Hive.openBox<Contact>(_contactsTable);
    boxAccounts.clear();
    boxContacts.clear();
  }
}

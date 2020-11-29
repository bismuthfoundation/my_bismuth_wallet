import 'dart:async';

import 'package:hex/hex.dart';
import 'package:logger/logger.dart';
import 'package:my_idena_wallet/model/wallet.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_idena_wallet/network/model/response/address_response.dart';
import 'package:my_idena_wallet/network/model/response/address_txs_response.dart';
import 'package:my_idena_wallet/service/app_service.dart';
import 'package:my_idena_wallet/util/app_ffi/encrypt/crypter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:my_idena_wallet/themes.dart';
import 'package:my_idena_wallet/service_locator.dart';
import 'package:my_idena_wallet/model/available_currency.dart';
import 'package:my_idena_wallet/model/available_language.dart';
import 'package:my_idena_wallet/model/address.dart';
import 'package:my_idena_wallet/model/vault.dart';
import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/db/account.dart';
import 'package:my_idena_wallet/util/sharedprefsutil.dart';
import 'package:my_idena_wallet/util/app_ffi/apputil.dart';
import 'package:my_idena_wallet/bus/events.dart';

import 'util/sharedprefsutil.dart';

class _InheritedStateContainer extends InheritedWidget {
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // You must pass through a child and your state.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  // You must pass through a child.
  final Widget child;

  StateContainer({@required this.child});

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        .data;
  }

  @override
  StateContainerState createState() => StateContainerState();
}

/// App InheritedWidget
/// This is where we handle the global state and also where
/// we interact with the server and make requests/handle+propagate responses
///
/// Basically the central hub behind the entire app
class StateContainerState extends State<StateContainer> {
  final Logger log = sl.get<Logger>();

  // Minimum receive = 0.000001
  String receiveThreshold = BigInt.from(10).pow(24).toString();

  AppWallet wallet;
  String currencyLocale;
  Locale deviceLocale = Locale('en', 'US');
  AvailableCurrency curCurrency = AvailableCurrency(AvailableCurrencyEnum.USD);
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  BaseTheme curTheme = IdenaTheme();
  // Currently selected account
  Account selectedAccount =
      Account(id: 1, name: "AB", index: 0, lastAccess: 0, selected: true);
  // Two most recently used accounts
  Account recentLast;
  Account recentSecondLast;

  // Initial deep link
  String initialDeepLink;
  // Deep link changes
  StreamSubscription _deepLinkSub;

  // When wallet is encrypted
  String encryptedSecret;

  @override
  void initState() {
    super.initState();
    // Register RxBus
    _registerBus();
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Get default language setting
    sl.get<SharedPrefsUtil>().getLanguage().then((language) {
      setState(() {
        curLanguage = language;
      });
    });
    // Get initial deep link
    getInitialLink().then((initialLink) {
      setState(() {
        initialDeepLink = initialLink;
      });
    });
  }

  // Subscriptions
  StreamSubscription<SubscribeEvent> _subscribeEventSub;
  StreamSubscription<PriceEvent> _priceEventSub;
  StreamSubscription<AccountModifiedEvent> _accountModifiedSub;

  // Register RX event listeners
  void _registerBus() {
    _subscribeEventSub =
        EventTaxiImpl.singleton().registerTo<SubscribeEvent>().listen((event) {
      handleAddressResponse(event.response);
    });
    _priceEventSub =
        EventTaxiImpl.singleton().registerTo<PriceEvent>().listen((event) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      setState(() {
        wallet.btcPrice = event.response.btcPrice.toString();
        wallet.localCurrencyPrice =
            event.response.localCurrencyPrice.toString();
      });
    });

    // Account has been deleted or name changed
    _accountModifiedSub = EventTaxiImpl.singleton()
        .registerTo<AccountModifiedEvent>()
        .listen((event) {
      if (!event.deleted) {
        if (event.account.index == selectedAccount.index) {
          setState(() {
            selectedAccount.name = event.account.name;
          });
        } else {
          updateRecentlyUsedAccounts();
        }
      } else {
        // Remove account
        updateRecentlyUsedAccounts().then((_) {
          if (event.account.index == selectedAccount.index &&
              recentLast != null) {
            sl.get<DBHelper>().changeAccount(recentLast);
            setState(() {
              selectedAccount = recentLast;
            });
            EventTaxiImpl.singleton()
                .fire(AccountChangedEvent(account: recentLast, noPop: true));
          } else if (event.account.index == selectedAccount.index &&
              recentSecondLast != null) {
            sl.get<DBHelper>().changeAccount(recentSecondLast);
            setState(() {
              selectedAccount = recentSecondLast;
            });
            EventTaxiImpl.singleton().fire(
                AccountChangedEvent(account: recentSecondLast, noPop: true));
          } else if (event.account.index == selectedAccount.index) {
            getSeed().then((seed) {
              sl.get<DBHelper>().getMainAccount(seed).then((mainAccount) {
                sl.get<DBHelper>().changeAccount(mainAccount);
                setState(() {
                  selectedAccount = mainAccount;
                });
                EventTaxiImpl.singleton().fire(
                    AccountChangedEvent(account: mainAccount, noPop: true));
              });
            });
          }
        });
        updateRecentlyUsedAccounts();
      }
    });
    // Deep link has been updated
    _deepLinkSub = getLinksStream().listen((String link) {
      setState(() {
        initialDeepLink = link;
      });
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _destroyBus() {
    if (_subscribeEventSub != null) {
      _subscribeEventSub.cancel();
    }
    if (_priceEventSub != null) {
      _priceEventSub.cancel();
    }
    if (_accountModifiedSub != null) {
      _accountModifiedSub.cancel();
    }
    if (_deepLinkSub != null) {
      _deepLinkSub.cancel();
    }
  }

  // Update the global wallet instance with a new address
  Future<void> updateWallet({Account account}) async {
    String address;
    address = await IdenaUtil().seedToAddress(await getSeed(), account.index);
    AppService().getAddressResponse(address.toString());
    AppService().getSimplePrice(curCurrency.getIso4217Code());
    account.address = address;
    selectedAccount = account;
    updateRecentlyUsedAccounts();
    setState(() {
      wallet = AppWallet(address: address, loading: true);
      requestUpdate();
    });
  }

  Future<void> updateRecentlyUsedAccounts() async {
    List<Account> otherAccounts =
        await sl.get<DBHelper>().getRecentlyUsedAccounts(await getSeed());
    if (otherAccounts != null && otherAccounts.length > 0) {
      if (otherAccounts.length > 1) {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = otherAccounts[1];
        });
      } else {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = null;
        });
      }
    } else {
      setState(() {
        recentLast = null;
        recentSecondLast = null;
      });
    }
  }

  // Change language
  void updateLanguage(LanguageSetting language) {
    setState(() {
      curLanguage = language;
    });
  }

  // Change curency
  void updateCurrency(AvailableCurrency currency) {
    setState(() {
      AppService().getSimplePrice(currency.getIso4217Code());
      curCurrency = currency;
    });
  }

  // Set encrypted secret
  void setEncryptedSecret(String secret) {
    setState(() {
      encryptedSecret = secret;
    });
  }

  // Reset encrypted secret
  void resetEncryptedSecret() {
    setState(() {
      encryptedSecret = null;
    });
  }

  /// Handle address response
  void handleAddressResponse(AddressResponse response) {
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    setState(() {
      wallet.loading = false;
      if (response.result == null) {
        wallet.accountBalance = 0;
      } else {
        wallet.accountBalance =
            double.tryParse(response.result.balance + response.result.stake);
      }
      // TODO : à renseigner
      wallet.localCurrencyPrice = "0";
      wallet.btcPrice = "0";
      //wallet.localCurrencyPrice = response.price.toString();
      //wallet.btcPrice = response.btcPrice.toString();
    });
  }

  /// Request balances for accounts in our database
  Future<void> _requestBalances() async {
    List<Account> accounts =
        await sl.get<DBHelper>().getAccounts(await getSeed());
    List<String> addressToRequest = List();
    List<AddressResponse> addressResponseList = new List();
    accounts.forEach((account) async {
      if (account.address != null) {
        addressToRequest.add(account.address);
        addressResponseList
            .add(await AppService().getAddressResponse(account.address));
      }
    });

    sl.get<DBHelper>().getAccounts(await getSeed()).then((accounts) {
      accounts.forEach((account) {
        addressResponseList.forEach((address) {
          String combinedBalance = (BigInt.tryParse(address.result.balance) +
                  BigInt.tryParse(address.result.stake))
              .toString();
          if (account.address == address.result.address &&
              combinedBalance != account.balance) {
            sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          }
        });
      });
    });
  }

  Future<void> requestUpdate({bool pending = true}) async {
    if (wallet != null &&
        wallet.address != null &&
        Address(wallet.address).isValid()) {
      // Request account history
      int count = 30;
      if (wallet.history != null && wallet.history.length > 1) {
        count = 30;
      }
      try {
        AddressTxsResponse addressTxsResponse =
            await AppService().getAddressTxsResponse(wallet.address, count);

        _requestBalances();
        bool postedToHome = false;
        // Iterate list in reverse (oldest to newest block)
        if (addressTxsResponse != null && addressTxsResponse.result != null) {
          for (AddressTxsResponseResult item in addressTxsResponse.result) {
            // If current list doesn't contain this item, insert it and the rest of the items in list and exit loop
            bool newItem = false;
            for(int i=0; i < wallet.history.length; i++)
            {
              if(wallet.history[i].timestamp != item.timestamp 
              || wallet.history[i].hash != item.hash)
              {
                newItem = true;
                break;
              }
            }

            if (newItem) {
              int startIndex = 0; // Index to start inserting into the list
              int lastIndex = addressTxsResponse.result.indexWhere((item) =>
                  wallet.history.contains(
                      item)); // Last index of historyResponse to insert to (first index where item exists in wallet history)
              lastIndex =
                  lastIndex <= 0 ? addressTxsResponse.result.length : lastIndex;
              setState(() {
                wallet.history.insertAll(0,
                    addressTxsResponse.result.getRange(startIndex, lastIndex));
                // Send list to home screen
                EventTaxiImpl.singleton()
                    .fire(HistoryHomeEvent(items: wallet.history));
              });
              postedToHome = true;
              break;
            }
          }
        }

        setState(() {
          wallet.historyLoading = false;
        });
        if (!postedToHome) {
          EventTaxiImpl.singleton()
              .fire(HistoryHomeEvent(items: wallet.history));
        }
      } catch (e) {
        // TODO handle account history error
        sl.get<Logger>().e("account_history e", e);
      }
    }
  }

  void logOut() {
    setState(() {
      wallet = AppWallet();
      encryptedSecret = null;
    });
    sl.get<DBHelper>().dropAccounts();
  }

  Future<String> getSeed() async {
    String seed;
    if (encryptedSecret != null) {
      seed = HEX.encode(IdenaCrypt.decrypt(
          encryptedSecret, await sl.get<Vault>().getSessionKey()));
    } else {
      seed = await sl.get<Vault>().getSeed();
    }
    return seed;
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

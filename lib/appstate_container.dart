
// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:event_taxi/event_taxi.dart';
import 'package:hex/hex.dart';
import 'package:logger/logger.dart';
import 'package:uni_links/uni_links.dart';

// Project imports:
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/model/available_currency.dart';
import 'package:my_bismuth_wallet/model/available_language.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/model/vault.dart';
import 'package:my_bismuth_wallet/model/wallet.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';
import 'package:my_bismuth_wallet/service/http_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/themes.dart';
import 'package:my_bismuth_wallet/util/app_ffi/apputil.dart';
import 'package:my_bismuth_wallet/util/app_ffi/encrypt/crypter.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class _InheritedStateContainer extends InheritedWidget {
  // Data is your entire state. In our case just 'User'
  final StateContainerState data;

  // You must pass through a child and your state.
  _InheritedStateContainer({
    super.key,
    required this.data,
    required Widget child,
  }) : super(child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
  // You must pass through a child.
  final Widget child;

  const StateContainer({super.key, required this.child});

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()!
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
  // Minimum receive = 0.000001
  String receiveThreshold = BigInt.from(10).pow(24).toString();

  AppWallet wallet = AppWallet();
  String currencyLocale = 'en_US';
  Locale deviceLocale = Locale('en', 'US');
  AvailableCurrency curCurrency = AvailableCurrency(AvailableCurrencyEnum.USD);
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  BaseTheme curTheme = BismuthTheme();
  // Currently selected account
  Account selectedAccount =
      Account(name: "AB", index: 0, lastAccess: 0, selected: true);
  // Two most recently used accounts
  Account? recentLast;
  Account? recentSecondLast;

  // Initial deep link
  String? initialDeepLink;
  // Deep link changes
  StreamSubscription<String?>? _deepLinkSub;

  // When wallet is encrypted
  String? encryptedSecret;

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
    if (_supportsDeepLinks) {
      // Get initial deep link
      getInitialLink().then((initialLink) {
        setState(() {
          initialDeepLink = initialLink;
        });
      });
    }
  }

  // Subscriptions
  late final StreamSubscription<BalanceGetEvent> _balanceGetEventSub;
  late final StreamSubscription<PriceEvent> _priceEventSub;
  late final StreamSubscription<AccountModifiedEvent> _accountModifiedSub;
  late final StreamSubscription<TransactionsListEvent> _transactionsListEventSub;

  bool get _supportsDeepLinks {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Register RX event listeners
  void _registerBus() {
    _balanceGetEventSub =
        EventTaxiImpl.singleton().registerTo<BalanceGetEvent>().listen((event) {
      //print("listen BalanceGetEvent");
      handleAddressResponse(event.response);
    });

    _transactionsListEventSub = EventTaxiImpl.singleton()
        .registerTo<TransactionsListEvent>()
        .listen((event) {
      //print("listen TransactionsListEvent");
      final AddressTxsResponse addressTxsResponse = AddressTxsResponse(
        result: <AddressTxsResponseResult>[],
      );
      final responses = event.response ?? <List<dynamic>>[];
      for (int i = responses.length - 1; i >= 0; i--) {
        final AddressTxsResponseResult addressTxResponseResult =
            AddressTxsResponseResult();
        addressTxResponseResult.populate(
            responses[i], selectedAccount.address ?? '');
        addressTxResponseResult.getBisToken();
        addressTxsResponse.result!.add(addressTxResponseResult);
      }

      wallet.history.clear();

      // Iterate list in reverse (oldest to newest block)
      for (final AddressTxsResponseResult item in addressTxsResponse.result!) {
        setState(() {
          wallet.history.insert(0, item);
        });
      }
    
      setState(() {
        wallet.historyLoading = false;
        wallet.loading = false;
      });

      EventTaxiImpl.singleton().fire(HistoryHomeEvent(items: wallet.history));
    });

    _priceEventSub =
        EventTaxiImpl.singleton().registerTo<PriceEvent>().listen((event) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      setState(() {
        wallet.btcPrice = event.response?.btcPrice?.toString() ?? '0';
        wallet.localCurrencyPrice =
            event.response?.localCurrencyPrice?.toString() ?? '0';
      });
    });

    // Account has been deleted or name changed
    _accountModifiedSub = EventTaxiImpl.singleton()
        .registerTo<AccountModifiedEvent>()
        .listen((event) {
      final account = event.account;
      if (account == null) {
        return;
      }
      if (!event.deleted) {
        if (account.index == selectedAccount.index) {
          setState(() {
            selectedAccount.name = account.name;
          });
        } else {
          updateRecentlyUsedAccounts();
        }
      } else {
        // Remove account
        updateRecentlyUsedAccounts().then((_) {
          if (account.index == selectedAccount.index && recentLast != null) {
            final Account recent = recentLast!;
            sl.get<DBHelper>().changeAccount(recent);
            setState(() {
              selectedAccount = recent;
            });
            EventTaxiImpl.singleton()
                .fire(AccountChangedEvent(account: recent, noPop: true));
          } else if (account.index == selectedAccount.index &&
              recentSecondLast != null) {
            final Account recent = recentSecondLast!;
            sl.get<DBHelper>().changeAccount(recent);
            setState(() {
              selectedAccount = recent;
            });
            EventTaxiImpl.singleton().fire(
                AccountChangedEvent(account: recent, noPop: true));
          } else if (account.index == selectedAccount.index) {
            getSeed().then((seed) {
              sl.get<DBHelper>().getMainAccount(seed).then((mainAccount) {
                if (mainAccount == null) {
                  return;
                }
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
    if (_supportsDeepLinks) {
      _deepLinkSub = linkStream.listen((String? link) {
        setState(() {
          initialDeepLink = link;
        });
      });
    }
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _destroyBus() {
    _balanceGetEventSub.cancel();
    _priceEventSub.cancel();
    _accountModifiedSub.cancel();
    _deepLinkSub?.cancel();
    _transactionsListEventSub.cancel();
  }

  // Update the global wallet instance with a new address
  Future<void> updateWallet({required Account account}) async {
    //print("updateWallet");
    final String address =
        AppUtil().seedToAddress(await getSeed(), account.index ?? 0);
    account.address = address;
    selectedAccount = account;
    updateRecentlyUsedAccounts();

    setState(() {
      wallet = AppWallet(address: address, loading: true);
      requestUpdate();
    });
  }

  Future<void> updateRecentlyUsedAccounts() async {
    final List<Account> otherAccounts =
        await sl.get<DBHelper>().getRecentlyUsedAccounts(await getSeed());
    if (otherAccounts.length > 0) {
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
  void updateCurrency(AvailableCurrency currency) async {
    await sl.get<HttpService>().getSimplePrice(currency.getIso4217Code());
    setState(() {
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
  void handleAddressResponse(BalanceGetResponse? response) {
    if (response == null) {
      return;
    }
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    setState(() {
      wallet.accountBalance = double.tryParse(response.balance ?? '0') ?? 0;
      sl.get<DBHelper>().updateAccountBalance(
          selectedAccount, wallet.accountBalance.toString());
    });
  }

  Future<void> requestUpdate() async {
    //print("requestUpdate");
    if (Address(wallet.address).isValid()) {
      // Request account history
      int count = 30;
      try {
        sl
            .get<AppService>()
            .getBalanceGetResponse(selectedAccount.address ?? '', true);

        await sl
            .get<HttpService>()
            .getSimplePrice(curCurrency.getIso4217Code());

        sl.get<AppService>().getAddressTxsResponse(wallet.address, count);

        //sl.get<AppService>().getAlias(wallet.address);

        final AddressTxsResponse addressTxsResponse = AddressTxsResponse();
        addressTxsResponse.tokens = await sl
            .get<HttpService>()
            .getTokensBalance(selectedAccount.address ?? '');
        setState(() {
          wallet.tokens.clear();
          wallet.tokens
              .add(BisToken(tokenName: "", tokensQuantity: 0, tokenMessage: ""));
          wallet.tokens.addAll(addressTxsResponse.tokens ?? <BisToken>[]);
        });
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
    return HEX.encode(AppCrypt.decrypt(
        encryptedSecret!, await sl.get<Vault>().getSessionKey()));
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

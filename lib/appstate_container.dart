import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:my_idena_wallet/model/wallet.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_idena_wallet/network/model/response/accounts_balances_response.dart';
import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/encrypt/crypter.dart';
import 'package:my_idena_wallet/util/idena_ffi/keys/keys.dart';
import 'package:uni_links/uni_links.dart';
import 'package:my_idena_wallet/themes.dart';
import 'package:my_idena_wallet/service_locator.dart';
import 'package:my_idena_wallet/model/available_currency.dart';
import 'package:my_idena_wallet/model/available_language.dart';
import 'package:my_idena_wallet/model/address.dart';
import 'package:my_idena_wallet/model/vault.dart';
import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/db/account.dart';
import 'package:my_idena_wallet/network/model/block_types.dart';
import 'package:my_idena_wallet/network/model/request/account_history_request.dart';
import 'package:my_idena_wallet/network/model/request/subscribe_request.dart';
import 'package:my_idena_wallet/network/model/response/account_history_response.dart';
import 'package:my_idena_wallet/network/model/response/account_history_response_item.dart';
import 'package:my_idena_wallet/network/model/response/callback_response.dart';
import 'package:my_idena_wallet/network/model/response/error_response.dart';
import 'package:my_idena_wallet/network/model/response/subscribe_response.dart';
import 'package:my_idena_wallet/network/model/response/process_response.dart';
import 'package:my_idena_wallet/network/model/response/pending_response.dart';
import 'package:my_idena_wallet/network/model/response/pending_response_item.dart';
import 'package:my_idena_wallet/util/sharedprefsutil.dart';
import 'package:my_idena_wallet/util/idena_ffi/idenautil.dart';
import 'package:my_idena_wallet/network/account_service.dart';
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

  // Minimum receive = 0.000001 iDNA
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

  Map<String, String> natriconNonce = Map<String, String>();

  // If callback is locked
  bool _locked = false;

  // Initial deep link
  String initialDeepLink;
  // Deep link changes
  StreamSubscription _deepLinkSub;

  List<String> pendingRequests = [];
  List<String> alreadyReceived = [];

  // When wallet is encrypted
  String encryptedSecret;

  void updateNatriconNonce(String address, int nonce) {
    setState(() {
      this.natriconNonce[address] = nonce.toString();
    });
  }

  String getNatriconNonce(String address) {
    if (this.natriconNonce.containsKey(address)) {
      return this.natriconNonce[address];
    }
    return "";
  }

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
  StreamSubscription<ConnStatusEvent> _connStatusSub;
  StreamSubscription<SubscribeEvent> _subscribeEventSub;
  StreamSubscription<PriceEvent> _priceEventSub;
  StreamSubscription<CallbackEvent> _callbackSub;
  StreamSubscription<ErrorEvent> _errorSub;
  StreamSubscription<AccountModifiedEvent> _accountModifiedSub;

  // Register RX event listenerss
  void _registerBus() {
    _subscribeEventSub =
        EventTaxiImpl.singleton().registerTo<SubscribeEvent>().listen((event) {
      handleSubscribeResponse(event.response);
    });
    _priceEventSub =
        EventTaxiImpl.singleton().registerTo<PriceEvent>().listen((event) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      setState(() {
        wallet.btcPrice = event.response.btcPrice.toString();
        wallet.localCurrencyPrice = event.response.price.toString();
      });
    });
    _connStatusSub =
        EventTaxiImpl.singleton().registerTo<ConnStatusEvent>().listen((event) {
      if (event.status == ConnectionStatus.CONNECTED) {
        requestUpdate();
      } else if (event.status == ConnectionStatus.DISCONNECTED &&
          !sl.get<AccountService>().suspended) {
        sl.get<AccountService>().initCommunication();
      }
    });
    _callbackSub =
        EventTaxiImpl.singleton().registerTo<CallbackEvent>().listen((event) {
      handleCallbackResponse(event.response);
    });
    _errorSub =
        EventTaxiImpl.singleton().registerTo<ErrorEvent>().listen((event) {
      handleErrorResponse(event.response);
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
    if (_connStatusSub != null) {
      _connStatusSub.cancel();
    }
    if (_subscribeEventSub != null) {
      _subscribeEventSub.cancel();
    }
    if (_priceEventSub != null) {
      _priceEventSub.cancel();
    }
    if (_callbackSub != null) {
      _callbackSub.cancel();
    }
    if (_errorSub != null) {
      _errorSub.cancel();
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
    String address = IdenaUtil.seedToAddress(await getSeed(), account.index); 
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

  void disconnect() {
    sl.get<AccountService>().reset(suspend: true);
  }

  void reconnect() {
    sl.get<AccountService>().initCommunication(unsuspend: true);
  }

  void lockCallback() {
    _locked = true;
  }

  void unlockCallback() {
    _locked = false;
  }

  ///
  /// When an error is returned from server
  ///
  Future<void> handleErrorResponse(ErrorResponse errorResponse) async {
    sl.get<AccountService>().processQueue();
    if (errorResponse.error == null) {
      return;
    }
  }

  /// Handle account_subscribe response
  void handleSubscribeResponse(SubscribeResponse response) {
    // Combat spam by raising minimum receive if pending block count is large enough
    if (response.pendingCount != null && response.pendingCount > 50) {
      // Bump min receive to 0.05 iDNA
      receiveThreshold = BigInt.from(5).pow(28).toString();
    }
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Server gives us a UUID for future requests on subscribe
    if (response.uuid != null) {
      sl.get<SharedPrefsUtil>().setUuid(response.uuid);
    }
    setState(() {
      wallet.loading = false;
      wallet.frontier = response.frontier;
      wallet.openBlock = response.openBlock;
      wallet.blockCount = response.blockCount;
      if (response.balance == null) {
        wallet.accountBalance = BigInt.from(0);
      } else {
        wallet.accountBalance = BigInt.tryParse(response.balance);
      }
      wallet.localCurrencyPrice = response.price.toString();
      wallet.btcPrice = response.btcPrice.toString();
      sl.get<AccountService>().pop();
      sl.get<AccountService>().processQueue();
    });
  }

  /// Handle callback response
  /// Typically this means we need to pocket transactions
  Future<void> handleCallbackResponse(CallbackResponse resp) async {
    if (_locked) {
      return;
    }
    log.d("Received callback ${json.encode(resp.toJson())}");
    if (resp.isSend != "true") {
      sl.get<AccountService>().processQueue();
      return;
    }
    PendingResponseItem pendingItem = PendingResponseItem(
        hash: resp.hash, source: resp.account, amount: resp.amount);
    String receivedHash = await handlePendingItem(pendingItem);
    if (receivedHash != null) {
      AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
          type: BlockTypes.RECEIVE,
          account: resp.account,
          amount: resp.amount,
          hash: receivedHash);
      if (!wallet.history.contains(histItem)) {
        setState(() {
          wallet.history.insert(0, histItem);
          wallet.accountBalance += BigInt.parse(resp.amount);
          // Send list to home screen
          EventTaxiImpl.singleton()
              .fire(HistoryHomeEvent(items: wallet.history));
        });
      }
    }
  }

  Future<String> handlePendingItem(PendingResponseItem item) async {
    if (pendingRequests.contains(item.hash)) {
      return null;
    }
    pendingRequests.add(item.hash);
    BigInt amountBigInt = BigInt.tryParse(item.amount);
    sl.get<Logger>().d("Handling ${item.hash} pending");
    if (amountBigInt != null) {
      if (amountBigInt < BigInt.parse(receiveThreshold)) {
        pendingRequests.remove(item.hash);
        return null;
      }
    }
    if (wallet.openBlock == null) {
      // Publish open
      sl.get<Logger>().d("Handling ${item.hash} as open");
      try {
        ProcessResponse resp = await sl.get<AccountService>().requestOpen(
            item.amount, item.hash, wallet.address, await _getPrivKey());
        wallet.openBlock = resp.hash;
        wallet.frontier = resp.hash;
        pendingRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        pendingRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating open", e);
      }
    } else {
      // Publish receive
      sl.get<Logger>().d("Handling ${item.hash} as receive");
      try {
        ProcessResponse resp = await sl.get<AccountService>().requestReceive(
            wallet.representative,
            wallet.frontier,
            item.amount,
            item.hash,
            wallet.address,
            await _getPrivKey());
        wallet.frontier = resp.hash;
        pendingRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        pendingRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating receive", e);
      }
    }
    return null;
  }

  /// Request balances for accounts in our database
  Future<void> _requestBalances() async {
    List<Account> accounts =
        await sl.get<DBHelper>().getAccounts(await getSeed());
    List<String> addressToRequest = List();
    accounts.forEach((account) {
      if (account.address != null) {
        addressToRequest.add(account.address);
      }
    });
    AccountsBalancesResponse resp = await sl
        .get<AccountService>()
        .requestAccountsBalances(addressToRequest);
    sl.get<DBHelper>().getAccounts(await getSeed()).then((accounts) {
      accounts.forEach((account) {
        resp.balances.forEach((address, balance) {
          String combinedBalance = (BigInt.tryParse(balance.balance) +
                  BigInt.tryParse(balance.pending))
              .toString();
          if (address == account.address &&
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
      String uuid = await sl.get<SharedPrefsUtil>().getUuid();
      sl.get<AccountService>().clearQueue();
      sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: "",
          notificationEnabled: false));
      sl
          .get<AccountService>()
          .queueRequest(AccountHistoryRequest(address: wallet.address));
      sl.get<AccountService>().processQueue();
      // Request account history

      // Choose correct blockCount to minimize bandwidth
      // This is can still be improved because history excludes change/open, blockCount doesn't
      // Get largest count we have + 5 (just a safe-buffer)
      int count = 500;
      if (wallet.history != null && wallet.history.length > 1) {
        count = 50;
      }
      try {
        AccountHistoryResponse resp = await sl
            .get<AccountService>()
            .requestAccountHistory(wallet.address, limit: count);
        _requestBalances();
        bool postedToHome = false;
        // Iterate list in reverse (oldest to newest block)
        for (AccountHistoryResponseItem item in resp.history) {
          // If current list doesn't contain this item, insert it and the rest of the items in list and exit loop
          if (!wallet.history.contains(item)) {
            int startIndex = 0; // Index to start inserting into the list
            int lastIndex = resp.history.indexWhere((item) => wallet.history
                .contains(
                    item)); // Last index of historyResponse to insert to (first index where item exists in wallet history)
            lastIndex = lastIndex <= 0 ? resp.history.length : lastIndex;
            setState(() {
              wallet.history
                  .insertAll(0, resp.history.getRange(startIndex, lastIndex));
              // Send list to home screen
              EventTaxiImpl.singleton()
                  .fire(HistoryHomeEvent(items: wallet.history));
            });
            postedToHome = true;
            break;
          }
        }
        setState(() {
          wallet.historyLoading = false;
        });
        if (!postedToHome) {
          EventTaxiImpl.singleton()
              .fire(HistoryHomeEvent(items: wallet.history));
        }
        sl.get<AccountService>().pop();
        sl.get<AccountService>().processQueue();
        // Receive pendings
        if (pending) {
          PendingResponse pendingResp = await sl
              .get<AccountService>()
              .getPending(wallet.address, max(wallet.blockCount ?? 0, 10),
                  threshold: receiveThreshold);
          // Initiate receive/open request for each pending
          for (String hash in pendingResp.blocks.keys) {
            PendingResponseItem pendingResponseItem = pendingResp.blocks[hash];
            pendingResponseItem.hash = hash;
            String receivedHash = await handlePendingItem(pendingResponseItem);
            if (receivedHash != null) {
              AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
                  type: BlockTypes.RECEIVE,
                  account: pendingResponseItem.source,
                  amount: pendingResponseItem.amount,
                  hash: receivedHash);
              if (!wallet.history.contains(histItem)) {
                setState(() {
                  wallet.history.insert(0, histItem);
                  wallet.accountBalance +=
                      BigInt.parse(pendingResponseItem.amount);
                  // Send list to home screen
                  EventTaxiImpl.singleton()
                      .fire(HistoryHomeEvent(items: wallet.history));
                });
              }
            }
          }
        }
      } catch (e) {
        // TODO handle account history error
        sl.get<Logger>().e("account_history e", e);
      }
    }
  }

  Future<void> requestSubscribe() async {
    if (wallet != null &&
        wallet.address != null &&
        Address(wallet.address).isValid()) {
      String uuid = await sl.get<SharedPrefsUtil>().getUuid();

    
      sl.get<AccountService>().removeSubscribeHistoryPendingFromQueue();
      sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: "",
          notificationEnabled: false));
      sl.get<AccountService>().processQueue();
    }
  }

  void logOut() {
    setState(() {
      wallet = AppWallet();
      encryptedSecret = null;
    });
    sl.get<DBHelper>().dropAccounts();
    sl.get<AccountService>().clearQueue();
  }

  Future<String> _getPrivKey() async {
    String seed = await getSeed();
    return IdenaKeys.seedToPrivate(seed, selectedAccount.index);
  }

  Future<String> getSeed() async {
    String seed;
    if (encryptedSecret != null) {
      seed = IdenaHelpers.byteToHex(IdenaCrypt.decrypt(
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

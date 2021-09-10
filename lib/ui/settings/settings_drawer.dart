// @dart=2.9

import 'dart:async';
import 'package:event_taxi/event_taxi.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/service/dragginator_service.dart';
import 'package:my_bismuth_wallet/ui/accounts/accountdetails_sheet.dart';
import 'package:my_bismuth_wallet/ui/accounts/accounts_sheet.dart';
import 'package:my_bismuth_wallet/ui/dragginator/my_dragginator_breeding_list.dart';
import 'package:my_bismuth_wallet/ui/dragginator/my_dragginator_merging.dart';
import 'package:my_bismuth_wallet/ui/send/send_confirm_sheet.dart';
import 'package:my_bismuth_wallet/ui/settings/custom_url_widget.dart';
import 'package:my_bismuth_wallet/ui/settings/disable_password_sheet.dart';
import 'package:my_bismuth_wallet/ui/settings/set_password_sheet.dart';
import 'package:my_bismuth_wallet/ui/settings/tokens_widget.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_simpledialog.dart';
import 'package:my_bismuth_wallet/ui/widgets/dialog.dart';
import 'package:my_bismuth_wallet/ui/widgets/sheet_util.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/model/authentication_method.dart';
import 'package:my_bismuth_wallet/model/available_currency.dart';
import 'package:my_bismuth_wallet/model/device_unlock_option.dart';
import 'package:my_bismuth_wallet/model/device_lock_timeout.dart';
import 'package:my_bismuth_wallet/model/available_language.dart';
import 'package:my_bismuth_wallet/model/vault.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/ui/settings/backupseed_sheet.dart';
import 'package:my_bismuth_wallet/ui/settings/settings_list_item.dart';
import 'package:my_bismuth_wallet/ui/settings/contacts_widget.dart';
import 'package:my_bismuth_wallet/ui/widgets/security.dart';
import 'package:my_bismuth_wallet/ui/util/ui_util.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';
import 'package:my_bismuth_wallet/util/biometrics.dart';
import 'package:my_bismuth_wallet/util/hapticutil.dart';

import '../../appstate_container.dart';
import '../../util/sharedprefsutil.dart';

class SettingsSheet extends StatefulWidget {
  _SettingsSheetState createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;
  Animation<Offset> _offsetFloat;
  AnimationController _securityController;
  Animation<Offset> _securityOffsetFloat;
  AnimationController _tokensListController;
  Animation<Offset> _tokensListOffsetFloat;
  AnimationController _customUrlController;
  Animation<Offset> _customUrlOffsetFloat;
  AnimationController _dragginatorController;
  Animation<Offset> _dragginatorOffsetFloat;

  String versionString = "";

  final Logger log = sl.get<Logger>();
  bool _hasBiometrics = false;
  AuthenticationMethod _curAuthMethod =
      AuthenticationMethod(AuthMethod.BIOMETRICS);
  UnlockSetting _curUnlockSetting = UnlockSetting(UnlockOption.NO);
  LockTimeoutSetting _curTimeoutSetting =
      LockTimeoutSetting(LockTimeoutOption.ONE);

  bool _securityOpen;
  bool _loadingAccounts;

  bool _contactsOpen;

  bool _tokensListOpen;

  bool _customUrlOpen;

  bool _dragginatorOpen;

  bool notNull(Object o) => o != null;

  @override
  void initState() {
    super.initState();
    _contactsOpen = false;
    _tokensListOpen = false;
    _securityOpen = false;
    _loadingAccounts = false;
    _customUrlOpen = false;
    _dragginatorOpen = false;
    // Determine if they have face or fingerprint enrolled, if not hide the setting
    sl.get<BiometricUtil>().hasBiometrics().then((bool hasBiometrics) {
      setState(() {
        _hasBiometrics = hasBiometrics;
      });
    });
    // Get default auth method setting
    sl.get<SharedPrefsUtil>().getAuthMethod().then((authMethod) {
      setState(() {
        _curAuthMethod = authMethod;
      });
    });
    // Get default unlock settings
    sl.get<SharedPrefsUtil>().getLock().then((lock) {
      setState(() {
        _curUnlockSetting = lock
            ? UnlockSetting(UnlockOption.YES)
            : UnlockSetting(UnlockOption.NO);
      });
    });
    sl.get<SharedPrefsUtil>().getLockTimeout().then((lockTimeout) {
      setState(() {
        _curTimeoutSetting = lockTimeout;
      });
    });
    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For security menu
    _securityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _dragginatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For token list menu
    _tokensListController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // For customUrl menu
    _customUrlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _offsetFloat = Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
        .animate(_controller);
    _securityOffsetFloat =
        Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
            .animate(_securityController);
    _dragginatorOffsetFloat =
        Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
            .animate(_dragginatorController);
    _tokensListOffsetFloat =
        Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
            .animate(_tokensListController);
    _customUrlOffsetFloat =
        Tween<Offset>(begin: Offset(1.1, 0), end: Offset(0, 0))
            .animate(_customUrlController);
    // Version string
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        versionString = "v${packageInfo.version}";
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _securityController.dispose();
    _dragginatorController.dispose();
    _tokensListController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  Future<void> _authMethodDialog() async {
    switch (await showDialog<AuthMethod>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).authMethod,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.BIOMETRICS);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).biometricsMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, AuthMethod.PIN);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).pinMethod,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case AuthMethod.PIN:
        sl
            .get<SharedPrefsUtil>()
            .setAuthMethod(AuthenticationMethod(AuthMethod.PIN))
            .then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.PIN);
          });
        });
        break;
      case AuthMethod.BIOMETRICS:
        sl
            .get<SharedPrefsUtil>()
            .setAuthMethod(AuthenticationMethod(AuthMethod.BIOMETRICS))
            .then((result) {
          setState(() {
            _curAuthMethod = AuthenticationMethod(AuthMethod.BIOMETRICS);
          });
        });
        break;
    }
  }

  Future<void> _lockDialog() async {
    switch (await showDialog<UnlockOption>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Text(
              AppLocalization.of(context).lockAppSetting,
              style: AppStyles.textStyleDialogHeader(context),
            ),
            children: <Widget>[
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.NO);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).no,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
              AppSimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, UnlockOption.YES);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppLocalization.of(context).yes,
                    style: AppStyles.textStyleDialogOptions(context),
                  ),
                ),
              ),
            ],
          );
        })) {
      case UnlockOption.YES:
        sl.get<SharedPrefsUtil>().setLock(true).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.YES);
          });
        });
        break;
      case UnlockOption.NO:
        sl.get<SharedPrefsUtil>().setLock(false).then((result) {
          setState(() {
            _curUnlockSetting = UnlockSetting(UnlockOption.NO);
          });
        });
        break;
    }
  }

  List<Widget> _buildCurrencyOptions() {
    List<Widget> ret = new List();
    AvailableCurrencyEnum.values.forEach((AvailableCurrencyEnum value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            AvailableCurrency(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _currencyDialog() async {
    AvailableCurrencyEnum selection =
        await showAppDialog<AvailableCurrencyEnum>(
            context: context,
            builder: (BuildContext context) {
              return AppSimpleDialog(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    AppLocalization.of(context).currency,
                    style: AppStyles.textStyleDialogHeader(context),
                  ),
                ),
                children: _buildCurrencyOptions(),
              );
            });
    if (selection != null) {
      sl
          .get<SharedPrefsUtil>()
          .setCurrency(AvailableCurrency(selection))
          .then((result) {
        if (StateContainer.of(context).curCurrency.currency != selection) {
          setState(() {
            StateContainer.of(context).curCurrency =
                AvailableCurrency(selection);
            StateContainer.of(context)
                .updateCurrency(AvailableCurrency(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildLanguageOptions() {
    List<Widget> ret = new List();
    AvailableLanguage.values.forEach((AvailableLanguage value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            LanguageSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _languageDialog() async {
    AvailableLanguage selection = await showAppDialog<AvailableLanguage>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context).language,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLanguageOptions(),
          );
        });
    if (selection != null) {
      sl
          .get<SharedPrefsUtil>()
          .setLanguage(LanguageSetting(selection))
          .then((result) {
        if (StateContainer.of(context).curLanguage.language != selection) {
          setState(() {
            StateContainer.of(context)
                .updateLanguage(LanguageSetting(selection));
          });
        }
      });
    }
  }

  List<Widget> _buildLockTimeoutOptions() {
    List<Widget> ret = new List();
    LockTimeoutOption.values.forEach((LockTimeoutOption value) {
      ret.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            LockTimeoutSetting(value).getDisplayName(context),
            style: AppStyles.textStyleDialogOptions(context),
          ),
        ),
      ));
    });
    return ret;
  }

  Future<void> _lockTimeoutDialog() async {
    LockTimeoutOption selection = await showAppDialog<LockTimeoutOption>(
        context: context,
        builder: (BuildContext context) {
          return AppSimpleDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalization.of(context).autoLockHeader,
                style: AppStyles.textStyleDialogHeader(context),
              ),
            ),
            children: _buildLockTimeoutOptions(),
          );
        });
    sl
        .get<SharedPrefsUtil>()
        .setLockTimeout(LockTimeoutSetting(selection))
        .then((result) {
      if (_curTimeoutSetting.setting != selection) {
        sl
            .get<SharedPrefsUtil>()
            .setLockTimeout(LockTimeoutSetting(selection))
            .then((_) {
          setState(() {
            _curTimeoutSetting = LockTimeoutSetting(selection);
          });
        });
      }
    });
  }

  Future<bool> _onBackButtonPressed() async {
    if (_contactsOpen) {
      setState(() {
        _contactsOpen = false;
      });
      _controller.reverse();
      return false;
    } else if (_securityOpen) {
      setState(() {
        _securityOpen = false;
      });
      _securityController.reverse();
      return false;
    } else if (_dragginatorOpen) {
      setState(() {
        _dragginatorOpen = false;
      });
      _dragginatorController.reverse();
      return false;
    } else if (_tokensListOpen) {
      setState(() {
        _tokensListOpen = false;
      });
      _tokensListController.reverse();
      return false;
    } else if (_customUrlOpen) {
      setState(() {
        _customUrlOpen = false;
      });
      _customUrlController.reverse();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Drawer in flutter doesn't have a built-in way to push/pop elements
    // on top of it like our Android counterpart. So we can override back button
    // presses and replace the main settings widget with contacts based on a bool
    return new WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            Container(
              color: StateContainer.of(context).curTheme.backgroundDark,
              constraints: BoxConstraints.expand(),
            ),
            buildMainSettings(context),
            SlideTransition(
                position: _offsetFloat,
                child: ContactsList(_controller, _contactsOpen)),
            SlideTransition(
                position: _securityOffsetFloat,
                child: buildSecurityMenu(context)),
            SlideTransition(
                position: _dragginatorOffsetFloat,
                child: buildDragginatorMenu(context)),
            SlideTransition(
                position: _tokensListOffsetFloat,
                child: TokensList(_tokensListController, _tokensListOpen)),
            SlideTransition(
                position: _customUrlOffsetFloat,
                child: CustomUrl(_customUrlController, _customUrlOpen)),
          ],
        ),
      ),
    );
  }

  Widget buildMainSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 30,
        ),
        child: Column(
          children: <Widget>[
            // A container for accounts area
            Container(
              margin:
                  EdgeInsetsDirectional.only(start: 26.0, end: 20, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsetsDirectional.only(start: 4.0),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  border: Border.all(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      width: 0),
                                ),
                                alignment: AlignmentDirectional(-1, 0),
                                child: CircleAvatar(
                                  backgroundColor: StateContainer.of(context)
                                      .curTheme
                                      .text05,
                                  backgroundImage: NetworkImage(
                                    StateContainer.of(context)
                                                    .selectedAccount
                                                    .dragginatorDna ==
                                                null ||
                                            StateContainer.of(context)
                                                    .selectedAccount
                                                    .dragginatorDna ==
                                                ""
                                        ? UIUtil.getRobohashURL(
                                            StateContainer.of(context)
                                                .selectedAccount
                                                .address)
                                        : UIUtil.getDragginatorURL(
                                            StateContainer.of(context)
                                                .selectedAccount
                                                .dragginatorDna,
                                            StateContainer.of(context)
                                                .selectedAccount
                                                .dragginatorStatus),
                                  ),
                                  radius: 50.0,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0)),
                                  highlightColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  splashColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  padding: EdgeInsets.all(0.0),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                  ),
                                  onPressed: () {
                                    AccountDetailsSheet(
                                            StateContainer.of(context)
                                                .selectedAccount)
                                        .mainBottomSheet(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // A row for other accounts and account switcher
                      Row(
                        children: <Widget>[
                          // Second Account
                          StateContainer.of(context).recentLast != null
                              ? Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          height: 52,
                                          width: 52,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text05,
                                            backgroundImage: NetworkImage(
                                              StateContainer.of(context)
                                                              .recentLast
                                                              .dragginatorDna ==
                                                          null ||
                                                      StateContainer.of(context)
                                                              .recentLast
                                                              .dragginatorDna ==
                                                          ""
                                                  ? UIUtil.getRobohashURL(
                                                      StateContainer.of(context)
                                                          .recentLast
                                                          .address)
                                                  : UIUtil.getDragginatorURL(
                                                      StateContainer.of(context)
                                                          .recentLast
                                                          .dragginatorDna,
                                                      StateContainer.of(context)
                                                          .recentLast
                                                          .dragginatorStatus),
                                            ),
                                            radius: 50.0,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          color: Colors.transparent,
                                          child: FlatButton(
                                            onPressed: () {
                                              sl
                                                  .get<DBHelper>()
                                                  .changeAccount(
                                                      StateContainer.of(context)
                                                          .recentLast)
                                                  .then((_) {
                                                EventTaxiImpl.singleton().fire(
                                                    AccountChangedEvent(
                                                        account:
                                                            StateContainer.of(
                                                                    context)
                                                                .recentLast,
                                                        delayPop: true));
                                              });
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0)),
                                            highlightColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text15,
                                            splashColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text15,
                                            padding: EdgeInsets.all(0.0),
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          // Third Account
                          StateContainer.of(context).recentSecondLast != null
                              ? Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          height: 52,
                                          width: 52,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text05,
                                            backgroundImage: NetworkImage(
                                              StateContainer.of(context)
                                                              .recentSecondLast
                                                              .dragginatorDna ==
                                                          null ||
                                                      StateContainer.of(context)
                                                              .recentSecondLast
                                                              .dragginatorDna ==
                                                          ""
                                                  ? UIUtil.getRobohashURL(
                                                      StateContainer.of(context)
                                                          .recentSecondLast
                                                          .address)
                                                  : UIUtil.getDragginatorURL(
                                                      StateContainer.of(context)
                                                          .recentSecondLast
                                                          .dragginatorDna,
                                                      StateContainer.of(context)
                                                          .recentSecondLast
                                                          .dragginatorStatus),
                                            ),
                                            radius: 50.0,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          color: Colors.transparent,
                                          child: FlatButton(
                                            onPressed: () {
                                              sl
                                                  .get<DBHelper>()
                                                  .changeAccount(
                                                      StateContainer.of(context)
                                                          .recentSecondLast)
                                                  .then((_) {
                                                EventTaxiImpl.singleton().fire(
                                                    AccountChangedEvent(
                                                        account: StateContainer
                                                                .of(context)
                                                            .recentSecondLast,
                                                        delayPop: true));
                                              });
                                            },
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0)),
                                            highlightColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text15,
                                            splashColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .text15,
                                            padding: EdgeInsets.all(0.0),
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          // Account switcher
                          Container(
                            height: 36,
                            width: 36,
                            margin: EdgeInsets.symmetric(horizontal: 6.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: FlatButton(
                              onPressed: () {
                                if (!_loadingAccounts) {
                                  setState(() {
                                    _loadingAccounts = true;
                                  });
                                  StateContainer.of(context)
                                      .getSeed()
                                      .then((seed) {
                                    sl
                                        .get<DBHelper>()
                                        .getAccounts(seed)
                                        .then((accounts) {
                                      setState(() {
                                        _loadingAccounts = false;
                                      });
                                      AppAccountsSheet(accounts)
                                          .mainBottomSheet(context);
                                    });
                                  });
                                }
                              },
                              padding: EdgeInsets.all(0.0),
                              shape: CircleBorder(),
                              splashColor: _loadingAccounts
                                  ? Colors.transparent
                                  : StateContainer.of(context).curTheme.text30,
                              highlightColor: _loadingAccounts
                                  ? Colors.transparent
                                  : StateContainer.of(context).curTheme.text15,
                              child: Icon(Typicons.users_outline,
                                  size: 26,
                                  color: _loadingAccounts
                                      ? StateContainer.of(context)
                                          .curTheme
                                          .icon60
                                      : StateContainer.of(context)
                                          .curTheme
                                          .icon),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    child: FlatButton(
                      padding: EdgeInsets.all(4.0),
                      highlightColor:
                          StateContainer.of(context).curTheme.text15,
                      splashColor: StateContainer.of(context).curTheme.text30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      onPressed: () {
                        AccountDetailsSheet(
                                StateContainer.of(context).selectedAccount)
                            .mainBottomSheet(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Main account name
                          Container(
                            child: Text(
                              StateContainer.of(context).selectedAccount.name,
                              style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                                color: StateContainer.of(context).curTheme.text,
                              ),
                            ),
                          ),
                          // Main account address
                          Container(
                            child: Text(
                              StateContainer.of(context).wallet != null &&
                                      StateContainer.of(context)
                                              .wallet
                                              .address !=
                                          null
                                  ? StateContainer.of(context).wallet?.address
                                  : "",
                              style: TextStyle(
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                                fontSize: 14.0,
                                color:
                                    StateContainer.of(context).curTheme.text60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Settings items
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsetsDirectional.only(start: 30.0, bottom: 10.0),
                      child: Text(AppLocalization.of(context).informations,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).tokensListHeader,
                        Iconic.list_nested, onPressed: () {
                      setState(() {
                        _tokensListOpen = true;
                      });
                      _tokensListController.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 30.0, top: 20.0, bottom: 10.0),
                      child: Text(AppLocalization.of(context).letsPlay,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).dragginatorHeader,
                        FontAwesome5.dragon, onPressed: () {
                      setState(() {
                        _dragginatorOpen = true;
                      });
                      _dragginatorController.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 30.0, top: 20.0, bottom: 10.0),
                      child: Text(AppLocalization.of(context).manage,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).contactsHeader,
                        Typicons.contacts, onPressed: () {
                      setState(() {
                        _contactsOpen = true;
                      });
                      _controller.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).backupSecretPhrase,
                        AppIcons.backupseed, onPressed: () async {
                      // Authenticate
                      AuthenticationMethod authMethod =
                          await sl.get<SharedPrefsUtil>().getAuthMethod();
                      bool hasBiometrics =
                          await sl.get<BiometricUtil>().hasBiometrics();
                      if (authMethod.method == AuthMethod.BIOMETRICS &&
                          hasBiometrics) {
                        try {
                          bool authenticated = await sl
                              .get<BiometricUtil>()
                              .authenticateWithBiometrics(
                                  context,
                                  AppLocalization.of(context)
                                      .fingerprintSeedBackup);
                          if (authenticated) {
                            sl.get<HapticUtil>().fingerprintSucess();
                            StateContainer.of(context).getSeed().then((seed) {
                              AppSeedBackupSheet(seed).mainBottomSheet(context);
                            });
                          }
                        } catch (e) {
                          await authenticateWithPin();
                        }
                      } else {
                        await authenticateWithPin();
                      }
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).customUrlHeader,
                        FontAwesome.code, onPressed: () {
                      setState(() {
                        _customUrlOpen = true;
                      });
                      _customUrlController.forward();
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 30.0, top: 20.0, bottom: 10.0),
                      child: Text(AppLocalization.of(context).preferences,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).changeCurrency,
                        StateContainer.of(context).curCurrency,
                        FontAwesome.money,
                        _currencyDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                        context,
                        AppLocalization.of(context).language,
                        StateContainer.of(context).curLanguage,
                        FontAwesome.language,
                        _languageDialog),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).securityHeader,
                        AppIcons.security, onPressed: () {
                      setState(() {
                        _securityOpen = true;
                      });
                      _securityController.forward();
                    }),
                    /*Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).logout,
                        FontAwesome.logout, onPressed: () {
                      AppDialogs.showConfirmDialog(
                          context,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).warning, context),
                          AppLocalization.of(context).logoutDetail,
                          AppLocalization.of(context)
                              .logoutAction
                              .toUpperCase(), () {
                        // Show another confirm dialog
                        AppDialogs.showConfirmDialog(
                            context,
                            AppLocalization.of(context).logoutAreYouSure,
                            AppLocalization.of(context).logoutReassurance,
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).yes, context), () {
                          // Delete all data
                          sl.get<Vault>().deleteAll().then((_) {
                            sl
                                .get<SharedPrefsUtil>()
                                .deleteAll()
                                .then((result) {
                              StateContainer.of(context).logOut();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (Route<dynamic> route) => false);
                            });
                          });
                        });
                      });
                    }),*/
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(versionString,
                              style: AppStyles.textStyleVersion(context)),
                          Text(" | ",
                              style: AppStyles.textStyleVersion(context)),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return UIUtil.showWebview(context,
                                      AppLocalization.of(context).privacyUrl);
                                }));
                              },
                              child: Text(
                                  AppLocalization.of(context).privacyPolicy,
                                  style: AppStyles.textStyleVersionUnderline(
                                      context))),
                        ],
                      ),
                    ),
                  ].where(notNull).toList(),
                ),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          StateContainer.of(context).curTheme.backgroundDark,
                          StateContainer.of(context).curTheme.backgroundDark00
                        ],
                        begin: AlignmentDirectional(0.5, -1.0),
                        end: AlignmentDirectional(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildDragginatorMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: [
          BoxShadow(
              color: StateContainer.of(context).curTheme.overlay30,
              offset: Offset(-5, 0),
              blurRadius: 20),
        ],
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button
            Container(
              margin: EdgeInsets.only(bottom: 10.0, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      //Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: FlatButton(
                            highlightColor:
                                StateContainer.of(context).curTheme.text15,
                            splashColor:
                                StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              setState(() {
                                _dragginatorOpen = false;
                              });
                              _dragginatorController.reverse();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(AppIcons.back,
                                color: StateContainer.of(context).curTheme.text,
                                size: 24)),
                      ),
                      Text(
                        AppLocalization.of(context).dragginatorHeader,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                      child: Text(AppLocalization.of(context).manage,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context)
                            .dragginatorBreedingListHeader,
                        FontAwesome5.list, onPressed: () {
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: MyDragginatorBreedingList(
                              StateContainer.of(context)
                                  .selectedAccount
                                  .address));
                    }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).dragginatorMergingHeader,
                        Typicons.flow_merge, onPressed: () {
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: MyDragginatorMerging(
                              StateContainer.of(context)
                                  .selectedAccount
                                  .address));
                    }),
                    sl.get<DragginatorService>().isEggOwner(
                                StateContainer.of(context).wallet.tokens) ==
                            false
                        ? SizedBox()
                        : Divider(
                            height: 2,
                            color: StateContainer.of(context).curTheme.text15,
                          ),
                    sl.get<DragginatorService>().isEggOwner(
                                StateContainer.of(context).wallet.tokens) ==
                            false
                        ? SizedBox()
                        : AppSettings.buildSettingsListItemSingleLine(
                            context,
                            AppLocalization.of(context)
                                .dragginatorGetEggWithEggHeader,
                            FontAwesome5.egg, onPressed: () {
                            Sheets.showAppHeightNineSheet(
                                context: context,
                                widget: SendConfirmSheet(
                                    title: AppLocalization.of(context)
                                        .dragginatorGetEggWithEggHeader,
                                    amountRaw: "0",
                                    operation: "token:transfer",
                                    openfield: "egg:1",
                                    comment: "",
                                    destination: AppLocalization.of(context)
                                        .dragginatorAddress,
                                    contactName: ""));
                          }),
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context)
                            .dragginatorGetEggWithBisHeader,
                        FontAwesome5.money_bill_wave, onPressed: () {
                      Sheets.showAppHeightNineSheet(
                          context: context,
                          widget: SendConfirmSheet(
                              title: AppLocalization.of(context)
                                  .dragginatorGetEggWithBisHeader,
                              amountRaw: "3",
                              operation: "",
                              openfield: "",
                              comment: "",
                              destination: AppLocalization.of(context)
                                  .dragginatorAddress,
                              contactName: ""));
                    }),
                    /*Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLineWithInfos(
                        context,
                        AppLocalization.of(context).dragginatorMarketPlace,
                        "It's a virtual marketplace where Egg owners can freely (as in beer) list their eggs to be sold. Other users then can buy those eggs, and Dragginator acts as an Escrow service.",
                        FontAwesome5.shopping_cart, onPressed: () {
                      AppDialogs.showInfoDialog(
                        context,
                        AppLocalization.of(context).dragginatorMarketPlace,
                        "Soon...",
                      );
                    }),*/
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemSingleLine(
                        context,
                        AppLocalization.of(context).dragginatorHelp,
                        FontAwesome.help_circled, onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return UIUtil.showDragginatorHelp(context);
                      }));
                    }),
                  ].where(notNull).toList(),
                ),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          StateContainer.of(context).curTheme.backgroundDark,
                          StateContainer.of(context).curTheme.backgroundDark00
                        ],
                        begin: AlignmentDirectional(0.5, -1.0),
                        end: AlignmentDirectional(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildSecurityMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        boxShadow: [
          BoxShadow(
              color: StateContainer.of(context).curTheme.overlay30,
              offset: Offset(-5, 0),
              blurRadius: 20),
        ],
      ),
      child: SafeArea(
        minimum: EdgeInsets.only(
          top: 60,
        ),
        child: Column(
          children: <Widget>[
            // Back button and Security Text
            Container(
              margin: EdgeInsets.only(bottom: 10.0, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      //Back button
                      Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: FlatButton(
                            highlightColor:
                                StateContainer.of(context).curTheme.text15,
                            splashColor:
                                StateContainer.of(context).curTheme.text15,
                            onPressed: () {
                              setState(() {
                                _securityOpen = false;
                              });
                              _securityController.reverse();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(AppIcons.back,
                                color: StateContainer.of(context).curTheme.text,
                                size: 24)),
                      ),
                      //Security Header Text
                      Text(
                        AppLocalization.of(context).securityHeader,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: <Widget>[
                ListView(
                  padding: EdgeInsets.only(top: 15.0),
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsetsDirectional.only(start: 30.0, bottom: 10),
                      child: Text(AppLocalization.of(context).preferences,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              color:
                                  StateContainer.of(context).curTheme.text60)),
                    ),
                    // Authentication Method
                    _hasBiometrics
                        ? Divider(
                            height: 2,
                            color: StateContainer.of(context).curTheme.text15,
                          )
                        : null,
                    _hasBiometrics
                        ? AppSettings.buildSettingsListItemDoubleLine(
                            context,
                            AppLocalization.of(context).authMethod,
                            _curAuthMethod,
                            AppIcons.fingerprint,
                            _authMethodDialog)
                        : null,
                    // Authenticate on Launch
                    StateContainer.of(context).encryptedSecret == null
                        ? Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemDoubleLine(
                                context,
                                AppLocalization.of(context).lockAppSetting,
                                _curUnlockSetting,
                                AppIcons.lock,
                                _lockDialog),
                          ])
                        : SizedBox(),
                    // Authentication Timer
                    Divider(
                      height: 2,
                      color: StateContainer.of(context).curTheme.text15,
                    ),
                    AppSettings.buildSettingsListItemDoubleLine(
                      context,
                      AppLocalization.of(context).autoLockHeader,
                      _curTimeoutSetting,
                      AppIcons.timer,
                      _lockTimeoutDialog,
                      disabled: _curUnlockSetting.setting == UnlockOption.NO &&
                          StateContainer.of(context).encryptedSecret == null,
                    ),
                    // Encrypt option
                    StateContainer.of(context).encryptedSecret == null
                        ? Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemSingleLine(
                                context,
                                AppLocalization.of(context).setWalletPassword,
                                AppIcons.walletpassword, onPressed: () {
                              Sheets.showAppHeightNineSheet(
                                  context: context, widget: SetPasswordSheet());
                            })
                          ])
                        : // Decrypt option
                        Column(children: <Widget>[
                            Divider(
                                height: 2,
                                color:
                                    StateContainer.of(context).curTheme.text15),
                            AppSettings.buildSettingsListItemSingleLine(
                                context,
                                AppLocalization.of(context)
                                    .disableWalletPassword,
                                AppIcons.walletpassworddisabled, onPressed: () {
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: DisablePasswordSheet());
                            }),
                          ]),
                    Divider(
                        height: 2,
                        color: StateContainer.of(context).curTheme.text15),
                  ].where(notNull).toList(),
                ),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          StateContainer.of(context).curTheme.backgroundDark,
                          StateContainer.of(context).curTheme.backgroundDark00
                        ],
                        begin: AlignmentDirectional(0.5, -1.0),
                        end: AlignmentDirectional(0.5, 1.0),
                      ),
                    ),
                  ),
                ), //List Top Gradient End
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context).pinSeedBackup,
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pop();
      StateContainer.of(context).getSeed().then((seed) {
        AppSeedBackupSheet(seed).mainBottomSheet(context);
      });
    }
  }
}

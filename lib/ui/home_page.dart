// @dart=2.9

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/base/animation/actor_animation.dart';

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/model/bis_url.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/ui/popup_button.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/dimens.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/service_locator.dart';

import 'package:my_bismuth_wallet/model/db/contact.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/network/model/block_types.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/ui/contacts/add_contact.dart';
import 'package:my_bismuth_wallet/ui/send/send_sheet.dart';
import 'package:my_bismuth_wallet/ui/send/send_confirm_sheet.dart';
import 'package:my_bismuth_wallet/ui/receive/receive_sheet.dart';
import 'package:my_bismuth_wallet/ui/settings/settings_drawer.dart';
import 'package:my_bismuth_wallet/ui/tokens/my_tokens_list.dart';
import 'package:my_bismuth_wallet/ui/widgets/buttons.dart';
import 'package:my_bismuth_wallet/ui/widgets/dialog.dart';
import 'package:my_bismuth_wallet/ui/widgets/sheet_util.dart';
import 'package:my_bismuth_wallet/ui/widgets/list_slidable.dart';
import 'package:my_bismuth_wallet/ui/util/routes.dart';
import 'package:my_bismuth_wallet/ui/widgets/reactive_refresh.dart';
import 'package:my_bismuth_wallet/ui/util/ui_util.dart';
import 'package:my_bismuth_wallet/ui/widgets/sync_info_view.dart';

import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';
import 'package:my_bismuth_wallet/util/hapticutil.dart';
import 'package:my_bismuth_wallet/util/caseconverter.dart';
import 'package:package_info/package_info.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_bismuth_wallet/bus/events.dart';

class AppHomePage extends StatefulWidget {
  PriceConversion priceConversion;

  AppHomePage({this.priceConversion}) : super();

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        FlareController {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  AnimationController _placeholderCardAnimationController;
  Animation<double> _opacityAnimation;
  bool _animationDisposed;

  bool _displayReleaseNote;

  // Receive card instance
  ReceiveSheet receive;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _listKeyMap = Map();

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  List<Contact> _contacts = List();

  // Price conversion state (BTC, app cryptocurrency, NONE)
  PriceConversion _priceConversion;

  bool _isRefreshing = false;

  bool _lockDisabled = false; // whether we should avoid locking the app

  // Main card height
  double mainCardHeight;
  double settingsIconMarginTop = 5;

  // Animation for swiping to send
  ActorAnimation _sendSlideAnimation;
  ActorAnimation _sendSlideReleaseAnimation;
  double _fanimationPosition;
  bool releaseAnimation = false;

  void initialize(FlutterActorArtboard actor) {
    _fanimationPosition = 0.0;
    _sendSlideAnimation = actor.getAnimation("pull");
    _sendSlideReleaseAnimation = actor.getAnimation("release");
  }

  void setViewTransform(Mat2D viewTransform) {}

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (releaseAnimation) {
      _sendSlideReleaseAnimation.apply(
          _sendSlideReleaseAnimation.duration * (1 - _fanimationPosition),
          artboard,
          1.0);
    } else {
      _sendSlideAnimation.apply(
          _sendSlideAnimation.duration * _fanimationPosition, artboard, 1.0);
    }
    return true;
  }

  _checkVersionApp() async {
    String versionAppCached = await sl.get<SharedPrefsUtil>().getVersionApp();
    PackageInfo.fromPlatform().then((packageInfo) async {
      if (versionAppCached != packageInfo.version) {
        _displayReleaseNote = true;
      } else {
        _displayReleaseNote = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _displayReleaseNote = false;
    _checkVersionApp();

    _registerBus();
    WidgetsBinding.instance.addObserver(this);
    if (widget.priceConversion != null) {
      _priceConversion = widget.priceConversion;
    } else {
      _priceConversion = PriceConversion.BTC;
    }
    // Main Card Size
    if (_priceConversion == PriceConversion.BTC) {
      mainCardHeight = 120;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.NONE) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.HIDDEN) {
      mainCardHeight = 64;
      settingsIconMarginTop = 5;
    }

    _addSampleContact();
    _updateContacts();
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController
        .addListener(_animationControllerListener);
    _opacityAnimation = new Tween(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController.reverse();
        break;
      default:
        return null;
    }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _startAnimation() {
    if (_animationDisposed) {
      _animationDisposed = false;
      _placeholderCardAnimationController
          .addListener(_animationControllerListener);
      _opacityAnimation.addStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.forward();
    }
  }

  void _disposeAnimation() {
    if (!_animationDisposed) {
      _animationDisposed = true;
      _opacityAnimation.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController
          .removeListener(_animationControllerListener);
      _placeholderCardAnimationController.stop();
    }
  }

  /// Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      bool addressExists = await sl
          .get<DBHelper>()
          .contactExistsWithAddress(AppLocalization.of(context).donationsUrl);
      if (addressExists) {
        return;
      }
      bool nameExists = await sl
          .get<DBHelper>()
          .contactExistsWithName(AppLocalization.of(context).donationsName);
      if (nameExists) {
        return;
      }
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      Contact c = Contact(
          name: AppLocalization.of(context).donationsName,
          address: AppLocalization.of(context).donationsUrl);
      await sl.get<DBHelper>().saveContact(c);
    }
  }

  void _updateContacts() {
    sl.get<DBHelper>().getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  StreamSubscription<HistoryHomeEvent> _historySub;
  StreamSubscription<ContactModifiedEvent> _contactModifiedSub;
  StreamSubscription<DisableLockTimeoutEvent> _disableLockSub;
  StreamSubscription<AccountChangedEvent> _switchAccountSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton()
        .registerTo<HistoryHomeEvent>()
        .listen((event) {
      setState(() {
        _isRefreshing = false;
      });
      if (StateContainer.of(context).initialDeepLink != null) {
        handleDeepLink(StateContainer.of(context).initialDeepLink);
        StateContainer.of(context).initialDeepLink = null;
      }
    });
    _contactModifiedSub = EventTaxiImpl.singleton()
        .registerTo<ContactModifiedEvent>()
        .listen((event) {
      _updateContacts();
    });
    // Hackish event to block auto-lock functionality
    _disableLockSub = EventTaxiImpl.singleton()
        .registerTo<DisableLockTimeoutEvent>()
        .listen((event) {
      if (event.disable) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton()
        .registerTo<AccountChangedEvent>()
        .listen((event) {
      setState(() {
        StateContainer.of(context).wallet.loading = true;
        StateContainer.of(context).wallet.historyLoading = true;

        _startAnimation();
        StateContainer.of(context).updateWallet(account: event.account);

        StateContainer.of(context).wallet.loading = false;
        StateContainer.of(context).wallet.historyLoading = false;
      });
      paintQrCode(address: event.account.address);
      if (event.delayPop) {
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    _placeholderCardAnimationController.dispose();
    super.dispose();
  }

  void _destroyBus() {
    if (_historySub != null) {
      _historySub.cancel();
    }
    if (_contactModifiedSub != null) {
      _contactModifiedSub.cancel();
    }
    if (_disableLockSub != null) {
      _disableLockSub.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        setAppLockEvent();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        cancelLockEvent();
        if (!StateContainer.of(context).wallet.loading &&
            StateContainer.of(context).initialDeepLink != null) {
          handleDeepLink(StateContainer.of(context).initialDeepLink);
          StateContainer.of(context).initialDeepLink = null;
        }
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  StreamSubscription<dynamic> lockStreamListener;

  Future<void> setAppLockEvent() async {
    if (((await sl.get<SharedPrefsUtil>().getLock()) ||
            StateContainer.of(context).encryptedSecret != null) &&
        !_lockDisabled) {
      if (lockStreamListener != null) {
        lockStreamListener.cancel();
      }
      Future<dynamic> delayed = new Future.delayed(
          (await sl.get<SharedPrefsUtil>().getLockTimeout()).getDuration());
      delayed.then((_) {
        return true;
      });
      lockStreamListener = delayed.asStream().listen((_) {
        try {
          StateContainer.of(context).resetEncryptedSecret();
        } catch (e) {
          log.w(
              "Failed to reset encrypted secret when locking ${e.toString()}");
        } finally {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      });
    }
  }

  Future<void> cancelLockEvent() async {
    if (lockStreamListener != null) {
      lockStreamListener.cancel();
    }
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    String displayName = smallScreen(context)
        ? StateContainer.of(context).wallet.history[index].getShorterString()
        : StateContainer.of(context).wallet.history[index].getShortString();
    _contacts.forEach((contact) {
      if (StateContainer.of(context).wallet.history[index].type ==
          BlockTypes.RECEIVE) {
        if (contact.address ==
            StateContainer.of(context).wallet.history[index].from) {
          displayName = contact.name;
        }
      } else {
        if (contact.address ==
            StateContainer.of(context).wallet.history[index].recipient) {
          displayName = contact.name;
        }
      }
    });
    return _buildTransactionCard(
        StateContainer.of(context).wallet.history[index],
        animation,
        displayName,
        context);
  }

  // Return widget for list
  Widget _getListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet.historyLoading) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              _buildLoadingTransactionCard(
                  "Sent", "10244000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Received", "100,00000", "@reddwarf1234", context),
              _buildLoadingTransactionCard(
                  "Sent", "14500000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Sent", "12,51200", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Received", "1,45300", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "100,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Received", "24,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
            ],
          ));
    } else if (StateContainer.of(context).wallet.history.length == 0) {
      _disposeAnimation();
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          children: <Widget>[
            _buildWelcomeTransactionCard(context),
            _buildDummyTransactionCard(
              AppLocalization.of(context).sent,
              AppLocalization.of(context).exampleCardLittle,
              AppLocalization.of(context).exampleCardTo,
              context,
            ),
            _buildDummyTransactionCard(
              AppLocalization.of(context).received,
              AppLocalization.of(context).exampleCardLot,
              AppLocalization.of(context).exampleCardFrom,
              context,
            ),
          ],
        ),
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
      );
    } else {
      _disposeAnimation();
    }
    return ReactiveRefreshIndicator(
      backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
      child: AnimatedList(
        key: _listKeyMap[StateContainer.of(context).wallet.address],
        padding: EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
        initialItemCount: StateContainer.of(context).wallet.history.length,
        itemBuilder: _buildItem,
      ),
      onRefresh: _refresh,
      isRefreshing: _isRefreshing,
    );
  }

  // Refresh list
  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    sl.get<HapticUtil>().success();
    StateContainer.of(context).requestUpdate();

    // Hide refresh indicator after 3 seconds if no server response
    Future.delayed(new Duration(seconds: 3), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  Future<void> handleDeepLink(String link) async {
    BisUrl bisUrl = await new BisUrl().getInfo(Uri.decodeFull(link));

    // Remove any other screens from stack
    Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));

    // Go to send confirm with amount
    Sheets.showAppHeightNineSheet(
        context: context,
        widget: SendConfirmSheet(
            amountRaw: bisUrl.amount,
            operation: bisUrl.operation,
            openfield: bisUrl.openfield,
            comment: bisUrl.comment,
            destination: bisUrl.address,
            contactName: bisUrl.contactName));
  }

  void paintQrCode({String address}) {
    QrPainter painter = QrPainter(
      data:
          address == null ? StateContainer.of(context).wallet.address : address,
      version: 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
      setState(() {
        receive = ReceiveSheet(
          qrWidget: Container(
              width: MediaQuery.of(context).size.width / 2.675,
              child: Image.memory(byteData.buffer.asUint8List())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _displayReleaseNote
        ? WidgetsBinding.instance
            .addPostFrameCallback((_) => displayReleaseNote())
        : null;
    // Create QR ahead of time because it improves performance this way
    if (receive == null && StateContainer.of(context).wallet != null) {
      paintQrCode();
    }

    return Scaffold(
      drawerEdgeDragWidth: 200,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context).curTheme.background,
      drawer: SizedBox(
        width: UIUtil.drawerWidth(context),
        child: Drawer(
          child: SettingsSheet(),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.045,
            bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  //Everything else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Main Card
                      _buildMainCard(context, _scaffoldKey),
                      //Main Card End

                      //Transactions Text
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(
                            30.0, 20.0, 26.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              CaseChange.toUpperCase(
                                  AppLocalization.of(context).transactions,
                                  context),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                color: StateContainer.of(context).curTheme.text,
                              ),
                            ),
                            SyncInfoView(),
                          ],
                        ),
                      ), //Transactions Text End

                      //Transactions List
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            _getListWidget(context),
                            //List Top Gradient End
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 10.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      StateContainer.of(context)
                                          .curTheme
                                          .background00,
                                      StateContainer.of(context)
                                          .curTheme
                                          .background
                                    ],
                                    begin: AlignmentDirectional(0.5, 1.0),
                                    end: AlignmentDirectional(0.5, -1.0),
                                  ),
                                ),
                              ),
                            ), // List Top Gradient End

                            //List Bottom Gradient
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 30.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      StateContainer.of(context)
                                          .curTheme
                                          .background00,
                                      StateContainer.of(context)
                                          .curTheme
                                          .background
                                    ],
                                    begin: AlignmentDirectional(0.5, -1),
                                    end: AlignmentDirectional(0.5, 0.5),
                                  ),
                                ),
                              ),
                            ), //List Bottom Gradient End
                          ],
                        ),
                      ), //Transactions List End
                      //Buttons background
                      SizedBox(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                      ), //Buttons background
                    ],
                  ),
                  // Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            StateContainer.of(context).curTheme.boxShadowButton
                          ],
                        ),
                        height: 55,
                        width: (MediaQuery.of(context).size.width - 18) / 3,
                        margin: EdgeInsetsDirectional.only(
                            start: 14, top: 0.0, end: 7.0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          color: receive != null
                              ? StateContainer.of(context).curTheme.primary
                              : StateContainer.of(context).curTheme.primary60,
                          child: AutoSizeText(
                            AppLocalization.of(context).receive,
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleButtonPrimary(context),
                            maxLines: 1,
                            stepGranularity: 0.5,
                          ),
                          onPressed: () {
                            if (receive == null) {
                              return;
                            }
                            Sheets.showAppHeightEightSheet(
                                context: context, widget: receive);
                          },
                          highlightColor: receive != null
                              ? StateContainer.of(context).curTheme.background40
                              : Colors.transparent,
                          splashColor: receive != null
                              ? StateContainer.of(context).curTheme.background40
                              : Colors.transparent,
                        ),
                      ),
                      StateContainer.of(context).wallet == null ||
                              StateContainer.of(context).wallet.tokens == null
                          ? SizedBox()
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  StateContainer.of(context)
                                      .curTheme
                                      .boxShadowButton
                                ],
                              ),
                              height: 55,
                              width:
                                  (MediaQuery.of(context).size.width - 158) / 3,
                              margin: EdgeInsetsDirectional.only(
                                  start: 7, top: 0.0, end: 7.0),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0)),
                                color:
                                    StateContainer.of(context).curTheme.primary,
                                child: Icon(Icons.scatter_plot_rounded,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .background,
                                    size: 40),
                                onPressed: () {
                                  Sheets.showAppHeightEightSheet(
                                      context: context,
                                      widget: MyTokensList(
                                          StateContainer.of(context)
                                              .wallet
                                              .tokens));
                                },
                                highlightColor: StateContainer.of(context)
                                            .wallet
                                            .tokens
                                            .length >
                                        0
                                    ? StateContainer.of(context)
                                        .curTheme
                                        .background40
                                    : Colors.transparent,
                                splashColor: StateContainer.of(context)
                                            .wallet
                                            .tokens
                                            .length >
                                        0
                                    ? StateContainer.of(context)
                                        .curTheme
                                        .background40
                                    : Colors.transparent,
                              ),
                            ),
                      AppPopupButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void displayReleaseNote() {
    _displayReleaseNote = false;
    PackageInfo.fromPlatform().then((packageInfo) {
      AppDialogs.showConfirmDialog(
          context,
          AppLocalization.of(context).releaseNoteHeader +
              " " +
              packageInfo.version,
          "- Send token from My Token List screen\n- Fix bug with deep link\n- Add icons relative to token",
          CaseChange.toUpperCase(AppLocalization.of(context).ok, context),
          () async {
        await sl.get<SharedPrefsUtil>().setVersionApp(packageInfo.version);
      });
    });
  }

  // Transaction Card/List Item
  Widget _buildTransactionCard(AddressTxsResponseResult item,
      Animation<double> animation, String displayName, BuildContext context) {
    String text;
    if (item.type == BlockTypes.SEND) {
      text = AppLocalization.of(context).sent;
    } else {
      text = AppLocalization.of(context).received;
    }
    return Slidable(
      delegate: SlidableScrollDelegate(),
      actionExtentRatio: 0.35,
      movementDuration: Duration(milliseconds: 300),
      enabled: StateContainer.of(context).wallet != null &&
          StateContainer.of(context).wallet.accountBalance > 0,
      onTriggered: (preempt) {
        if (preempt) {
          setState(() {
            releaseAnimation = true;
          });
        } else {
          // See if a contact
          sl.get<DBHelper>().getContactWithAddress(item.from).then((contact) {
            // Go to send with address
            Sheets.showAppHeightNineSheet(
                context: context,
                widget: SendSheet(
                  sendATokenActive: true,
                  localCurrency: StateContainer.of(context).curCurrency,
                  contact: contact,
                  address: item.from,
                  quickSendAmount: item.amount,
                ));
          });
        }
      },
      onAnimationChanged: (animation) {
        if (animation != null) {
          _fanimationPosition = animation.value;
          if (animation.value == 0.0 && releaseAnimation) {
            setState(() {
              releaseAnimation = false;
            });
          }
        }
      },
      secondaryActions: <Widget>[
        SlideAction(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            margin: EdgeInsetsDirectional.only(
                end: MediaQuery.of(context).size.width * 0.15,
                top: 4,
                bottom: 4),
            child: Container(
              alignment: AlignmentDirectional(-0.5, 0),
              constraints: BoxConstraints.expand(),
              child: FlareActor("assets/pulltosend_animation.flr",
                  animation: "pull",
                  fit: BoxFit.contain,
                  controller: this,
                  color: StateContainer.of(context).curTheme.primary),
            ),
          ),
        ),
      ],
      child: _SizeTransitionNoClip(
        sizeFactor: animation,
        child: Container(
          margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.backgroundDark,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [StateContainer.of(context).curTheme.boxShadow],
          ),
          child: FlatButton(
            highlightColor: StateContainer.of(context).curTheme.text15,
            splashColor: StateContainer.of(context).curTheme.text15,
            color: StateContainer.of(context).curTheme.backgroundDark,
            padding: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: TransactionDetailsSheet(
                      item: item,
                      address: item.type == BlockTypes.SEND
                          ? item.recipient
                          : item.from,
                      displayName: displayName),
                  animationDurationMs: 175);
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              item.isAliasRegister()
                                  ? Text(
                                      "Alias",
                                      textAlign: TextAlign.start,
                                      style: AppStyles.textStyleTransactionType(
                                          context),
                                    )
                                  : Text(
                                      item.blockHeight == -1
                                          ? text +
                                              " - " +
                                              AppLocalization.of(context)
                                                  .mempool
                                          : text,
                                      textAlign: TextAlign.start,
                                      style: AppStyles.textStyleTransactionType(
                                          context),
                                    ),
                              Text(
                                DateFormat.yMd(Localizations.localeOf(context)
                                        .languageCode)
                                    .add_Hms()
                                    .format(item.timestamp)
                                    .toString(),
                                style:
                                    AppStyles.textStyleTransactionUnit(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width / 2.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                double.tryParse(item
                                            .getFormattedAmount()
                                            .replaceAll(",", "")) >
                                        0
                                    ? Container(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            text: '',
                                            children: [
                                              TextSpan(
                                                text: item.type ==
                                                        BlockTypes.SEND
                                                    ? "- " +
                                                        item
                                                            .getFormattedAmount() +
                                                        " BIS"
                                                    : "+ " +
                                                        item.getFormattedAmount() +
                                                        " BIS",
                                                style: item.type ==
                                                        BlockTypes.SEND
                                                    ? AppStyles
                                                        .textStyleTransactionTypeRed(
                                                            context)
                                                    : AppStyles
                                                        .textStyleTransactionTypeGreen(
                                                            context),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                item.isTokenTransfer() == true
                                    ? Container(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            text: '',
                                            children: [
                                              TextSpan(
                                                text:
                                                    item.type == BlockTypes.SEND
                                                        ? "- " +
                                                            item
                                                                .getBisToken()
                                                                .tokensQuantity
                                                                .toString() +
                                                            " " +
                                                            item
                                                                .getBisToken()
                                                                .tokenName
                                                        : "+ " +
                                                            item
                                                                .getBisToken()
                                                                .tokensQuantity
                                                                .toString() +
                                                            " " +
                                                            item
                                                                .getBisToken()
                                                                .tokenName,
                                                style: item.type ==
                                                        BlockTypes.SEND
                                                    ? AppStyles
                                                        .textStyleTransactionTypeRed(
                                                            context)
                                                    : AppStyles
                                                        .textStyleTransactionTypeGreen(
                                                            context),
                                              ),
                                              item.getBisToken().tokenName ==
                                                      "egg"
                                                  ? TextSpan(text: " ")
                                                  : TextSpan(text: ""),
                                              item.getBisToken().tokenName ==
                                                      "egg"
                                                  ? WidgetSpan(
                                                      child: Icon(
                                                          FontAwesome5.egg,
                                                          size: AppFontSizes
                                                              .small,
                                                          color: item.type ==
                                                                  BlockTypes
                                                                      .SEND
                                                              ? Colors.red[400]
                                                              : Colors
                                                                  .green[400]),
                                                      style: item.type ==
                                                              BlockTypes.SEND
                                                          ? AppStyles
                                                              .textStyleTransactionTypeRed(
                                                                  context)
                                                          : AppStyles
                                                              .textStyleTransactionTypeGreen(
                                                                  context),
                                                    )
                                                  : TextSpan(text: "")
                                            ],
                                          ),
                                        ),
                                      )
                                    : item.isAliasRegister()
                                        ? Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  TextSpan(
                                                    text: item.openfield
                                                        .replaceAll(
                                                            "alias=", ""),
                                                    style: AppStyles
                                                        .textStyleTransactionTypeBlue(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : item.isDragginatorNew()
                                        ?
                                        Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  WidgetSpan(
                                                      child: Icon(
                                                          FontAwesome5.dragon,
                                                          size: AppFontSizes
                                                              .small,
                                                          color: Colors.blue[400]
                                                             ),
                                                    
                                                    ),
                                                  TextSpan(
                                                    text: "   new egg",
                                                    style: AppStyles
                                                        .textStyleTransactionTypeBlue(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ) :
                                        item.isDragginatorMerge()
                                        ?
                                        Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  WidgetSpan(
                                                      child: Icon(
                                                          FontAwesome5.dragon,
                                                          size: AppFontSizes
                                                              .small,
                                                          color: Colors.blue[400]
                                                             ),
                                                    
                                                    ),
                                                  TextSpan(
                                                    text: "   eggs merge",
                                                    style: AppStyles
                                                        .textStyleTransactionTypeBlue(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ) :
                                          item.isDragginator()
                                        ?
                                        Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  WidgetSpan(
                                                      child: Icon(
                                                          FontAwesome5.dragon,
                                                          size: AppFontSizes
                                                              .small,
                                                          color: Colors.blue[400]
                                                             ),
                                                    
                                                    ),
                                                  TextSpan(
                                                    text: "   " + item.operation.split(":")[1],
                                                    style: AppStyles
                                                        .textStyleTransactionTypeBlue(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ) :
                                          item.isHNRegister()
                                        ?
                                        Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  WidgetSpan(
                                                      child: Icon(
                                                          FontAwesome5.linode,
                                                          size: AppFontSizes
                                                              .small,
                                                          color: Colors.blue[400]
                                                             ),
                                                    
                                                    ),
                                                  TextSpan(
                                                    text: "  HN register",
                                                    style: AppStyles
                                                        .textStyleTransactionTypeBlue(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                /*Container(
                                  width: 26.0,
                                  height: 26.0,
                                  child: CircleAvatar(
                                    backgroundColor: StateContainer.of(context)
                                        .curTheme
                                        .text05,
                                    backgroundImage: NetworkImage(
                                      UIUtil.getRobohashURL(
                                          item.type == BlockTypes.SEND
                                              ? item.recipient
                                              : item.from),
                                    ),
                                    radius: 30.0,
                                  ),
                                ),*/
                                Text(
                                  displayName,
                                  textAlign: TextAlign.end,
                                  style: AppStyles.textStyleTransactionAddress(
                                      context),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } //Transaction Card End

  // Dummy Transaction Card
  Widget _buildDummyTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == AppLocalization.of(context).sent) {
      text = AppLocalization.of(context).sent;
      icon = AppIcons.sent;
      iconColor = StateContainer.of(context).curTheme.text60;
    } else {
      text = AppLocalization.of(context).received;
      icon = AppIcons.received;
      iconColor = StateContainer.of(context).curTheme.primary60;
    }
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: StateContainer.of(context).curTheme.text15,
        splashColor: StateContainer.of(context).curTheme.text15,
        color: StateContainer.of(context).curTheme.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsetsDirectional.only(end: 16.0),
                      child: Icon(icon, color: iconColor, size: 15),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            textAlign: TextAlign.start,
                            style: AppStyles.textStyleTransactionType(context),
                          ),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: amount,
                                  style: AppStyles.textStyleTransactionAmount(
                                      context),
                                ),
                                TextSpan(
                                  text: " BIS",
                                  style: AppStyles.textStyleTransactionUnit(
                                      context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Text(
                    address,
                    textAlign: TextAlign.end,
                    style: AppStyles.textStyleTransactionAddress(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Transaction Card End

  // Welcome Card
  TextSpan _getExampleHeaderSpan(BuildContext context) {
    String workingStr;
    if (StateContainer.of(context).selectedAccount == null ||
        StateContainer.of(context).selectedAccount.index == 0) {
      workingStr = AppLocalization.of(context).exampleCardIntro;
    } else {
      workingStr = AppLocalization.of(context).newAccountIntro;
    }
    if (!workingStr.contains("BIS")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize cryptocurrency
    List<String> splitStr = workingStr.split("BIS");
    if (splitStr.length != 2) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    return TextSpan(
      text: '',
      children: [
        TextSpan(
          text: splitStr[0],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
        TextSpan(
          text: "BIS",
          style: AppStyles.textStyleTransactionWelcomePrimary(context),
        ),
        TextSpan(
          text: splitStr[1],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeTransactionCard(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
                boxShadow: [StateContainer.of(context).curTheme.boxShadow],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getExampleHeaderSpan(context),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context).curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Loading Transaction Card
  Widget _buildLoadingTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == "Sent") {
      text = "Senttt";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.text20;
    } else {
      text = "Receiveddd";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context).curTheme.primary20;
    }
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: StateContainer.of(context).curTheme.text15,
        splashColor: StateContainer.of(context).curTheme.text15,
        color: StateContainer.of(context).curTheme.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Transaction Icon
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                          margin: EdgeInsetsDirectional.only(end: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
                                  text,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: AppFontSizes.small,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.transparent,
                                  ),
                                ),
                                Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text45,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      text,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: AppFontSizes.small - 4,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Amount Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
                                  amount,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: "Roboto",
                                      color: Colors.transparent,
                                      fontSize: AppFontSizes.smallest,
                                      fontWeight: FontWeight.w600),
                                ),
                                Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary20,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      amount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          color: Colors.transparent,
                                          fontSize: AppFontSizes.smallest - 3,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          alignment: AlignmentDirectional(1, 0),
                          children: <Widget>[
                            Text(
                              address,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: AppFontSizes.smallest,
                                fontFamily: 'OverpassMono',
                                fontWeight: FontWeight.w100,
                                color: Colors.transparent,
                              ),
                            ),
                            Opacity(
                              opacity: _opacityAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context)
                                      .curTheme
                                      .text20,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  address,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.smallest - 3,
                                    fontFamily: 'OverpassMono',
                                    fontWeight: FontWeight.w100,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // Loading Transaction Card End

  //Main Card
  Widget _buildMainCard(BuildContext context, _scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context).curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context).curTheme.boxShadow],
      ),
      margin: EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: MediaQuery.of(context).size.height * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 80.0,
            height: mainCardHeight,
            alignment: AlignmentDirectional(-1, -1),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsetsDirectional.only(
                  top: settingsIconMarginTop, start: 5),
              height: 50,
              width: 50,
              child: FlatButton(
                  highlightColor: StateContainer.of(context).curTheme.text15,
                  splashColor: StateContainer.of(context).curTheme.text15,
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Icon(FontAwesome.sliders,
                      color: StateContainer.of(context).curTheme.icon,
                      size: 24)),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: mainCardHeight,
            curve: Curves.easeInOut,
            child: _getBalanceWidget(),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: mainCardHeight == 64 ? 60 : 74,
            height: mainCardHeight == 64 ? 60 : 74,
            margin: EdgeInsets.only(right: 2),
            alignment: Alignment(0, 0),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    child: Hero(
                      tag: "avatar",
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return UIUtil.showAccountWebview(
                                context,
                                StateContainer.of(context)
                                    .selectedAccount
                                    .address);
                          }));
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              StateContainer.of(context).curTheme.text05,
                          backgroundImage: NetworkImage(StateContainer.of(context)
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
                                        .dragginatorStatus),),
                          radius: 50.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  } //Main Card

  // Get balance display
  Widget _getBalanceWidget() {
    if (StateContainer.of(context).wallet == null ||
        StateContainer.of(context).wallet.loading) {
      // Placeholder for balance text
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _priceConversion == PriceConversion.BTC
                ? Container(
                    child: Stack(
                      alignment: AlignmentDirectional(0, 0),
                      children: <Widget>[
                        Text(
                          "1234567",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w600,
                              color: Colors.transparent),
                        ),
                        Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: StateContainer.of(context).curTheme.text20,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              "1234567",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: AppFontSizes.small - 3,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 225),
              child: Stack(
                alignment: AlignmentDirectional(0, 0),
                children: <Widget>[
                  AutoSizeText(
                    "1234567",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: AppFontSizes.largestc,
                        fontWeight: FontWeight.w900,
                        color: Colors.transparent),
                    maxLines: 1,
                    stepGranularity: 0.1,
                    minFontSize: 1,
                  ),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.primary60,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: AutoSizeText(
                        "1234567",
                        style: TextStyle(
                            fontFamily: "Roboto",
                            fontSize: AppFontSizes.largestc - 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.transparent),
                        maxLines: 1,
                        stepGranularity: 0.1,
                        minFontSize: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _priceConversion == PriceConversion.BTC
                ? Container(
                    child: Stack(
                      alignment: AlignmentDirectional(0, 0),
                      children: <Widget>[
                        Text(
                          "1234567",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w600,
                              color: Colors.transparent),
                        ),
                        Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: StateContainer.of(context).curTheme.text20,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              "1234567",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: AppFontSizes.small - 3,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        ),
      );
    }
    // Balance texts
    return GestureDetector(
      onTap: () {
        if (_priceConversion == PriceConversion.BTC) {
          // Hide prices
          setState(() {
            _priceConversion = PriceConversion.NONE;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.NONE);
        } else if (_priceConversion == PriceConversion.NONE) {
          // Cycle to hidden
          setState(() {
            _priceConversion = PriceConversion.HIDDEN;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.HIDDEN);
        } else if (_priceConversion == PriceConversion.HIDDEN) {
          // Cycle to BTC price
          setState(() {
            mainCardHeight = 120;
            settingsIconMarginTop = 5;
          });
          Future.delayed(Duration(milliseconds: 150), () {
            setState(() {
              _priceConversion = PriceConversion.BTC;
            });
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.BTC);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width - 190,
        color: Colors.transparent,
        child: _priceConversion == PriceConversion.HIDDEN
            ? Center(
                child: Container(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset("assets/icon.png"),
                  ),
                ),
              )
            : Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _priceConversion == PriceConversion.BTC
                        ? Text(
                            StateContainer.of(context)
                                .wallet
                                .getLocalCurrencyPrice(
                                    StateContainer.of(context).curCurrency,
                                    locale: StateContainer.of(context)
                                        .currencyLocale),
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleCurrencyAlt(context))
                        : SizedBox(height: 0),
                    Container(
                      margin: EdgeInsetsDirectional.only(end: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 205),
                            child: AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  // Main balance text
                                  TextSpan(
                                    text: StateContainer.of(context)
                                            .wallet
                                            .getAccountBalanceDisplay() +
                                        " BIS",
                                    style: _priceConversion ==
                                            PriceConversion.BTC
                                        ? AppStyles.textStyleCurrency(context)
                                        : AppStyles.textStyleCurrencySmaller(
                                            context),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize:
                                      _priceConversion == PriceConversion.BTC
                                          ? 28
                                          : 22),
                              stepGranularity: 0.1,
                              minFontSize: 1,
                              maxFontSize:
                                  _priceConversion == PriceConversion.BTC
                                      ? 28
                                      : 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _priceConversion == PriceConversion.BTC
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  _priceConversion == PriceConversion.BTC
                                      ? AppIcons.btc
                                      // TODO : pas bon
                                      : AppIcons.accountwallet,
                                  color:
                                      _priceConversion == PriceConversion.NONE
                                          ? Colors.transparent
                                          : StateContainer.of(context)
                                              .curTheme
                                              .text60,
                                  size: 14),
                              Text(StateContainer.of(context).wallet.btcPrice,
                                  textAlign: TextAlign.center,
                                  style:
                                      AppStyles.textStyleCurrencyAlt(context)),
                            ],
                          )
                        : SizedBox(height: 0),
                  ],
                ),
              ),
      ),
    );
  }
}

class TransactionDetailsSheet extends StatefulWidget {
  final AddressTxsResponseResult item;
  final String address;
  final String displayName;

  TransactionDetailsSheet({this.item, this.address, this.displayName})
      : super();

  _TransactionDetailsSheetState createState() =>
      _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends State<TransactionDetailsSheet> {
  // Current state references
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text10,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).transactionHeader,
                                context),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),
              ],
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 0, bottom: 10),
                child: Center(
                  child: Stack(children: <Widget>[
                    SingleChildScrollView(
                        child: Padding(
                      padding: EdgeInsets.only(
                          top: 30, bottom: 80, left: 10, right: 10),
                      child: Column(
                        children: <Widget>[
                          // list
                          Stack(
                            children: <Widget>[
                              Column(
                                children: [
                                  SizedBox(height: 20),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailBlock),
                                  widget.item.blockHeight == -1
                                      ? SizedBox()
                                      : SelectableText(widget.item.blockHash,
                                          style: AppStyles
                                              .textStyleTransactionUnit(
                                                  context),
                                          textAlign: TextAlign.center),
                                  widget.item.blockHeight == -1
                                      ? Text(
                                          "(" +
                                              AppLocalization.of(context)
                                                  .mempool +
                                              ")",
                                          style: AppStyles
                                              .textStyleTransactionUnit(
                                                  context))
                                      : Text(
                                          "(" +
                                              widget.item.blockHeight
                                                  .toString() +
                                              ")",
                                          style: AppStyles
                                              .textStyleTransactionUnit(
                                                  context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailDate),
                                  Text(
                                      DateFormat.yMd(
                                              Localizations.localeOf(context)
                                                  .languageCode)
                                          .add_Hms()
                                          .format(widget.item.timestamp)
                                          .toString(),
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailFrom),
                                  SelectableText(widget.item.from,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailTo),
                                  SelectableText(widget.item.recipient,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailTxId),
                                  SelectableText(widget.item.hash,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context),
                                      textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailAmount),
                                  Text(
                                      widget.item.type == BlockTypes.SEND
                                          ? "- " +
                                              widget.item.getFormattedAmount() +
                                              " BIS"
                                          : "+ " +
                                              widget.item.getFormattedAmount() +
                                              " BIS",
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailFee),
                                  Text(
                                      "- " +
                                          widget.item.fee.toString() +
                                          " BIS",
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailReward),
                                  Text(widget.item.reward.toString() + " BIS",
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailSignature),
                                  SelectableText(widget.item.signature,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailOperation),
                                  SelectableText(widget.item.operation,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context)),
                                  SizedBox(height: 10),
                                  Text(AppLocalization.of(context)
                                      .transactionDetailOpenfield),
                                  SelectableText(widget.item.openfield,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context),
                                      textAlign: TextAlign.center),
                                  SizedBox(height: 20),
                                  Text(
                                      "* " +
                                          AppLocalization.of(context)
                                              .transactionDetailCopyPaste,
                                      style: AppStyles.textStyleTransactionUnit(
                                          context),
                                      textAlign: TextAlign.left),
                                  Column(
                                    children: <Widget>[
                                      // A stack for Copy Address and Add Contact buttons
                                      Stack(
                                        children: <Widget>[
                                          // A row for Copy Address Button
                                          Row(
                                            children: <Widget>[
                                              AppButton.buildAppButton(
                                                  context,
                                                  // Share Address Button
                                                  _addressCopied
                                                      ? AppButtonType.SUCCESS
                                                      : AppButtonType.PRIMARY,
                                                  _addressCopied
                                                      ? AppLocalization.of(
                                                              context)
                                                          .addressCopied
                                                      : AppLocalization.of(
                                                              context)
                                                          .copyAddress,
                                                  Dimens
                                                      .BUTTON_TOP_EXCEPTION_DIMENS,
                                                  onPressed: () {
                                                Clipboard.setData(
                                                    new ClipboardData(
                                                        text: widget.address));
                                                if (mounted) {
                                                  setState(() {
                                                    // Set copied style
                                                    _addressCopied = true;
                                                  });
                                                }
                                                if (_addressCopiedTimer !=
                                                    null) {
                                                  _addressCopiedTimer.cancel();
                                                }
                                                _addressCopiedTimer = new Timer(
                                                    const Duration(
                                                        milliseconds: 800), () {
                                                  if (mounted) {
                                                    setState(() {
                                                      _addressCopied = false;
                                                    });
                                                  }
                                                });
                                              }),
                                            ],
                                          ),
                                          // A row for Add Contact Button
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsetsDirectional.only(
                                                    top: Dimens
                                                            .BUTTON_TOP_EXCEPTION_DIMENS[
                                                        1],
                                                    end: Dimens
                                                        .BUTTON_TOP_EXCEPTION_DIMENS[2]),
                                                child: Container(
                                                  height: 55,
                                                  width: 55,
                                                  // Add Contact Button
                                                  child: !widget.displayName
                                                          .startsWith("@")
                                                      ? FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Sheets.showAppHeightNineSheet(
                                                                context:
                                                                    context,
                                                                widget: AddContactSheet(
                                                                    address: widget
                                                                        .address));
                                                          },
                                                          splashColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0)),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      10.0,
                                                                  horizontal:
                                                                      10),
                                                          child: Icon(
                                                              AppIcons
                                                                  .addcontact,
                                                              size: 35,
                                                              color: _addressCopied
                                                                  ? StateContainer.of(
                                                                          context)
                                                                      .curTheme
                                                                      .successDark
                                                                  : StateContainer.of(
                                                                          context)
                                                                      .curTheme
                                                                      .backgroundDark),
                                                        )
                                                      : SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                  ]),
                ),
              ),
            ),
          ],
        ));
  }
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
class _SizeTransitionNoClip extends AnimatedWidget {
  final Widget child;

  const _SizeTransitionNoClip(
      {@required Animation<double> sizeFactor, this.child})
      : super(listenable: sizeFactor);

  @override
  Widget build(BuildContext context) {
    return new Align(
      alignment: const AlignmentDirectional(-1.0, -1.0),
      widthFactor: null,
      heightFactor: (this.listenable as Animation<double>).value,
      child: child,
    );
  }
}

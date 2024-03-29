// @dart=2.9

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/dimens.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/model/available_currency.dart';
import 'package:my_bismuth_wallet/model/bis_url.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/ui/send/send_confirm_sheet.dart';
import 'package:my_bismuth_wallet/ui/util/formatters.dart';
import 'package:my_bismuth_wallet/ui/util/ui_util.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_text_field.dart';
import 'package:my_bismuth_wallet/ui/widgets/buttons.dart';
import 'package:my_bismuth_wallet/ui/widgets/one_or_three_address_text.dart';
import 'package:my_bismuth_wallet/ui/widgets/sheet_util.dart';
import 'package:my_bismuth_wallet/util/caseconverter.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';
import 'package:my_bismuth_wallet/util/user_data_util.dart';

class SendSheet extends StatefulWidget {
  final AvailableCurrency localCurrency;
  final Contact contact;
  final String address;
  final String operation;
  final String openfield;
  final String quickSendAmount;
  final String title;
  final String actionButtonTitle;
  final bool sendATokenActive;
  final String selectedTokenName;

  SendSheet(
      {@required this.localCurrency,
      this.contact,
      this.address,
      this.operation,
      this.openfield,
      this.quickSendAmount,
      this.title,
      this.actionButtonTitle,
      this.selectedTokenName,
      @required this.sendATokenActive})
      : super();

  _SendSheetState createState() => _SendSheetState();
}

enum AddressStyle { TEXT60, TEXT90, PRIMARY }

class _SendSheetState extends State<SendSheet> {
  final Logger log = sl.get<Logger>();

  FocusNode _sendAddressFocusNode;
  TextEditingController _sendAddressController;
  FocusNode _sendAmountFocusNode;
  TextEditingController _sendAmountController;
  FocusNode _sendOpenfieldFocusNode;
  TextEditingController _sendOpenfieldController;
  FocusNode _sendOperationFocusNode;
  TextEditingController _sendOperationController;
  FocusNode _sendTokenQuantityFocusNode;
  TextEditingController _sendTokenQuantityController;
  FocusNode _sendCommentFocusNode;
  TextEditingController _sendCommentController;

  // States
  AddressStyle _sendAddressStyle;
  String _amountHint = "";
  String _addressHint = "";
  String _openfieldHint = "";
  String _operationHint = "";
  String _commentHint = "";
  String _tokenQuantityHint = "";
  String _amountValidationText = "";
  String _tokenQuantityValidationText = "";
  String _tokenValidationText = "";
  String _addressValidationText = "";
  String _openfieldValidationText = "";
  String _operationValidationText = "";
  String _selectedTokenName = "";
  String quickSendAmount;
  List<Contact> _contacts;
  bool animationOpen;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a contact is being entered
  bool _isContact = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _showContactButton = true;
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  NumberFormat _localCurrencyFormat;
  bool isTokenToSendSwitched = false;
  String _rawAmount;
  String _rawTokenQuantity;
  bool validRequest = true;

  @override
  void initState() {
    super.initState();
    _sendAmountFocusNode = FocusNode();
    _sendAddressFocusNode = FocusNode();
    _sendOpenfieldFocusNode = FocusNode();
    _sendOperationFocusNode = FocusNode();
    _sendCommentFocusNode = FocusNode();
    _sendTokenQuantityFocusNode = FocusNode();
    _sendAmountController = TextEditingController();
    _sendAddressController = TextEditingController();
    _sendOpenfieldController = TextEditingController();
    _sendOperationController = TextEditingController();
    _sendCommentController = TextEditingController();
    _sendTokenQuantityController = TextEditingController();
    _sendAddressStyle = AddressStyle.TEXT60;
    _contacts = List();
    _selectedTokenName = widget.selectedTokenName;
    quickSendAmount = widget.quickSendAmount;
    this.animationOpen = false;
    if (widget.contact != null) {
      // Setup initial state for contact pre-filled
      _sendAddressController.text = widget.contact.name;
      _isContact = true;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _sendAddressStyle = AddressStyle.PRIMARY;
    } else if (widget.address != null) {
      // Setup initial state with prefilled address
      _sendAddressController.text = widget.address;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _sendAddressStyle = AddressStyle.TEXT90;
      _addressValidAndUnfocused = true;
    }

    if (widget.operation != null) {
      _sendOperationController.text = widget.operation;
      if (widget.operation == AddressTxsResponseResult.TOKEN_TRANSFER) {
        isTokenToSendSwitched = true;
      }
    }
    if (widget.openfield != null) {
      _sendOpenfieldController.text = widget.openfield;
    }
    // On amount focus change
    _sendAmountFocusNode.addListener(() {
      if (_sendAmountFocusNode.hasFocus) {
        if (_rawAmount != null) {
          setState(() {
            _sendAmountController.text =
                NumberUtil.getRawAsUsableString(_rawAmount).replaceAll(",", "");
            _rawAmount = null;
          });
        }
        if (quickSendAmount != null) {
          _sendAmountController.text = "";
          setState(() {
            quickSendAmount = null;
          });
        }
        setState(() {
          _amountHint = null;
        });
      } else {
        setState(() {
          _amountHint = "";
        });
      }
    });
    // On address focus change
    _sendAddressFocusNode.addListener(() {
      if (_sendAddressFocusNode.hasFocus) {
        setState(() {
          _addressHint = null;
          //_addressValidAndUnfocused = false;
        });
        _sendAddressController.selection = TextSelection.fromPosition(
            TextPosition(offset: _sendAddressController.text.length));
        if (_sendAddressController.text.startsWith("@")) {
          sl
              .get<DBHelper>()
              .getContactsWithNameLike(_sendAddressController.text)
              .then((contactList) {
            setState(() {
              _contacts = contactList;
            });
          });
        }
      } else {
        setState(() {
          _addressHint = "";
          _contacts = [];
          if (Address(_sendAddressController.text).isValid()) {
            //_addressValidAndUnfocused = true;
          }
        });
        if (_sendAddressController.text.trim() == "@") {
          _sendAddressController.text = "";
          setState(() {
            _showContactButton = true;
          });
        }
      }
    });
    // On openfield focus change
    _sendOpenfieldFocusNode.addListener(() {
      if (_sendOpenfieldFocusNode.hasFocus) {
        setState(() {
          _openfieldHint = null;
        });
      } else {
        setState(() {
          _openfieldHint = "";
        });
      }
    });
    // On operation focus change
    _sendOperationFocusNode.addListener(() {
      if (_sendOperationFocusNode.hasFocus) {
        setState(() {
          _operationHint = null;
        });
      } else {
        setState(() {
          _operationHint = "";
        });
      }
    });

    // On comment focus change
    _sendCommentFocusNode.addListener(() {
      if (_sendCommentFocusNode.hasFocus) {
        setState(() {
          _commentHint = null;
        });
      } else {
        setState(() {
          _commentHint = "";
        });
      }
    });

    // On token quantity focus change
    _sendTokenQuantityFocusNode.addListener(() {
      if (_sendTokenQuantityFocusNode.hasFocus) {
        if (_rawTokenQuantity != null) {
          setState(() {
            _sendTokenQuantityController.text =
                NumberUtil.getRawAsUsableString(_rawTokenQuantity)
                    .replaceAll(",", "");
            _rawTokenQuantity = null;
          });
        }
        setState(() {
          _tokenQuantityHint = null;
        });
      } else {
        setState(() {
          _tokenQuantityHint = "";
        });
      }
    });
    // Set initial currency format
    _localCurrencyFormat = NumberFormat.currency(
        locale: widget.localCurrency.getLocale().toString(),
        symbol: widget.localCurrency.getCurrencySymbol());
    // Set quick send amount
    if (quickSendAmount != null) {
      _sendAmountController.text =
          NumberUtil.getRawAsUsableString(quickSendAmount).replaceAll(",", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    // The main column that holds everything
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the header of the sheet, balance text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 60,
                ),

                // Container for the header, address and balance text
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
                                widget.title == null
                                    ? AppLocalization.of(context).sendFrom
                                    : widget.title,
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

            Container(
              margin: EdgeInsets.only(top: 0.0, left: 30, right: 30),
              child: Container(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: StateContainer.of(context).selectedAccount.name,
                        style: TextStyle(
                          color: StateContainer.of(context).curTheme.text60,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Address Text
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: OneOrThreeLineAddressText(
                  address: StateContainer.of(context).wallet.address,
                  type: AddressTextType.PRIMARY60),
            ),

            // A main container that holds everything
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 0, bottom: 10),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // Clear focus of our fields when tapped in this empty space
                        _sendAddressFocusNode.unfocus();
                        _sendAmountFocusNode.unfocus();
                        _sendOpenfieldFocusNode.unfocus();
                        _sendOperationFocusNode.unfocus();
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: SizedBox.expand(),
                        constraints: BoxConstraints.expand(),
                      ),
                    ),
                    // A column for Enter Amount, Enter Address, Error containers and the pop up list
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30, bottom: bottom + 80),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                // Column for Balance Text, Enter Amount container + Enter Amount Error container
                                Column(
                                  children: <Widget>[
                                    // Balance Text
                                    FutureBuilder(
                                      future: sl
                                          .get<SharedPrefsUtil>()
                                          .getPriceConversion(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null &&
                                            snapshot.data !=
                                                PriceConversion.HIDDEN) {
                                          return Container(
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(
                                                text: '',
                                                children: [
                                                  TextSpan(
                                                    text: "(",
                                                    style: TextStyle(
                                                      color: StateContainer.of(
                                                              context)
                                                          .curTheme
                                                          .primary60,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _localCurrencyMode
                                                        ? StateContainer.of(
                                                                context)
                                                            .wallet
                                                            .getLocalCurrencyPrice(
                                                                StateContainer.of(
                                                                        context)
                                                                    .curCurrency,
                                                                locale: StateContainer.of(
                                                                        context)
                                                                    .currencyLocale)
                                                        : StateContainer.of(
                                                                context)
                                                            .wallet
                                                            .getAccountBalanceDisplay(),
                                                    style: TextStyle(
                                                      color: StateContainer.of(
                                                              context)
                                                          .curTheme
                                                          .primary60,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _localCurrencyMode
                                                        ? ")"
                                                        : " BIS)",
                                                    style: TextStyle(
                                                      color: StateContainer.of(
                                                              context)
                                                          .curTheme
                                                          .primary60,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return Container(
                                          child: Text(
                                            "*******",
                                            style: TextStyle(
                                              color: Colors.transparent,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // ******* Enter Amount Container ******* //
                                    getEnterAmountContainer(),
                                    // ******* Enter Amount Container End ******* //

                                    // ******* Enter Amount Error Container ******* //
                                    Container(
                                      alignment: AlignmentDirectional(0, 0),
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(_amountValidationText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    // ******* Enter Amount Error Container End ******* //
                                  ],
                                ),

                                // Column for Enter Address container + Enter Address Error container
                                Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.105,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.105),
                                            alignment: Alignment.bottomCenter,
                                            constraints: BoxConstraints(
                                                maxHeight: 174, minHeight: 0),
                                            // ********************************************* //
                                            // ********* The pop-up Contacts List ********* //
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .backgroundDarkest,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom: 50),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.only(
                                                        bottom: 0, top: 0),
                                                    itemCount: _contacts.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return _buildContactItem(
                                                          _contacts[index]);
                                                    },
                                                  ), // ********* The pop-up Contacts List End ********* //
                                                  // ************************************************** //
                                                ),
                                              ),
                                            ),
                                          ),

                                          // ******* Enter Address Container ******* //
                                          getEnterAddressContainer(),
                                          // ******* Enter Address Container End ******* //
                                        ],
                                      ),
                                    ),

                                    // ******* Enter Address Error Container ******* //
                                    Container(
                                      alignment: AlignmentDirectional(0, 0),
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(_addressValidationText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    // ******* Enter Address Error Container End ******* //

                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      child: Text(
                                        "+ " +
                                            AppLocalization.of(context).fees +
                                            ": " +
                                            sl
                                                .get<AppService>()
                                                .getFeesEstimation(
                                                    _sendOpenfieldController
                                                            .text +
                                                        _sendCommentController
                                                            .text,
                                                    _sendOperationController
                                                        .text)
                                                .toStringAsFixed(5) +
                                            " BIS",
                                        style: TextStyle(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .primary60,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                AppLocalization.of(context)
                                                    .pasteBisUrl,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: 'Roboto',
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .text60,
                                                ),
                                              ),
                                              Text(
                                                AppLocalization.of(context)
                                                    .pasteBisUrlPrefix,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: 'Roboto',
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .text60,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (!_pasteButtonVisible) {
                                                return;
                                              }
                                              Clipboard.getData("text/plain")
                                                  .then((ClipboardData
                                                      data) async {
                                                if (data == null ||
                                                    data.text == null ||
                                                    data.text.contains(
                                                            "bis://") ==
                                                        false) {
                                                  UIUtil.showSnackbar(
                                                      AppLocalization.of(
                                                              context)
                                                          .pasteBisUrlError,
                                                      context);

                                                  return;
                                                }
                                                BisUrl bisUrl =
                                                    await new BisUrl()
                                                        .getInfo(data.text);
                                                setState(() {
                                                  _addressValidationText = "";
                                                  _amountValidationText = "";
                                                  _tokenValidationText = "";
                                                  _tokenQuantityValidationText =
                                                      "";
                                                  _openfieldValidationText = "";
                                                  _operationValidationText = "";
                                                  _sendAddressController.text =
                                                      bisUrl.address;
                                                  _sendAmountController.text =
                                                      bisUrl.amount;
                                                  _sendCommentController.text =
                                                      bisUrl.comment;
                                                  _sendOpenfieldController
                                                      .text = bisUrl.openfield;
                                                  _sendOperationController
                                                      .text = bisUrl.operation;
                                                  isTokenToSendSwitched =
                                                      bisUrl.isTokenToSend;
                                                  _sendTokenQuantityController
                                                          .text =
                                                      bisUrl.tokenToSendQty
                                                          .toString();
                                                  _selectedTokenName =
                                                      bisUrl.tokenName;

                                                  validRequest =
                                                      _validateRequest();
                                                });
                                              });
                                            },
                                            child: Icon(AppIcons.paste,
                                                size: 20,
                                                color:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .icon),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      child: Text(
                                        CaseChange.toUpperCase(
                                            AppLocalization.of(context)
                                                .optionalParameters,
                                            context),
                                        style: TextStyle(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text60,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      child: Text(
                                        AppLocalization.of(context).diacritic,
                                        style: TextStyle(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .primary60,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                    widget.sendATokenActive
                                        ? Container(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppLocalization.of(context)
                                                    .sendATokenQuestion,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: 'Roboto',
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .text60,
                                                ),
                                              ),
                                              Switch(
                                                  value: isTokenToSendSwitched,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      isTokenToSendSwitched =
                                                          value;
                                                      _sendOpenfieldController =
                                                          TextEditingController();
                                                      _sendOperationController =
                                                          TextEditingController();
                                                      _sendTokenQuantityController =
                                                          TextEditingController();
                                                      _sendCommentController =
                                                          TextEditingController();
                                                      _selectedTokenName = "";
                                                    });
                                                  },
                                                  activeTrackColor:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .backgroundDarkest,
                                                  activeColor: Colors.green),
                                            ],
                                          ))
                                        : SizedBox(),
                                    isTokenToSendSwitched == false
                                        ? Column(
                                            children: [
                                              Container(
                                                child:
                                                    getEnterOperationContainer(),
                                              ),
                                              Container(
                                                child:
                                                    getEnterOpenfieldContainer(),
                                              ),
                                            ],
                                          )
                                        : Column(children: [
                                            Container(
                                                child:
                                                    getEnterTokenContainer()),
                                            Container(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              margin: EdgeInsets.only(top: 3),
                                              child: Text(_tokenValidationText,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: StateContainer.of(
                                                            context)
                                                        .curTheme
                                                        .primary,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                            ),
                                            Container(
                                                child:
                                                    getEnterTokensQuantityContainer()),
                                            Container(
                                              alignment:
                                                  AlignmentDirectional(0, 0),
                                              margin: EdgeInsets.only(top: 3),
                                              child: Text(
                                                  _tokenQuantityValidationText,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: StateContainer.of(
                                                            context)
                                                        .curTheme
                                                        .primary,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                            ),
                                            Container(
                                              child: getEnterCommentContainer(),
                                            ),
                                          ]),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    //List Top Gradient End
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 30.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              StateContainer.of(context).curTheme.background00,
                              StateContainer.of(context).curTheme.background
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
                              StateContainer.of(context).curTheme.background00,
                              StateContainer.of(context).curTheme.background
                            ],
                            begin: AlignmentDirectional(0.5, -1),
                            end: AlignmentDirectional(0.5, 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //A column with "Scan QR Code" and "Send" buttons
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Send Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          widget.actionButtonTitle == null
                              ? AppLocalization.of(context).send
                              : widget.actionButtonTitle,
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        validRequest = _validateRequest();
                        if (_sendAddressController.text.startsWith("@") &&
                            validRequest) {
                          // Need to make sure its a valid contact
                          sl
                              .get<DBHelper>()
                              .getContactWithName(_sendAddressController.text)
                              .then((contact) {
                            if (contact == null) {
                              setState(() {
                                _addressValidationText =
                                    AppLocalization.of(context).contactInvalid;
                              });
                            } else {
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: SendConfirmSheet(
                                      title: widget.title,
                                      amountRaw: _localCurrencyMode
                                          ? NumberUtil.getAmountAsRaw(
                                              _convertLocalCurrencyToCrypto())
                                          : _rawAmount == null
                                              ? NumberUtil.getAmountAsRaw(
                                                  _sendAmountController.text)
                                              : _rawAmount,
                                      destination: contact.address,
                                      contactName: contact.name,
                                      operation: _sendOperationController.text,
                                      openfield: _sendOpenfieldController.text,
                                      maxSend: _isMaxSend(),
                                      comment: _sendCommentController.text,
                                      localCurrency: _localCurrencyMode
                                          ? _sendAmountController.text
                                          : null));
                            }
                          });
                        } else if (validRequest) {
                          Sheets.showAppHeightNineSheet(
                              context: context,
                              widget: SendConfirmSheet(
                                  title: widget.title,
                                  amountRaw: _localCurrencyMode
                                      ? NumberUtil.getAmountAsRaw(
                                          _convertLocalCurrencyToCrypto())
                                      : _rawAmount == null
                                          ? NumberUtil.getAmountAsRaw(
                                              _sendAmountController.text)
                                          : _rawAmount,
                                  destination: _sendAddressController.text,
                                  operation: _sendOperationController.text,
                                  openfield: _sendOpenfieldController.text,
                                  comment: _sendCommentController.text,
                                  maxSend: _isMaxSend(),
                                  localCurrency: _localCurrencyMode
                                      ? _sendAmountController.text
                                      : null));
                        }
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Scan QR Code Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).scanQrCode,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                        UIUtil.cancelLockEvent();
                        String scanResult = await UserDataUtil.getQRData(
                            DataType.ADDRESS, context);
                        if (scanResult == null) {
                          UIUtil.showSnackbar(
                              AppLocalization.of(context).qrInvalidAddress,
                              context);
                        } else if (QRScanErrs.ERROR_LIST.contains(scanResult)) {
                          return;
                        } else {
                          if (scanResult.contains("bis://")) {
                            BisUrl bisUrl =
                                await new BisUrl().getInfo(scanResult);
                            setState(() {
                              _addressValidationText = "";
                              _amountValidationText = "";
                              _tokenValidationText = "";
                              _tokenQuantityValidationText = "";
                              _openfieldValidationText = "";
                              _operationValidationText = "";
                              _sendAddressController.text = bisUrl.address;
                              _sendAmountController.text = bisUrl.amount;
                              _sendCommentController.text = bisUrl.comment;
                              _sendOpenfieldController.text = bisUrl.openfield;
                              _sendOperationController.text = bisUrl.operation;
                              isTokenToSendSwitched = bisUrl.isTokenToSend;
                              _sendTokenQuantityController.text =
                                  bisUrl.tokenToSendQty.toString();
                              _selectedTokenName = bisUrl.tokenName;

                              validRequest = _validateRequest();
                            });
                            return;
                          }

                          // Is a URI
                          Address address = Address(scanResult);
                          // See if this address belongs to a contact
                          Contact contact = await sl
                              .get<DBHelper>()
                              .getContactWithAddress(address.address);
                          if (contact == null) {
                            // Not a contact
                            if (mounted) {
                              setState(() {
                                _isContact = false;
                                _addressValidationText = "";
                                _sendAddressStyle = AddressStyle.TEXT90;
                                _pasteButtonVisible = false;
                                _showContactButton = false;
                              });
                              _sendAddressController.text = address.address;
                              _sendAddressFocusNode.unfocus();
                              setState(() {
                                _addressValidAndUnfocused = true;
                              });
                            }
                          } else {
                            // Is a contact
                            if (mounted) {
                              setState(() {
                                _isContact = true;
                                _addressValidationText = "";
                                _sendAddressStyle = AddressStyle.PRIMARY;
                                _pasteButtonVisible = false;
                                _showContactButton = false;
                              });
                              _sendAddressController.text = contact.name;
                            }
                          }
                          // If amount is present, fill it and go to SendConfirm
                          if (address.amount != null) {
                            bool hasError = false;
                            BigInt amountBigInt =
                                BigInt.tryParse(address.amount);
                            if (amountBigInt != null &&
                                amountBigInt < BigInt.from(10).pow(24)) {
                              hasError = true;
                              UIUtil.showSnackbar(
                                  AppLocalization.of(context)
                                      .minimumSend
                                      .replaceAll("%1", "0.000001"),
                                  context);
                            } else if (_localCurrencyMode && mounted) {
                              toggleLocalCurrency();
                              _sendAmountController.text =
                                  NumberUtil.getRawAsUsableString(
                                      address.amount);
                            } else if (mounted) {
                              setState(() {
                                _rawAmount = address.amount;
                                // If raw amount has more precision than we support show a special indicator
                                if (NumberUtil.getRawAsUsableString(_rawAmount)
                                        .replaceAll(",", "") ==
                                    NumberUtil.getRawAsUsableDecimal(_rawAmount)
                                        .toString()) {
                                  _sendAmountController.text =
                                      NumberUtil.getRawAsUsableString(
                                              _rawAmount)
                                          .replaceAll(",", "");
                                } else {
                                  _sendAmountController
                                      .text = NumberUtil.truncateDecimal(
                                              NumberUtil.getRawAsUsableDecimal(
                                                  address.amount),
                                              digits: 6)
                                          .toStringAsFixed(6) +
                                      "~";
                                }
                              });
                              _sendAddressFocusNode.unfocus();
                            }

                            if (!hasError) {
                              // Go to confirm sheet
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: SendConfirmSheet(
                                      title: widget.title,
                                      amountRaw: _localCurrencyMode
                                          ? NumberUtil.getAmountAsRaw(
                                              _convertLocalCurrencyToCrypto())
                                          : _rawAmount == null
                                              ? NumberUtil.getAmountAsRaw(
                                                  _sendAmountController.text)
                                              : _rawAmount,
                                      destination: contact != null
                                          ? contact.address
                                          : address.address,
                                      contactName:
                                          contact != null ? contact.name : null,
                                      maxSend: _isMaxSend(),
                                      localCurrency: _localCurrencyMode
                                          ? _sendAmountController.text
                                          : null));
                            }
                          }
                        }
                      })
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  String _convertLocalCurrencyToCrypto() {
    String convertedAmt = _sendAmountController.text.replaceAll(",", ".");
    convertedAmt = NumberUtil.sanitizeNumber(convertedAmt);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(
        StateContainer.of(context).wallet.localCurrencyConversion);
    return NumberUtil.truncateDecimal(valueLocal / conversion).toString();
  }

  String _convertCryptoToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(_sendAmountController.text,
        maxDecimalDigits: 2);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(
        StateContainer.of(context).wallet.localCurrencyConversion);
    convertedAmt =
        NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 2)
            .toString();
    convertedAmt =
        convertedAmt.replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  String _convertFeesToLocalCurrency() {
    String convertedAmt = NumberUtil.sanitizeNumber(
        sl
            .get<AppService>()
            .getFeesEstimation(
                _sendOpenfieldController.text + _sendCommentController.text,
                _sendOperationController.text)
            .toStringAsFixed(5),
        maxDecimalDigits: 5);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(
        StateContainer.of(context).wallet.localCurrencyConversion);
    convertedAmt =
        NumberUtil.truncateDecimal(valueCrypto * conversion, digits: 5)
            .toString();
    convertedAmt =
        convertedAmt.replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend() {
    // Sanitize commas
    if (_sendAmountController.text.isEmpty) {
      return false;
    }
    try {
      String textField = _sendAmountController.text;

      String balance;
      if (_localCurrencyMode) {
        balance = StateContainer.of(context).wallet.getLocalCurrencyPrice(
            StateContainer.of(context).curCurrency,
            locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = StateContainer.of(context)
            .wallet
            .getAccountBalanceDisplay()
            .replaceAll(r",", "");
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        String sanitizedTextField = NumberUtil.sanitizeNumber(textField);
        balance =
            balance.replaceAll(_localCurrencyFormat.symbols.GROUP_SEP, "");
        balance = balance.replaceAll(",", ".");
        String sanitizedBalance = NumberUtil.sanitizeNumber(balance);
        textFieldInt = (Decimal.parse(sanitizedTextField) *
                Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits)))
            .toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) *
                Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits)))
            .toInt();
      } else {
        textField = textField.replaceAll(",", "");
        textFieldInt = (Decimal.parse(textField) *
                Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits)))
            .toInt();
        balanceInt = (Decimal.parse(balance) *
                Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits)))
            .toInt();
      }

      int estimationFeesInt = (Decimal.parse(sl
                  .get<AppService>()
                  .getFeesEstimation(
                      _sendOpenfieldController.text +
                          _sendCommentController.text,
                      _sendOperationController.text)
                  .toString()) *
              Decimal.fromInt(pow(10, NumberUtil.maxDecimalDigits)))
          .toInt();

      return textFieldInt + estimationFeesInt == balanceInt;
    } catch (e) {
      return false;
    }
  }

  void toggleLocalCurrency() {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what cryptocurrency is worth
    // this way you can tap button and tap back and not end up with X.9993451 cryptocurrency
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      String cryptoAmountStr;
      // Check out previous state
      if (_sendAmountController.text == _lastLocalCurrencyAmount) {
        cryptoAmountStr = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = _sendAmountController.text;
        _lastCryptoAmount = _convertLocalCurrencyToCrypto();
        cryptoAmountStr = _lastCryptoAmount;
      }
      setState(() {
        _localCurrencyMode = false;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController.text = cryptoAmountStr;
        _sendAmountController.selection = TextSelection.fromPosition(
            TextPosition(offset: cryptoAmountStr.length));
      });
    } else {
      // Switching to local-currency mode
      String localAmountStr;
      // Check our previous state
      if (_sendAmountController.text == _lastCryptoAmount) {
        localAmountStr = _lastLocalCurrencyAmount;
      } else {
        _lastCryptoAmount = _sendAmountController.text;
        _lastLocalCurrencyAmount = _convertCryptoToLocalCurrency();
        localAmountStr = _lastLocalCurrencyAmount;
      }
      setState(() {
        _localCurrencyMode = true;
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _sendAmountController.text = localAmountStr;
        _sendAmountController.selection = TextSelection.fromPosition(
            TextPosition(offset: localAmountStr.length));
      });
    }
  }

  // Build contact items for the list
  Widget _buildContactItem(Contact contact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 42,
          width: double.infinity - 5,
          child: TextButton(
            onPressed: () {
              _sendAddressController.text = contact.name;
              _sendAddressFocusNode.unfocus();
              setState(() {
                _isContact = true;
                _showContactButton = false;
                _pasteButtonVisible = false;
                _sendAddressStyle = AddressStyle.PRIMARY;
              });
            },
            child: Text(contact.name,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleAddressText90(context)),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: StateContainer.of(context).curTheme.text03,
        ),
      ],
    );
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  bool _validateRequest() {
    bool isValid = true;
    _sendAmountFocusNode.unfocus();
    _sendAddressFocusNode.unfocus();
    _sendAddressFocusNode.unfocus();
    // Validate amount
    if (_sendAmountController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = AppLocalization.of(context).amountMissing;
      });
    } else {
      // Estimation of fees
      double estimationFees = sl.get<AppService>().getFeesEstimation(
          _sendOpenfieldController.text + _sendCommentController.text,
          _sendOperationController.text);

      String amount = _localCurrencyMode
          ? _convertLocalCurrencyToCrypto()
          : _rawAmount == null
              ? _sendAmountController.text
              : NumberUtil.getRawAsUsableString(_rawAmount);
      double balanceRaw = StateContainer.of(context).wallet.accountBalance;
      double sendAmount = double.tryParse(amount);
      if (sendAmount == null) {
        isValid = false;
        setState(() {
          _amountValidationText = AppLocalization.of(context).amountMissing;
        });
      } else if (sendAmount + estimationFees > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText =
              AppLocalization.of(context).insufficientBalance;
        });
      }
    }
    // Validate address
    bool isContact = _sendAddressController.text.startsWith("@");
    if (_sendAddressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).addressMising;
        _pasteButtonVisible = true;
      });
    } else if (!isContact && !Address(_sendAddressController.text).isValid()) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).invalidAddress;
        _pasteButtonVisible = true;
      });
    } else if (!isContact) {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
      _sendAddressFocusNode.unfocus();
    }

    // Validate token
    if (isTokenToSendSwitched) {
      if (_selectedTokenName.isEmpty) {
        isValid = false;
        setState(() {
          _tokenValidationText = AppLocalization.of(context).tokenMissing;
        });
      } else {
        bool tokenInList = false;
        for (int i = 0;
            i < StateContainer.of(context).wallet.tokens.length;
            i++) {
          if (StateContainer.of(context).wallet.tokens[i].tokenName ==
              _selectedTokenName) {
            tokenInList = true;
            break;
          }
        }

        if (tokenInList == false) {
          isValid = false;
          setState(() {
            _tokenValidationText = AppLocalization.of(context).noTokenOwner +
                " '" +
                _selectedTokenName +
                "'";
          });
        }
      }
      if (_sendTokenQuantityController.text.trim().isEmpty ||
          int.tryParse(_sendTokenQuantityController.text.trim()) == 0) {
        isValid = false;
        setState(() {
          _tokenQuantityValidationText =
              AppLocalization.of(context).tokenQuantityMissing;
        });
      } else {
        if (_selectedTokenName.isEmpty == false) {
          for (int i = 0;
              i < StateContainer.of(context).wallet.tokens.length;
              i++) {
            if (StateContainer.of(context).wallet.tokens[i].tokenName ==
                _selectedTokenName) {
              if (int.tryParse(_sendTokenQuantityController.text).compareTo(
                      StateContainer.of(context)
                          .wallet
                          .tokens[i]
                          .tokensQuantity) >
                  0) {
                isValid = false;

                setState(() {
                  _tokenQuantityValidationText =
                      AppLocalization.of(context).insufficientTokenQuantity;
                });
              }
            }
          }
        }
      }
    }

    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  getEnterAmountContainer() {
    return AppTextField(
      focusNode: _sendAmountFocusNode,
      controller: _sendAmountController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'Roboto',
      ),
      inputFormatters: _rawAmount == null
          ? [
              LengthLimitingTextInputFormatter(16),
              _localCurrencyMode
                  ? CurrencyFormatter(
                      decimalSeparator:
                          _localCurrencyFormat.symbols.DECIMAL_SEP,
                      commaSeparator: _localCurrencyFormat.symbols.GROUP_SEP,
                      maxDecimalDigits: 8)
                  : CurrencyFormatter(
                      maxDecimalDigits: NumberUtil.maxDecimalDigits),
              LocalCurrencyFormatter(
                  active: _localCurrencyMode,
                  currencyFormat: _localCurrencyFormat)
            ]
          : [LengthLimitingTextInputFormatter(16)],
      onChanged: (text) {
        // Always reset the error message to be less annoying
        setState(() {
          _amountValidationText = "";
          // Reset the raw amount
          _rawAmount = null;
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText:
          _amountHint == null ? "" : AppLocalization.of(context).enterAmount,
      suffixButton: TextFieldButton(
        icon: AppIcons.max,
        onPressed: () {
          setState(() {
            _amountValidationText = "";
            // Reset the raw amount
            _rawAmount = null;
          });
          if (_isMaxSend()) {
            return;
          }

          if (!_localCurrencyMode) {
            double estimationFees = sl.get<AppService>().getFeesEstimation(
                _sendOpenfieldController.text + _sendCommentController.text,
                _sendOperationController.text);
            _sendAmountController.text = StateContainer.of(context)
                .wallet
                .getAccountBalanceMoinsFeesDisplay(estimationFees)
                .replaceAll(r",", "");
            _sendAddressController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendAddressController.text.length));
          } else {
            String feeString = _convertFeesToLocalCurrency();
            feeString = feeString.replaceAll(
                _localCurrencyFormat.symbols.GROUP_SEP, "");
            feeString = feeString.replaceAll(
                _localCurrencyFormat.symbols.DECIMAL_SEP, ".");
            feeString = NumberUtil.sanitizeNumber(feeString)
                .replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);

            String localAmount = StateContainer.of(context)
                .wallet
                .getLocalCurrencyPriceMoinsFees(
                    StateContainer.of(context).curCurrency,
                    double.tryParse(feeString),
                    locale: StateContainer.of(context).currencyLocale);
            localAmount = localAmount.replaceAll(
                _localCurrencyFormat.symbols.GROUP_SEP, "");
            localAmount = localAmount.replaceAll(
                _localCurrencyFormat.symbols.DECIMAL_SEP, ".");
            localAmount = NumberUtil.sanitizeNumber(localAmount)
                .replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
            _sendAmountController.text =
                _localCurrencyFormat.currencySymbol + localAmount;
            _sendAddressController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendAddressController.text.length));
          }
        },
      ),
      fadeSuffixOnCondition: true,
      suffixShowFirstCondition: !_isMaxSend(),
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: true),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
        if (!Address(_sendAddressController.text).isValid()) {
          FocusScope.of(context).requestFocus(_sendAddressFocusNode);
        }
      },
    );
  } //************ Enter Amount Container Method End ************//
  //*************************************************************//

  //************ Enter Address Container Method ************//
  //*******************************************************//
  getEnterAddressContainer() {
    return AppTextField(
        topMargin: 124,
        padding: _addressValidAndUnfocused
            ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0)
            : EdgeInsets.zero,
        textAlign: _isContact && false ? TextAlign.start : TextAlign.center,
        focusNode: _sendAddressFocusNode,
        controller: _sendAddressController,
        cursorColor: StateContainer.of(context).curTheme.primary,
        inputFormatters: [
          _isContact
              ? LengthLimitingTextInputFormatter(20)
              : LengthLimitingTextInputFormatter(65),
        ],
        textInputAction: TextInputAction.done,
        maxLines: null,
        autocorrect: false,
        hintText: _addressHint == null
            ? ""
            : AppLocalization.of(context).enterAddress,
        prefixButton: TextFieldButton(
          icon: AppIcons.at,
          onPressed: () {
            if (_showContactButton && _contacts.length == 0) {
              // Show menu
              FocusScope.of(context).requestFocus(_sendAddressFocusNode);
              if (_sendAddressController.text.length == 0) {
                _sendAddressController.text = "@";
                _sendAddressController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _sendAddressController.text.length));
              }
              sl.get<DBHelper>().getContacts().then((contactList) {
                setState(() {
                  _contacts = contactList;
                });
              });
            }
          },
        ),
        fadePrefixOnCondition: true,
        prefixShowFirstCondition: _showContactButton && _contacts.length == 0,
        suffixButton: TextFieldButton(
          icon: AppIcons.paste,
          onPressed: () {
            if (!_pasteButtonVisible) {
              return;
            }
            Clipboard.getData("text/plain").then((ClipboardData data) {
              if (data == null || data.text == null) {
                return;
              }
              Address address = Address(data.text);
              if (address.isValid()) {
                sl
                    .get<DBHelper>()
                    .getContactWithAddress(address.address)
                    .then((contact) {
                  if (contact == null) {
                    setState(() {
                      _isContact = false;
                      _addressValidationText = "";
                      _sendAddressStyle = AddressStyle.TEXT90;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _sendAddressController.text = address.address;
                    //_sendAddressFocusNode.unfocus();
                    setState(() {
                      //_addressValidAndUnfocused = true;
                    });
                  } else {
                    // Is a contact
                    setState(() {
                      _isContact = true;
                      _addressValidationText = "";
                      _sendAddressStyle = AddressStyle.PRIMARY;
                      _pasteButtonVisible = false;
                      _showContactButton = false;
                    });
                    _sendAddressController.text = contact.name;
                  }
                });
              }
            });
          },
        ),
        fadeSuffixOnCondition: true,
        suffixShowFirstCondition: _pasteButtonVisible,
        style: _sendAddressStyle == AddressStyle.TEXT60
            ? AppStyles.textStyleAddressText60(context)
            : _sendAddressStyle == AddressStyle.TEXT90
                ? AppStyles.textStyleAddressText90(context)
                : AppStyles.textStyleAddressText90(context),
        onChanged: (text) {
          if (text.length > 0) {
            setState(() {
              _showContactButton = false;
            });
          } else {
            setState(() {
              _showContactButton = true;
            });
          }
          bool isContact = text.startsWith("@");
          // Switch to contact mode if starts with @
          if (isContact) {
            setState(() {
              _isContact = true;
            });
            sl
                .get<DBHelper>()
                .getContactsWithNameLike(text)
                .then((matchedList) {
              setState(() {
                _contacts = matchedList;
              });
            });
          } else {
            setState(() {
              _isContact = false;
              _contacts = [];
            });
          }
          // Always reset the error message to be less annoying
          setState(() {
            _addressValidationText = "";
          });
          if (!isContact && Address(text).isValid()) {
            //_sendAddressFocusNode.unfocus();
            setState(() {
              _sendAddressStyle = AddressStyle.TEXT90;
              _addressValidationText = "";
              _pasteButtonVisible = true;
            });
          } else if (!isContact) {
            setState(() {
              _sendAddressStyle = AddressStyle.TEXT60;
              _pasteButtonVisible = true;
            });
          } else {
            sl.get<DBHelper>().getContactWithName(text).then((contact) {
              if (contact == null) {
                setState(() {
                  _sendAddressStyle = AddressStyle.TEXT60;
                });
              } else {
                setState(() {
                  _pasteButtonVisible = false;
                  _addressValidationText = "";
                  _sendAddressStyle = AddressStyle.PRIMARY;
                });
              }
            });
          }
        },
        overrideTextFieldWidget: _addressValidAndUnfocused
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _addressValidAndUnfocused = false;
                    _addressValidationText = "";
                  });
                  Future.delayed(Duration(milliseconds: 50), () {
                    FocusScope.of(context).requestFocus(_sendAddressFocusNode);
                  });
                },
                child: UIUtil.threeLineAddressText(
                    context, _sendAddressController.text))
            : null);
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Openfield Container Method ************//
  //*******************************************************//
  getEnterOpenfieldContainer() {
    return AppTextField(
      focusNode: _sendOpenfieldFocusNode,
      controller: _sendOpenfieldController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'Roboto',
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(100000)],
      onChanged: (text) {
        // Always reset the error message to be less annoying
        setState(() {
          _openfieldValidationText = "";
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _openfieldHint == null
          ? ""
          : AppLocalization.of(context).enterOpenfield,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Openfield Container Method End ************//
  //*************************************************************//

//************ Enter Openfield Container Method ************//
  //*******************************************************//
  getEnterCommentContainer() {
    return AppTextField(
      focusNode: _sendCommentFocusNode,
      controller: _sendCommentController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'Roboto',
      ),
      onChanged: (text) {
        // Always reset the error message to be less annoying
        setState(() {});
      },
      inputFormatters: [LengthLimitingTextInputFormatter(100000)],
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _commentHint == null
          ? ""
          : AppLocalization.of(context).enterOpenfield,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Openfield Container Method End ************//
  //*************************************************************//

  //************ Enter Nb of tokens Container Method ************//
  //*******************************************************//
  getEnterTokensQuantityContainer() {
    return AppTextField(
      focusNode: _sendTokenQuantityFocusNode,
      controller: _sendTokenQuantityController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'Roboto',
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(16),
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      onChanged: (text) {
        // Always reset the error message to be less annoying
        setState(() {
          _tokenQuantityValidationText = "";
          // Reset the raw amount
          _rawTokenQuantity = null;
          _sendOperationController = TextEditingController(
              text: AddressTxsResponseResult.TOKEN_TRANSFER);
          _sendOpenfieldController = TextEditingController(
              text:
                  _selectedTokenName + ":" + _sendTokenQuantityController.text);
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _tokenQuantityHint == null
          ? ""
          : AppLocalization.of(context).enterTokenQuantity,
      fadeSuffixOnCondition: true,
      keyboardType:
          TextInputType.numberWithOptions(signed: true, decimal: false),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
        if (!Address(_sendAddressController.text).isValid()) {
          FocusScope.of(context).requestFocus(_sendAddressFocusNode);
        }
      },
    );
  } //************ Enter Nb of tokens Container Method End ************//
  //*************************************************************//

  //************ Enter Operation Container Method ************//
  //*******************************************************//
  getEnterOperationContainer() {
    return AppTextField(
      focusNode: _sendOperationFocusNode,
      controller: _sendOperationController,
      topMargin: 30,
      cursorColor: StateContainer.of(context).curTheme.primary,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
        color: StateContainer.of(context).curTheme.primary,
        fontFamily: 'Roboto',
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
      onChanged: (text) {
        // Always reset the error message to be less annoying
        setState(() {
          _operationValidationText = "";
        });
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      hintText: _operationHint == null
          ? ""
          : AppLocalization.of(context).enterOperation,
      keyboardType: TextInputType.text,
      textAlign: TextAlign.left,
      onSubmitted: (text) {
        FocusScope.of(context).unfocus();
      },
    );
  } //************ Enter Operation Container Method End ************//
  //*************************************************************//

  //************ Enter Token Container Method ************//
  //*******************************************************//
  getEnterTokenContainer() {
    return SizedBox(
      width: 250,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: StateContainer.of(context).curTheme.backgroundDarkest,
        ),
        child: DropdownButtonFormField(
          value: _selectedTokenName,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color:
                        StateContainer.of(context).curTheme.backgroundDarkest),
              ),
              isDense: true),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w100,
            fontFamily: 'Roboto',
            color: StateContainer.of(context).curTheme.text60,
          ),
          items:
              StateContainer.of(context).wallet.tokens.map((BisToken bisToken) {
            return DropdownMenuItem<String>(
                value: bisToken.tokenName,
                child: Container(
                    child: bisToken.tokenName == ""
                        ? Text("")
                        : Text(
                            bisToken.tokenName +
                                " (" +
                                bisToken.tokensQuantity.toString() +
                                " " +
                                AppLocalization.of(context).available +
                                ")",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'Roboto',
                              color: StateContainer.of(context).curTheme.text60,
                            ),
                          )));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTokenName = value;
              _tokenValidationText = "";
              _sendOperationController = TextEditingController(
                  text: AddressTxsResponseResult.TOKEN_TRANSFER);
              _sendOpenfieldController = TextEditingController(
                  text: _selectedTokenName +
                      ":" +
                      _sendTokenQuantityController.text);
            });
          },
        ),
      ),
    );
  } //************ Enter Token Container Method End ************//
  //*************************************************************//

}

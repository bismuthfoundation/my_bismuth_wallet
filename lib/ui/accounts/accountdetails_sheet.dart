// @dart=2.9

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

// Project imports:
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/dimens.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/service/dragginator_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/ui/util/ui_util.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_text_field.dart';
import 'package:my_bismuth_wallet/ui/widgets/buttons.dart';
import 'package:my_bismuth_wallet/ui/widgets/dialog.dart';
import 'package:my_bismuth_wallet/ui/widgets/sheets.dart';
import 'package:my_bismuth_wallet/ui/widgets/tap_outside_unfocus.dart';
import 'package:my_bismuth_wallet/util/caseconverter.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';

// Account Details Sheet
class AccountDetailsSheet {
  Account account;
  String originalName;
  String originalDragginatorAvatarDna;
  TextEditingController _nameController;
  TextEditingController _dragginatorAvatarDnaController;
  FocusNode _nameFocusNode;
  FocusNode _dragginatorAvatarDnaFocusNode;
  bool deleted;
  // Address copied or not
  bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  AccountDetailsSheet(this.account) {
    this.originalName = account.name;
    this.originalDragginatorAvatarDna = account.dragginatorDna;
    this.deleted = false;
  }

  Future<bool> _onWillPop(BuildContext context) async {
    // Update name if changed and valid
    if (originalName != _nameController.text &&
        _nameController.text.trim().length > 0 &&
        !deleted) {
      sl.get<DBHelper>().changeAccountName(account, _nameController.text);
      account.name = _nameController.text;
      EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account));
    }
    // Update avatar dna if changed and valid
    if (originalName != _dragginatorAvatarDnaController.text && !deleted) {
      if (_dragginatorAvatarDnaController.text.trim() != "") {
        await sl
            .get<DragginatorService>()
            .getInfosFromDna(_dragginatorAvatarDnaController.text)
            .then((value) {
          if (value != null && value.status != "") {
            sl.get<DBHelper>().changeAccountDragginatorDna(
                account, _dragginatorAvatarDnaController.text, value.status);
            account.dragginatorDna = _dragginatorAvatarDnaController.text;
            account.dragginatorStatus = value.status;
            EventTaxiImpl.singleton()
                .fire(AccountModifiedEvent(account: account));
          } else {
            UIUtil.showSnackbar(
                "The dna '" +
                    _dragginatorAvatarDnaController.text +
                    "' doesn't exist.",
                context);
            return false;
          }
        });
      } else {
        sl.get<DBHelper>().changeAccountDragginatorDna(account, "", "");
        account.dragginatorDna = "";
        account.dragginatorStatus = "";
        EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account));
      }
    }
    return true;
  }

  mainBottomSheet(BuildContext context) {
    _addressCopied = false;
    _nameController = TextEditingController(text: account.name);
    _dragginatorAvatarDnaController =
        TextEditingController(text: account.dragginatorDna);
    _nameFocusNode = FocusNode();
    _dragginatorAvatarDnaFocusNode = FocusNode();
    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: () => _onWillPop(context),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
                onWillPop: () => _onWillPop(context),
                child: TapOutsideUnfocus(
                    child: SafeArea(
                        minimum: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.035),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Trashcan Button
                                Container(
                                    width: 50,
                                    height: 50,
                                    margin: EdgeInsetsDirectional.only(
                                        top: 10.0, start: 10.0),
                                    child: account.index == 0
                                        ? SizedBox()
                                        : TextButton(
                                            onPressed: () {
                                              AppDialogs.showConfirmDialog(
                                                  context,
                                                  AppLocalization.of(context)
                                                      .hideAccountHeader,
                                                  AppLocalization.of(context)
                                                      .removeAccountText
                                                      .replaceAll(
                                                          "%1",
                                                          AppLocalization.of(
                                                                  context)
                                                              .addAccount),
                                                  CaseChange.toUpperCase(
                                                      AppLocalization.of(
                                                              context)
                                                          .yes,
                                                      context), () {
                                                // Remove account
                                                deleted = true;
                                                sl
                                                    .get<DBHelper>()
                                                    .deleteAccount(account)
                                                    .then((id) {
                                                  EventTaxiImpl.singleton()
                                                      .fire(
                                                          AccountModifiedEvent(
                                                              account: account,
                                                              deleted: true));
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                                  cancelText:
                                                      CaseChange.toUpperCase(
                                                          AppLocalization.of(
                                                                  context)
                                                              .no,
                                                          context));
                                            },
                                            child: Icon(AppIcons.trashcan,
                                                size: 24,
                                                color:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .text),
                                          )),
                                // The header of the sheet
                                Container(
                                  margin: EdgeInsets.only(top: 25.0),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              140),
                                  child: Column(
                                    children: <Widget>[
                                      AutoSizeText(
                                        CaseChange.toUpperCase(
                                            AppLocalization.of(context).account,
                                            context),
                                        style:
                                            AppStyles.textStyleHeader(context),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        stepGranularity: 0.1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Search Button
                                SizedBox(height: 50, width: 50),
                              ],
                            ),
                            // Address Text
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: account.address != null
                                  ? UIUtil.threeLineAddressText(
                                      context, account.address,
                                      type: ThreeLineAddressTextType.PRIMARY60)
                                  : account.selected
                                      ? UIUtil.threeLineAddressText(
                                          context,
                                          StateContainer.of(context)
                                              .wallet
                                              .address,
                                          type: ThreeLineAddressTextType
                                              .PRIMARY60)
                                      : SizedBox(),
                            ),
                            // Balance Text
                            (account.balance != null || account.selected)
                                ? Container(
                                    margin: EdgeInsets.only(top: 5.0),
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        text: '',
                                        children: [
                                          TextSpan(
                                            text: "(",
                                            style: TextStyle(
                                              color: StateContainer.of(context)
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                NumberUtil.getRawAsUsableString(
                                                    account.balance == null
                                                        ? StateContainer.of(
                                                                context)
                                                            .wallet
                                                            .accountBalance
                                                            .toString()
                                                        : account.balance),
                                            style: TextStyle(
                                              color: StateContainer.of(context)
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                          TextSpan(
                                            text: " BIS)",
                                            style: TextStyle(
                                              color: StateContainer.of(context)
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(),

                            // The main container that holds Contact Name and Contact Address
                            Expanded(
                              child: KeyboardAvoider(
                                  duration: Duration(milliseconds: 0),
                                  autoScroll: true,
                                  focusPadding: 40,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        AppTextField(
                                          topMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          rightMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.105,
                                          controller: _nameController,
                                          focusNode: _nameFocusNode,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                15),
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            fontFamily: 'NunitoSans',
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        AppTextField(
                                          topMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          rightMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.105,
                                          controller:
                                              _dragginatorAvatarDnaController,
                                          focusNode:
                                              _dragginatorAvatarDnaFocusNode,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                30),
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            fontFamily: 'NunitoSans',
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              new EdgeInsetsDirectional.only(
                                                  start: 12.0, end: 12.0),
                                          child: Text(
                                              "If you want to change your default avatar to an egg or a draggon from your collection, please specify its dna.",
                                              style: AppStyles
                                                  .textStyleSettingItemSubheader(
                                                      context)),
                                        ),
                                      ])),
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      AppButton.buildAppButton(
                                          context,
                                          // Share Address Button
                                          _addressCopied
                                              ? AppButtonType.SUCCESS
                                              : AppButtonType.PRIMARY,
                                          _addressCopied
                                              ? AppLocalization.of(context)
                                                  .addressCopied
                                              : AppLocalization.of(context)
                                                  .copyAddress,
                                          Dimens.BUTTON_TOP_DIMENS,
                                          onPressed: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: account.address));
                                        setState(() {
                                          // Set copied style
                                          _addressCopied = true;
                                        });
                                        if (_addressCopiedTimer != null) {
                                          _addressCopiedTimer.cancel();
                                        }
                                        _addressCopiedTimer = new Timer(
                                            const Duration(milliseconds: 800),
                                            () {
                                          setState(() {
                                            _addressCopied = false;
                                          });
                                        });
                                      }),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      // Close Button
                                      AppButton.buildAppButton(
                                          context,
                                          AppButtonType.PRIMARY_OUTLINE,
                                          AppLocalization.of(context).close,
                                          Dimens.BUTTON_BOTTOM_DIMENS,
                                          onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))));
          });
        });
  }
}

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/model/vault.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_text_field.dart';
import 'package:my_bismuth_wallet/ui/widgets/dialog.dart';
import 'package:my_bismuth_wallet/ui/widgets/tap_outside_unfocus.dart';
import 'package:my_bismuth_wallet/util/app_ffi/encrypt/crypter.dart';
import 'package:my_bismuth_wallet/util/app_ffi/apputil.dart';
import 'package:my_bismuth_wallet/util/caseconverter.dart';
import 'package:my_bismuth_wallet/ui/widgets/buttons.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/dimens.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class AppPasswordLockScreen extends StatefulWidget {
  @override
  _AppPasswordLockScreenState createState() => _AppPasswordLockScreenState();
}

class _AppPasswordLockScreenState extends State<AppPasswordLockScreen> {
  FocusNode enterPasswordFocusNode;
  TextEditingController enterPasswordController;

  String passwordError;

  @override
  void initState() {
    super.initState();
    this.enterPasswordFocusNode = FocusNode();
    this.enterPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: TapOutsideUnfocus(
            child: Container(
          color: StateContainer.of(context).curTheme.backgroundDark,
          width: double.infinity,
          child: SafeArea(
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
            ),
            child: Column(
              children: <Widget>[
                // Logout button
                Container(
                  margin: EdgeInsetsDirectional.only(start: 16, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        onPressed: () {
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
                                    AppLocalization.of(context).yes, context),
                                () {
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
                        },
                        highlightColor:
                            StateContainer.of(context).curTheme.text15,
                        splashColor: StateContainer.of(context).curTheme.text30,
                        padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(AppIcons.logout,
                                  size: 16,
                                  color:
                                      StateContainer.of(context).curTheme.text),
                              Container(
                                margin: EdgeInsetsDirectional.only(start: 4),
                                child: Text(AppLocalization.of(context).logout,
                                    style: AppStyles.textStyleLogoutButton(
                                        context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        AppIcons.lock,
                        size: 80,
                        color: StateContainer.of(context).curTheme.primary,
                      ),
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                    ),
                    Container(
                      child: Text(
                        CaseChange.toUpperCase(
                            AppLocalization.of(context).locked, context),
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                      margin: EdgeInsets.only(top: 10),
                    ),
                    Expanded(
                        child: KeyboardAvoider(
                            duration: Duration(milliseconds: 0),
                            autoScroll: true,
                            focusPadding: 40,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // Enter your password Text Field
                                  AppTextField(
                                    topMargin: 30,
                                    padding: EdgeInsetsDirectional.only(
                                        start: 16, end: 16),
                                    focusNode: enterPasswordFocusNode,
                                    controller: enterPasswordController,
                                    textInputAction: TextInputAction.go,
                                    autofocus: true,
                                    onChanged: (String newText) {
                                      if (passwordError != null) {
                                        setState(() {
                                          passwordError = null;
                                        });
                                      }
                                    },
                                    onSubmitted: (value) async {
                                      FocusScope.of(context).unfocus();
                                      await validateAndDecrypt();
                                    },
                                    hintText: AppLocalization.of(context)
                                        .enterPasswordHint,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  // Error Container
                                  Container(
                                    alignment: AlignmentDirectional(0, 0),
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text(
                                        this.passwordError == null
                                            ? ""
                                            : this.passwordError,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .primary,
                                          fontFamily: 'NunitoSans',
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ])))
                  ],
                )),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context).unlock,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                      await validateAndDecrypt();
                    }),
                  ],
                )
              ],
            ),
          ),
        )));
  }

  Future<void> validateAndDecrypt() async {
    try {
      String decryptedSeed = HEX.encode(AppCrypt.decrypt(
          await sl.get<Vault>().getSeed(), enterPasswordController.text));
      StateContainer.of(context).setEncryptedSecret(HEX.encode(AppCrypt.encrypt(
          decryptedSeed, await sl.get<Vault>().getSessionKey())));
      _goHome();
    } catch (e) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context).invalidPassword;
        });
      }
    }
  }

  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet == null) {
      await AppUtil()
          .loginAccount(await StateContainer.of(context).getSeed(), context);
    }
    StateContainer.of(context).requestUpdate();
    PriceConversion conversion =
        await sl.get<SharedPrefsUtil>().getPriceConversion();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_transition', (Route<dynamic> route) => false,
        arguments: conversion);
  }
}

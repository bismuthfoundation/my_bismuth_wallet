import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/styles.dart';
import 'package:my_bismuth_wallet/app_icons.dart';
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/ui/widgets/app_text_field.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class CustomUrl extends StatefulWidget {
  final AnimationController tokensListController;
  bool tokensListOpen;

  CustomUrl(this.tokensListController, this.tokensListOpen);

  _CustomUrlState createState() => _CustomUrlState();
}

class _CustomUrlState extends State<CustomUrl> {
  final Logger log = sl.get<Logger>();

  bool walletServerOk;
  bool tokenApiOk;

  FocusNode _walletServerFocusNode;
  FocusNode _tokenApiFocusNode;
  TextEditingController _walletServerController;
  TextEditingController _tokenApiController;

  bool useCustomWalletServer;

  String _walletServerHint = "";
  String _tokenApiHint = "";
  String _walletServerValidationText = "";
  String _tokenApiValidationText = "";

  AppService appService = new AppService();

  void initControllerText() async {
    String w = await sl.get<SharedPrefsUtil>().getWalletServer();
    _walletServerController.text = w;
    if (w == "auto") {
      useCustomWalletServer = false;
    } else {
      useCustomWalletServer = true;
    }
    updateWalletServer();
    _tokenApiController.text = await sl.get<SharedPrefsUtil>().getTokensApi();
    updateTokenApi();
  }

  void updateWalletServer() async {
    await sl
        .get<SharedPrefsUtil>()
        .setWalletServer(_walletServerController.text);
    WStatusGetResponse wStatusGetResponse =
        await appService.getWStatusGetResponse();
    if (wStatusGetResponse == null) {
      walletServerOk = false;
    } else {
      walletServerOk = true;
    }
    setState(() {});
  }

  void updateTokenApi() async {
    await sl.get<SharedPrefsUtil>().setTokensApi(_tokenApiController.text);
    tokenApiOk = await AppService()
        .isTokensBalance(StateContainer.of(context).selectedAccount.address);

    setState(() {});
  }

  @override
  void initState() {
    //
    super.initState();

    useCustomWalletServer = false;

    walletServerOk = false;
    tokenApiOk = false;

    _walletServerFocusNode = FocusNode();
    _tokenApiFocusNode = FocusNode();
    _walletServerController = TextEditingController();
    _tokenApiController = TextEditingController();

    initControllerText();

    _walletServerFocusNode.addListener(() {
      if (_walletServerFocusNode.hasFocus) {
        setState(() {
          _walletServerHint = null;
        });
      } else {
        setState(() {
          _walletServerHint = "";
        });
      }
    });
    _tokenApiFocusNode.addListener(() {
      if (_tokenApiFocusNode.hasFocus) {
        setState(() {
          _tokenApiHint = null;
        });
      } else {
        setState(() {
          _tokenApiHint = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            bottom: MediaQuery.of(context).size.height * 0.035,
            top: 60,
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(children: <Widget>[
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
                                widget.tokensListOpen = false;
                              });
                              widget.tokensListController.reverse();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(AppIcons.back,
                                color: StateContainer.of(context).curTheme.text,
                                size: 24)),
                      ),
                      // Header Text
                      Text(
                        AppLocalization.of(context).customUrlHeader,
                        style: AppStyles.textStyleSettingsHeader(context),
                      ),
                    ]),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.only(top: 30, bottom: 30),
                          child: Column(children: <Widget>[
                            Stack(children: <Widget>[
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalization.of(context)
                                              .enterWalletServerSwitch,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w100,
                                            fontFamily: 'Roboto',
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .text60,
                                          ),
                                        ),
                                        Switch(
                                            value: useCustomWalletServer,
                                            onChanged: (value) {
                                              setState(() {
                                                useCustomWalletServer = value;
                                                if (useCustomWalletServer ==
                                                    false) {
                                                  _walletServerController.text =
                                                      "auto";
                                                } else {
                                                  _walletServerController.text =
                                                      "";
                                                }
                                                _walletServerValidationText =
                                                    "";
                                                updateWalletServer();
                                              });
                                            },
                                            activeTrackColor:
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .backgroundDarkest,
                                            activeColor: Colors.green),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    useCustomWalletServer
                                        ? Container(
                                            child: getWalletServerContainer(),
                                          )
                                        : SizedBox(),
                                    useCustomWalletServer
                                        ? Container(
                                            alignment:
                                                AlignmentDirectional(0, 0),
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                                _walletServerValidationText,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .primary,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Container(
                                      child: getTokenApiContainer(),
                                    ),
                                    Container(
                                      alignment: AlignmentDirectional(0, 0),
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(_tokenApiValidationText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                  ])
                            ])
                          ])))),
            ],
          ),
        ));
  }

  getWalletServerContainer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            walletServerOk == false
                ? Icon(
                    Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                    color: Colors.red)
                : Icon(Icons.signal_cellular_alt_rounded, color: Colors.green),
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context).enterWalletServer,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w100,
                fontFamily: 'Roboto',
                color: StateContainer.of(context).curTheme.text60,
              ),
            ),
          ],
        ),
        AppTextField(
          leftMargin: 10,
          rightMargin: 10,
          topMargin: 10,
          focusNode: _walletServerFocusNode,
          controller: _walletServerController,
          cursorColor: StateContainer.of(context).curTheme.primary,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            color: StateContainer.of(context).curTheme.primary,
            fontFamily: 'Roboto',
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(23)],
          onChanged: (text) {
            updateWalletServer();
            // Always reset the error message to be less annoying
            setState(() {
              _walletServerValidationText = "";
            });
          },
          textInputAction: TextInputAction.next,
          maxLines: null,
          autocorrect: false,
          hintText: _walletServerHint == null
              ? ""
              : AppLocalization.of(context).enterWalletServer,
          keyboardType: TextInputType.multiline,
          textAlign: TextAlign.left,
          onSubmitted: (text) {
            FocusScope.of(context).unfocus();
          },
        ),
        Text(AppLocalization.of(context).enterWalletServerInfo,
            style: AppStyles.textStyleParagraphSmall(context)),
      ],
    );
  }

  getTokenApiContainer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            tokenApiOk == false
                ? Icon(FontAwesome.connectdevelop, size: 16, color: Colors.red)
                : Icon(FontAwesome.connectdevelop,
                    size: 16, color: Colors.green),
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context).enterTokenApi,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w100,
                fontFamily: 'Roboto',
                color: StateContainer.of(context).curTheme.text60,
              ),
            ),
          ],
        ),
        AppTextField(
          leftMargin: 10,
          rightMargin: 10,
          topMargin: 10,
          focusNode: _tokenApiFocusNode,
          controller: _tokenApiController,
          cursorColor: StateContainer.of(context).curTheme.primary,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            color: StateContainer.of(context).curTheme.primary,
            fontFamily: 'Roboto',
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
          onChanged: (text) {
            updateTokenApi();
            // Always reset the error message to be less annoying
            setState(() {
              _tokenApiValidationText = "";
            });
          },
          textInputAction: TextInputAction.next,
          maxLines: null,
          autocorrect: false,
          hintText: _tokenApiHint == null
              ? ""
              : AppLocalization.of(context).enterTokenApi,
          keyboardType: TextInputType.multiline,
          textAlign: TextAlign.left,
          onSubmitted: (text) {
            FocusScope.of(context).unfocus();
          },
        ),
        Text(AppLocalization.of(context).enterTokenApiInfo,
            style: AppStyles.textStyleParagraphSmall(context)),
      ],
    );
  }

  bool _validateRequest() {
    bool isValid = true;
    _walletServerFocusNode.unfocus();
    _tokenApiFocusNode.unfocus();

    if (_walletServerController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        //_walletServerValidationText = AppLocalization.of(context).account;
      });
    }

    return isValid;
  }
}

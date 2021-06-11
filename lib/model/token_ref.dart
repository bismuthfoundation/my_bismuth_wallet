// @dart=2.9

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:my_bismuth_wallet/styles.dart';

class TokenRef {
  String token;
  int totalSupply;
  DateTime creationDate;
  String creator;

  TokenRef({this.token, this.totalSupply, this.creationDate, this.creator});

  Widget getIcon(String tokenName) {
    IconData iconData;
    switch (tokenName) {
      case "egg":
        iconData = FontAwesome5.egg;
        break;
      case "snowball":
        iconData = FontAwesome5.snowflake;
        break;
      case "snowman":
        iconData = FontAwesome5.snowman;
        break;
      case "snowball":
        iconData = FontAwesome5.snowflake;
        break;
      case "btc":
        iconData = FontAwesome5.bitcoin;
        break;
      case "fuel":
        iconData = Maki.fuel;
        break;
      case "air":
        iconData = FontAwesome5.wind;
        break;
      case "earth":
        iconData = FontAwesome5.globe;
        break;
      case "fire":
        iconData = FontAwesome5.fire_alt;
        break;
      case "water":
        iconData = FontAwesome5.water;
        break;
      case "dragginator":
        iconData = FontAwesome5.dragon;
        break;
      case "candycane":
        iconData = FontAwesome5.candy_cane;
        break;
      case "hdd":
        iconData = FontAwesome5.hdd;
        break;
      case "water":
        iconData = FontAwesome5.water;
        break;
      case "ticket":
        iconData = FontAwesome.ticket;
        break;
      default:
        iconData = null;
        break;
    }
    if (iconData != null) {
      return Icon(
        iconData,
        size: AppFontSizes.small,
      );
    } else {
      return SizedBox();
    }
  }
}

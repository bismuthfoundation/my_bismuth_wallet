// @dart=2.9

import 'package:flutter/material.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/model/setting_item.dart';

enum UnlockOption { YES, NO }

/// Represent authenticate to open setting
class UnlockSetting extends SettingSelectionItem {
  UnlockOption setting;

  UnlockSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case UnlockOption.YES:
        return AppLocalization.of(context).yes;
      case UnlockOption.NO:
      default:
        return AppLocalization.of(context).no;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}
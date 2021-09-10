// @dart=2.9

import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:my_bismuth_wallet/util/random_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/encrypt.dart';
import 'package:my_bismuth_wallet/model/authentication_method.dart';
import 'package:my_bismuth_wallet/model/available_currency.dart';
import 'package:my_bismuth_wallet/model/available_language.dart';
import 'package:my_bismuth_wallet/model/device_lock_timeout.dart';
import 'package:my_bismuth_wallet/model/vault.dart';

/// Price conversion preference values
enum PriceConversion { BTC, NONE, HIDDEN }

/// Singleton wrapper for shared preferences
class SharedPrefsUtil {
  // Keys
  static const String first_launch_key = 'fbismuth_first_launch';
  static const String price_conversion = 'fbismuth_price_conversion_pref';
  static const String auth_method = 'fbismuth_auth_method';
  static const String cur_currency = 'fbismuth_currency_pref';
  static const String cur_language = 'fbismuth_language_pref';
  static const String cur_theme = 'fbismuth_theme_pref';
  static const String firstcontact_added = 'fbismuth_first_c_added';
  static const String lock = 'fbismuth_lock_dev';
  static const String lock_timeout = 'fbismuth_lock_timeout';
  static const String has_shown_root_warning =
      'fbismuth_root_warn'; // If user has seen the root/jailbreak warning yet
  // For maximum pin attempts
  static const String pin_attempts = 'fbismuth_pin_attempts';
  static const String pin_lock_until = 'fbismuth_lock_duraton';
  // For certain keystore incompatible androids
  static const String use_legacy_storage = 'fbismuth_legacy_storage';

  static const String version_app = 'fbismuth_version_app';

  static const String wallet_server = 'fbismuth_wallet_server';
  static const String tokens_api = 'fbismuth_tokens_api';
  static const String explorer_url = 'fbismuth_explorer_url';


  // For plain-text data
  Future<void> set(String key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.get(key) ?? defaultValue;
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String value) async {
    // Retrieve/Generate encryption password
    String secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) {
      secret = RandomUtil.generateEncryptionSecret(16) +
          ":" +
          RandomUtil.generateEncryptionSecret(8);
      await sl.get<Vault>().writeEncryptionPhrase(secret);
    }
    // Encrypt and save
    Salsa20Encryptor encrypter =
        new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String> getEncrypted(String key) async {
    String secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) return null;
    // Decrypt and return
    Salsa20Encryptor encrypter =
        new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encrypted = prefs.get(key);
    if (encrypted == null) return null;
    return encrypter.decrypt(encrypted);
  }

  Future<void> setHasSeenRootWarning() async {
    return await set(has_shown_root_warning, true);
  }

  Future<bool> getHasSeenRootWarning() async {
    return await get(has_shown_root_warning, defaultValue: false);
  }

  Future<void> setFirstLaunch() async {
    return await set(first_launch_key, false);
  }

  Future<bool> getFirstLaunch() async {
    return await get(first_launch_key, defaultValue: true);
  }

  Future<void> setFirstContactAdded(bool value) async {
    return await set(firstcontact_added, value);
  }

  Future<bool> getFirstContactAdded() async {
    return await get(firstcontact_added, defaultValue: false);
  }

  Future<void> setPriceConversion(PriceConversion conversion) async {
    return await set(price_conversion, conversion.index);
  }

  Future<PriceConversion> getPriceConversion() async {
    return PriceConversion.values[
        await get(price_conversion, defaultValue: PriceConversion.BTC.index)];
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
    return await set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(AuthMethod.values[
        await get(auth_method, defaultValue: AuthMethod.BIOMETRICS.index)]);
  }

  Future<void> setCurrency(AvailableCurrency currency) async {
    return await set(cur_currency, currency.getIndex());
  }

  Future<AvailableCurrency> getCurrency(Locale deviceLocale) async {
    return AvailableCurrency(AvailableCurrencyEnum.values[await get(
        cur_currency,
        defaultValue:
            AvailableCurrency.getBestForLocale(deviceLocale).currency.index)]);
  }

  Future<void> setLanguage(LanguageSetting language) async {
    return await set(cur_language, language.getIndex());
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(AvailableLanguage.values[await get(cur_language,
        defaultValue: AvailableLanguage.DEFAULT.index)]);
  }

  Future<void> setVersionApp(String v) async {
    return await set(version_app, v);
  }

  Future<String> getVersionApp() async {
    return await get(version_app,
        defaultValue: "");
  }

  Future<void> setWalletServer(String v) async {
    return await set(wallet_server, v);
  }

  Future<String> getWalletServer() async {
    return await get(wallet_server,
        defaultValue: "auto");
  }

  Future<void> setTokensApi(String v) async {
    return await set(tokens_api, v);
  }

  Future<String> getTokensApi() async {
    return await get(tokens_api,
        defaultValue: "https://bismuth.today/api/balances/");
  }


  Future<void> setExplorerUrl(String v) async {
    return await set(explorer_url, v);
  }

  Future<String> getExplorerUrl() async {
    return await get(explorer_url,
        defaultValue: "https://bismuth.online/search?quicksearch=%1");
  }

  Future<void> setLock(bool value) async {
    return await set(lock, value);
  }

  Future<bool> getLock() async {
    return await get(lock, defaultValue: false);
  }

  Future<void> setLockTimeout(LockTimeoutSetting setting) async {
    return await set(lock_timeout, setting.getIndex());
  }

  Future<LockTimeoutSetting> getLockTimeout() async {
    return LockTimeoutSetting(LockTimeoutOption.values[await get(
        lock_timeout,
        defaultValue: LockTimeoutOption.ONE.index)]);
  }

  // Locking out when max pin attempts exceeded
  Future<int> getLockAttempts() async {
    return await get(pin_attempts, defaultValue: 0);
  }

  Future<void> incrementLockAttempts() async {
    await set(pin_attempts, await getLockAttempts() + 1);
  }

  Future<void> resetLockAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
  }

  Future<bool> shouldLock() async {
    if (await get(pin_lock_until) != null || await getLockAttempts() >= 5) {
      return true;
    }
    return false;
  }

  Future<void> updateLockDate() async {
    int attempts = await getLockAttempts();
    if (attempts >= 20) {
      // 4+ failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(hours: 24))));
    } else if (attempts >= 15) {
      // 3 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 15))));
    } else if (attempts >= 10) {
      // 2 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 5))));
    } else if (attempts >= 5) {
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 1))));
    }
  }

  Future<DateTime> getLockDate() async {
    String lockDateStr = await get(pin_lock_until);
    if (lockDateStr == null) {
      return null;
    }
    return DateFormat.yMd().add_jms().parseUtc(lockDateStr);
  }

  Future<bool> useLegacyStorage() async {
    return await get(use_legacy_storage, defaultValue: false);
  }

  Future<void> setUseLegacyStorage() async {
    await set(use_legacy_storage, true);
  }

  // For logging out
  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(price_conversion);
    await prefs.remove(cur_currency);
    await prefs.remove(auth_method);
    await prefs.remove(lock);
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
    await prefs.remove(lock_timeout);
    await prefs.remove(has_shown_root_warning);
    await prefs.remove(version_app);
    await prefs.remove(wallet_server);
    await prefs.remove(tokens_api);
    await prefs.remove(explorer_url);
  }
}

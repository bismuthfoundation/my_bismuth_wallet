// @dart=2.9

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/available_language.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';
import 'l10n/messages_all.dart';

/// Localization
class AppLocalization {
  static Locale currentLocale = Locale('en', 'US');

  static Future<AppLocalization> load(Locale locale) {
    currentLocale = locale;
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  /// -- GENERIC ITEMS
  String get cancel {
    return Intl.message('Cancel', desc: 'dialog_cancel', name: 'cancel');
  }

  String get close {
    return Intl.message('Close', desc: 'dialog_close', name: 'close');
  }

  String get confirm {
    return Intl.message('Confirm', desc: 'dialog_confirm', name: 'confirm');
  }

  String get no {
    return Intl.message('No', desc: 'intro_new_wallet_backup_no', name: 'no');
  }

  String get yes {
    return Intl.message('Yes',
        desc: 'intro_new_wallet_backup_yes', name: 'yes');
  }

  String get onStr {
    return Intl.message('On', desc: 'generic_on', name: 'onStr');
  }

  String get off {
    return Intl.message('Off', desc: 'generic_off', name: 'off');
  }

  String get send {
    return Intl.message('Send', desc: 'home_send_cta', name: 'send');
  }

  String get receive {
    return Intl.message('Receive', desc: 'home_receive_cta', name: 'receive');
  }

  String get sent {
    return Intl.message('Sent', desc: 'history_sent', name: 'sent');
  }

  String get received {
    return Intl.message('Received', desc: 'history_received', name: 'received');
  }

  String get transactions {
    return Intl.message('Transactions',
        desc: 'transaction_header', name: 'transactions');
  }

  String get transactionHeader {
    return Intl.message('Transaction',
        desc: 'transaction_header', name: 'transactionHeader');
  }

  String get transactionDetailBlock {
    return Intl.message('Block',
        desc: 'transaction_detail', name: 'transactionDetailBlock');
  }

  String get transactionDetailDate {
    return Intl.message('Date',
        desc: 'transaction_detail', name: 'transactionDetailDate');
  }

  String get transactionDetailFrom {
    return Intl.message('From address',
        desc: 'transaction_detail', name: 'transactionDetailFrom');
  }

  String get transactionDetailTo {
    return Intl.message('To address',
        desc: 'transaction_detail', name: 'transactionDetailTo');
  }

  String get transactionDetailTxId {
    return Intl.message('Transaction id',
        desc: 'transaction_detail', name: 'transactionDetailTxId');
  }

  String get transactionDetailAmount {
    return Intl.message('Amount',
        desc: 'transaction_detail', name: 'transactionDetailAmount');
  }

  String get transactionDetailFee {
    return Intl.message('Fee',
        desc: 'transaction_detail', name: 'transactionDetailFee');
  }

  String get transactionDetailReward {
    return Intl.message('Reward',
        desc: 'transaction_detail', name: 'transactionDetailReward');
  }

  String get transactionDetailOperation {
    return Intl.message('Operation',
        desc: 'transaction_detail', name: 'transactionDetailOperation');
  }

  String get transactionDetailOpenfield {
    return Intl.message('Data (Openfield)',
        desc: 'transaction_detail', name: 'transactionDetailOpenfield');
  }

  String get transactionDetailSignature {
    return Intl.message('Signature',
        desc: 'transaction_signature', name: 'transactionDetailSignature');
  }

  String get transactionDetailCopyPaste {
    return Intl.message('Double click on text to copy to clipboard',
        desc: 'transaction_detail', name: 'transactionDetailCopyPaste');
  }

  String get mempool {
    return Intl.message('Unconfirmed', desc: 'mempool', name: 'mempool');
  }

  String get addressCopied {
    return Intl.message('Address Copied',
        desc: 'receive_copied', name: 'addressCopied');
  }

  String get copyAddress {
    return Intl.message('Copy Address',
        desc: 'receive_copy_cta', name: 'copyAddress');
  }

  String get addressShare {
    return Intl.message('Share Address',
        desc: 'receive_share_cta', name: 'addressShare');
  }

  String get addressHint {
    return Intl.message('Enter Address',
        desc: 'send_address_hint', name: 'addressHint');
  }

  String get seed {
    return Intl.message('Seed',
        desc: 'intro_new_wallet_seed_header', name: 'seed');
  }

  String get seedInvalid {
    return Intl.message('Seed is Invalid',
        desc: 'intro_seed_invalid', name: 'seedInvalid');
  }

  String get seedCopied {
    return Intl.message(
        'Seed Copied to Clipboard\nIt is pasteable for 2 minutes.',
        desc: 'intro_new_wallet_seed_copied',
        name: 'seedCopied');
  }

  String get scanQrCode {
    return Intl.message('Scan QR Code',
        desc: 'send_scan_qr', name: 'scanQrCode');
  }

  String get qrInvalidSeed {
    return Intl.message("QR code does not contain a valid seed or private key",
        desc: "qr_invalid_seed", name: 'qrInvalidSeed');
  }

  String get qrInvalidAddress {
    return Intl.message("QR code does not contain a valid destination",
        desc: "qr_invalid_address", name: 'qrInvalidAddress');
  }

  String get qrInvalidPermissions {
    return Intl.message("Please Grant Camera Permissions to scan QR Codes",
        desc: "User did not grant camera permissions to the app",
        name: "qrInvalidPermissions");
  }

  String get qrUnknownError {
    return Intl.message("Could not Read QR Code",
        desc: "An unknown error occurred with the QR scanner",
        name: "qrUnknownError");
  }

  /// -- END GENERIC ITEMS

  /// -- DRAGGINATOR
  String get dragginatorHeader {
    return Intl.message('Dragginator (beta)',
        desc: '', name: 'dragginatorHeader');
  }

  String get dragginatorBreedingListHeader {
    return Intl.message('My breeding',
        desc: '', name: 'dragginatorBreedingListHeader');
  }

  String get dragginatorMergingHeader {
    return Intl.message('Merging', desc: '', name: 'dragginatorMergingHeader');
  }

  String get dragginatorGetEggWithEggHeader {
    return Intl.message('Get an egg for 1 EGG',
        desc: '', name: 'dragginatorGetEggWithEggHeader');
  }

  String get dragginatorGetEggWithBisHeader {
    return Intl.message('Get an egg for %1 BIS',
        desc: '', name: 'dragginatorGetEggWithBisHeader');
  }

  String get dragginatorMarketPlace {
    return Intl.message('Marketplace',
        desc: '', name: 'dragginatorMarketPlace');
  }

  String get dragginatorHelp {
    return Intl.message('Help', desc: '', name: 'dragginatorHelp');
  }

  String get dragginatorSendEgg {
    return Intl.message('Send the %1', desc: '', name: 'dragginatorSendEgg');
  }

  String get dragginatorAllowTransfer {
    return Intl.message('Allow to transfer',
        desc: '', name: 'dragginatorAllowTransfer');
  }

  String get dragginatorRegisterAnEggToTheHunt {
    return Intl.message('Register to the hunt',
        desc: '', name: 'dragginatorRegisterAnEggToTheHunt');
  }

  String get dragginatorMerging2Eggs {
    return Intl.message('Merging 2 eggs',
        desc: '', name: 'dragginatorMerging2Eggs');
  }

  String get dragginatorHatchAnEgg {
    return Intl.message('Hatch the egg',
        desc: '', name: 'dragginatorHatchAnEgg');
  }

  String get dragginatorOffersAnEgg {
    return Intl.message('Offers the egg',
        desc: '', name: 'dragginatorOffersAnEgg');
  }

  String get dragginatorRevert {
    return Intl.message('Revert', desc: '', name: 'dragginatorRevert');
  }

  ///  -- END DRAGGINATOR

  /// -- CUSTOM URL

  String get customUrlHeader {
    return Intl.message('Custom Urls', desc: '', name: 'customUrlHeader');
  }

  String get enterWalletServer {
    return Intl.message('Enter a custom wallet server',
        desc: '', name: 'enterWalletServer');
  }

  String get enterWalletServerSwitch {
    return Intl.message('Use a custom wallet server',
        desc: '', name: 'enterWalletServerSwitch');
  }

  String get enterTokenApi {
    return Intl.message('Enter url token api', desc: '', name: 'enterTokenApi');
  }

  String get enterExplorerUrlSwitch {
    return Intl.message('Use a custom explorer url',
        desc: '', name: 'enterExplorerUrlSwitch');
  }

  String get enterExplorerUrl {
    return Intl.message('Enter a custom url explorer',
        desc: '', name: 'enterExplorerUrl');
  }

  String get enterExplorerUrlInfo {
    return Intl.message(
        '(ex: https://bismuth.online/search?quicksearch=%1\n"%1" will be replaced by BIS address)',
        desc: '',
        name: 'enterExplorerUrlInfo');
  }

  String get enterWalletServerInfo {
    return Intl.message('ip:port (ex: 11.22.33.44:2000)',
        desc: '', name: 'enterWalletServerInfo');
  }

  String get enterTokenApiInfo {
    return Intl.message('(ex: https://bismuth.today/api/balances/)',
        desc: '', name: 'enterTokenApiInfo');
  }

  /// -- END CUSTOM URL

  /// -- CONTACT ITEMS

  String get removeContact {
    return Intl.message('Remove Contact',
        desc: 'contact_remove_btn', name: 'removeContact');
  }

  String get removeContactConfirmation {
    return Intl.message('Are you sure you want to delete %1?',
        desc: 'contact_remove_sure', name: 'removeContactConfirmation');
  }

  String get contactHeader {
    return Intl.message('Contact',
        desc: 'contact_view_header', name: 'contactHeader');
  }

  String get contactsHeader {
    return Intl.message('Contacts',
        desc: 'contact_header', name: 'contactsHeader');
  }

  String get addContact {
    return Intl.message('Add Contact',
        desc: 'contact_add_button', name: 'addContact');
  }

  String get contactNameHint {
    return Intl.message('Enter a Name @',
        desc: 'contact_name_hint', name: 'contactNameHint');
  }

  String get contactInvalid {
    return Intl.message("Invalid Contact Name",
        desc: 'contact_invalid_name', name: 'contactInvalid');
  }

  String get contactAdded {
    return Intl.message("%1 added to contacts.",
        desc: 'contact_added', name: 'contactAdded');
  }

  String get contactRemoved {
    return Intl.message("%1 has been removed from contacts!",
        desc: 'contact_removed', name: 'contactRemoved');
  }

  String get contactNameMissing {
    return Intl.message("Choose a Name for this Contact",
        desc: 'contact_name_missing', name: 'contactNameMissing');
  }

  String get contactExists {
    return Intl.message("Contact Already Exists",
        desc: 'contact_name_exists', name: 'contactExists');
  }

  /// -- END CONTACT ITEMS

  /// -- INTRO ITEMS
  String get backupYourSeed {
    return Intl.message('Backup your seed',
        desc: 'intro_new_wallet_seed_backup_header', name: 'backupYourSeed');
  }

  String get backupSeedConfirm {
    return Intl.message('Are you sure that you backed up your wallet seed?',
        desc: 'intro_new_wallet_backup', name: 'backupSeedConfirm');
  }

  String get seedBackupInfo {
    return Intl.message(
        "Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
        desc: 'intro_new_wallet_seed',
        name: 'seedBackupInfo');
  }

  String get copySeed {
    return Intl.message("Copy Seed", desc: 'copy_seed_btn', name: 'copySeed');
  }

  String get seedCopiedShort {
    return Intl.message("Seed Copied",
        desc: 'seed_copied_btn', name: 'seedCopiedShort');
  }

  String get importSeed {
    return Intl.message("Import Seed",
        desc: 'intro_seed_header', name: 'importSeed');
  }

  String get importSeedHint {
    return Intl.message("Please enter your seed below.",
        desc: 'intro_seed_info', name: 'importSeedHint');
  }

  String get welcomeText {
    return Intl.message(
        "Welcome to my Bismuth Wallet. To begin, you may create a new wallet or import an existing one.",
        desc: 'intro_welcome_title',
        name: 'welcomeText');
  }

  String get newWallet {
    return Intl.message("New Wallet",
        desc: 'intro_welcome_new_wallet', name: 'newWallet');
  }

  String get importWallet {
    return Intl.message("Import Wallet",
        desc: 'intro_welcome_have_wallet', name: 'importWallet');
  }

  /// -- END INTRO ITEMS

  /// -- SEND ITEMS
  String get sentTo {
    return Intl.message("Sent To", desc: 'sent_to', name: 'sentTo');
  }

  String get sending {
    return Intl.message("Sending", desc: 'send_sending', name: 'sending');
  }

  String get to {
    return Intl.message("To", desc: 'send_to', name: 'to');
  }

  String get sendAmountConfirm {
    return Intl.message("Send %1 BIS",
        desc: 'send_pin_description', name: 'sendAmountConfirm');
  }

  String get sendAmountConfirmPin {
    return sendAmountConfirm;
  }

  String get sendError {
    return Intl.message("An error occurred. Try again later.",
        desc: 'send_generic_error', name: 'sendError');
  }

  String get enterAmount {
    return Intl.message("Enter Amount",
        desc: 'send_amount_hint', name: 'enterAmount');
  }

  String get enterAddress {
    return Intl.message("Enter Address",
        desc: 'enter_address', name: 'enterAddress');
  }

  String get enterOpenfield {
    return Intl.message("Enter Data (Openfield)",
        desc: 'send_openfield_hint', name: 'enterOpenfield');
  }

  String get enterOperation {
    return Intl.message("Enter Operation",
        desc: 'send_operation_hint', name: 'enterOperation');
  }

  String get enterTokenQuantity {
    return Intl.message("Enter Quantity",
        desc: 'send_enterTokenQuantity_hint', name: 'enterTokenQuantity');
  }

  String get sendATokenQuestion {
    return Intl.message("Send a token ?",
        desc: 'sendATokenQuestion_hint', name: 'sendATokenQuestion');
  }

  String get pasteBisUrl {
    return Intl.message("You can paste a BIS url",
        desc: 'pasteBisUrl_hint', name: 'pasteBisUrl');
  }

  String get pasteBisUrlPrefix {
    return Intl.message("('bis://' or 'bis://pay)'",
        desc: 'pasteBisUrlPrefix_hint', name: 'pasteBisUrlPrefix');
  }

  String get pasteBisUrlError {
    return Intl.message("Your clipboard doesn't contain a BIS url",
        desc: 'pasteBisUrlError_hint', name: 'pasteBisUrlError');
  }

  String get available {
    return Intl.message("available", desc: 'available', name: 'available');
  }

  String get openfield {
    return Intl.message("Data (Openfield)",
        desc: 'openfield', name: 'openfield');
  }

  String get operation {
    return Intl.message("Operation", desc: 'operation', name: 'operation');
  }

  String get diacritic {
    return Intl.message(
        "Common accents and diacritical signs will be replacing with an equivalent character",
        desc: 'diacritic',
        name: 'diacritic');
  }

  String get optionalParameters {
    return Intl.message("Optional Parameters",
        desc: 'optionalParameters', name: 'optionalParameters');
  }

  String get invalidAddress {
    return Intl.message("Address entered was invalid",
        desc: 'send_invalid_address', name: 'invalidAddress');
  }

  String get addressMising {
    return Intl.message("Please Enter an Address",
        desc: 'send_enter_address', name: 'addressMising');
  }

  String get amountMissing {
    return Intl.message("Please Enter an Amount",
        desc: 'send_enter_amount', name: 'amountMissing');
  }

  String get tokenQuantityMissing {
    return Intl.message("Please Enter a Quantity",
        desc: 'send_enter_token_quantity', name: 'tokenQuantityMissing');
  }

  String get tokenMissing {
    return Intl.message("Please choose a Token",
        desc: 'send_enter_token', name: 'tokenMissing');
  }

  String get insufficientTokenQuantity {
    return Intl.message("Insufficient Quantity in your wallet",
        desc: 'send_insufficient_token_quantity',
        name: 'insufficientTokenQuantity');
  }

  String get minimumSend {
    return Intl.message("Minimum send amount is %1 BIS",
        desc: 'send_minimum_error', name: 'minimumSend');
  }

  String get insufficientBalance {
    return Intl.message("Insufficient Balance",
        desc: 'send_insufficient_balance', name: 'insufficientBalance');
  }

  String get sendFrom {
    return Intl.message("Send From", desc: 'send_title', name: 'sendFrom');
  }

  String get fees {
    return Intl.message("Fees", desc: 'fees', name: 'fees');
  }

  /// -- END SEND ITEMS

  /// -- PIN SCREEN
  String get pinCreateTitle {
    return Intl.message("Create a 6-digit pin",
        desc: 'pin_create_title', name: 'pinCreateTitle');
  }

  String get pinConfirmTitle {
    return Intl.message("Confirm your pin",
        desc: 'pin_confirm_title', name: 'pinConfirmTitle');
  }

  String get pinEnterTitle {
    return Intl.message("Enter pin",
        desc: 'pin_enter_title', name: 'pinEnterTitle');
  }

  String get pinConfirmError {
    return Intl.message("Pins do not match",
        desc: 'pin_confirm_error', name: 'pinConfirmError');
  }

  String get pinInvalid {
    return Intl.message("Invalid pin entered",
        desc: 'pin_error', name: 'pinInvalid');
  }

  /// -- END PIN SCREEN

  /// -- SETTINGS ITEMS

  String get pickFromList {
    return Intl.message("Pick From a List",
        desc: 'pick rep from list', name: 'pickFromList');
  }

  String get uptime {
    return Intl.message("Uptime", desc: 'Rep uptime', name: 'uptime');
  }

  String get authMethod {
    return Intl.message("Authentication Method",
        desc: 'settings_disable_fingerprint', name: 'authMethod');
  }

  String get pinMethod {
    return Intl.message("PIN", desc: 'settings_pin_method', name: 'pinMethod');
  }

  String get privacyPolicy {
    return Intl.message("Privacy Policy",
        desc: 'settings_privacy_policy', name: 'privacyPolicy');
  }

  String get biometricsMethod {
    return Intl.message("Biometrics",
        desc: 'settings_fingerprint_method', name: 'biometricsMethod');
  }

  String get currency {
    return Intl.message("Currency",
        desc: 'A settings menu item for changing currency', name: 'currency');
  }

  String get changeCurrency {
    return Intl.message("Change Currency",
        desc: 'settings_local_currency', name: 'changeCurrency');
  }

  String get language {
    return Intl.message("Language",
        desc: 'settings_change_language', name: 'language');
  }

  String get logout {
    return Intl.message("Logout", desc: 'settings_logout', name: 'logout');
  }

  String get rootWarning {
    return Intl.message(
        'It appears your device is "rooted", "jailbroken", or modified in a way that compromises security. It is recommended that you reset your device to its original state before proceeding.',
        desc:
            "Shown to users if they have a rooted Android device or jailbroken iOS device",
        name: 'rootWarning');
  }

  String get iUnderstandTheRisks {
    return Intl.message("I Understand the Risks",
        desc:
            "Shown to users if they have a rooted Android device or jailbroken iOS device",
        name: 'iUnderstandTheRisks');
  }

  String get exit {
    return Intl.message("Exit",
        desc: "Exit action, like a button", name: 'exit');
  }

  String get warning {
    return Intl.message("Warning",
        desc: 'settings_logout_alert_title', name: 'warning');
  }

  String get logoutDetail {
    return Intl.message(
        "Logging out will remove your seed and all my Bismuth Wallet-related data from this device. If your seed is not backed up, you will never be able to access your funds again",
        desc: 'settings_logout_alert_message',
        name: 'logoutDetail');
  }

  String get logoutAction {
    return Intl.message("Delete Seed and Logout",
        desc: 'settings_logout_alert_confirm_cta', name: 'logoutAction');
  }

  String get logoutAreYouSure {
    return Intl.message("Are you sure?",
        desc: 'settings_logout_warning_title', name: 'logoutAreYouSure');
  }

  String get logoutReassurance {
    return Intl.message(
        "As long as you've backed up your seed you have nothing to worry about.",
        desc: 'settings_logout_warning_message',
        name: 'logoutReassurance');
  }

  String get settingsHeader {
    return Intl.message("Settings",
        desc: 'settings_title', name: 'settingsHeader');
  }

  String get preferences {
    return Intl.message("Preferences",
        desc: 'settings_preferences_header', name: 'preferences');
  }

  String get informations {
    return Intl.message("Informations",
        desc: 'settings_informations_header', name: 'informations');
  }

  String get letsPlay {
    return Intl.message("Let's play", desc: '', name: 'letsPlay');
  }

  String get searchField {
    return Intl.message("Search...",
        desc: 'search_field_hint', name: 'searchField');
  }

  String get myTokens {
    return Intl.message("Tokens", desc: 'my_tokens_button', name: 'myTokens');
  }

  String get myTokensListHeader {
    return Intl.message("My Token List",
        desc: 'my_tokens_list_header', name: 'myTokensListHeader');
  }

  String get noTokenOwner {
    return Intl.message("You don't have any token",
        desc: 'no_token_owner_error', name: 'noTokenOwner');
  }

  String get tokensListHeader {
    return Intl.message("Token List",
        desc: 'settings_tokens_list_header', name: 'tokensListHeader');
  }

  String get tokensListTotalSupply {
    return Intl.message("Total supply : ",
        desc: 'settings_tokens_list_total_supply',
        name: 'tokensListTotalSupply');
  }

  String get tokensListCreatedThe {
    return Intl.message("Created the ",
        desc: 'settings_tokens_list_created_the', name: 'tokensListCreatedThe');
  }

  String get tokensListCreatedBy {
    return Intl.message("By ",
        desc: 'settings_tokens_list_created_by', name: 'tokensListCreatedBy');
  }

  String get manage {
    return Intl.message("Manage",
        desc: 'settings_manage_header', name: 'manage');
  }

  String get backupSeed {
    return Intl.message("Backup Seed",
        desc: 'settings_backup_seed', name: 'backupSeed');
  }

  String get fingerprintSeedBackup {
    return Intl.message("Authenticate to backup seed.",
        desc: 'settings_fingerprint_title', name: 'fingerprintSeedBackup');
  }

  String get pinSeedBackup {
    return Intl.message("Enter PIN to Backup Seed",
        desc: 'settings_pin_title', name: 'pinSeedBackup');
  }

  String get systemDefault {
    return Intl.message("System Default",
        desc: 'settings_default_language_string', name: 'systemDefault');
  }

  /// -- END SETTINGS ITEMS

  // Scan

  String get scanInstructions {
    return Intl.message("Scan a Bismuth \naddress QR code",
        desc: 'scan_send_instruction_label', name: 'scanInstructions');
  }

  /// -- LOCK SCREEN

  String get unlockPin {
    return Intl.message("Enter PIN to Unlock my Bismuth Wallet",
        desc: 'unlock_bismuth_pin', name: 'unlockPin');
  }

  String get unlockBiometrics {
    return Intl.message("Authenticate to Unlock my Bismuth Wallet",
        desc: 'unlock_bismuth_bio', name: 'unlockBiometrics');
  }

  String get lockAppSetting {
    return Intl.message("Authenticate on Launch",
        desc: 'authenticate_on_launch', name: 'lockAppSetting');
  }

  String get locked {
    return Intl.message("Locked", desc: 'lockedtxt', name: 'locked');
  }

  String get unlock {
    return Intl.message("Unlock", desc: 'unlocktxt', name: 'unlock');
  }

  String get tooManyFailedAttempts {
    return Intl.message("Too many failed unlock attempts.",
        desc: 'fail_toomany_attempts', name: 'tooManyFailedAttempts');
  }

  /// -- END LOCK SCREEN

  /// -- SECURITY SETTINGS SUBMENU

  String get securityHeader {
    return Intl.message("Security",
        desc: 'security_header', name: 'securityHeader');
  }

  String get autoLockHeader {
    return Intl.message("Automatically Lock",
        desc: 'auto_lock_header', name: 'autoLockHeader');
  }

  String get xMinutes {
    return Intl.message("After %1 minutes",
        desc: 'after_minutes', name: 'xMinutes');
  }

  String get xMinute {
    return Intl.message("After %1 minute",
        desc: 'after_minute', name: 'xMinute');
  }

  String get instantly {
    return Intl.message("Instantly", desc: 'insantly', name: 'instantly');
  }

  String get setWalletPassword {
    return Intl.message("Set Wallet Password",
        desc: 'Allows user to encrypt wallet with a password',
        name: 'setWalletPassword');
  }

  String get setPassword {
    return Intl.message("Set Password",
        desc: 'A button that sets the wallet password', name: 'setPassword');
  }

  String get disableWalletPassword {
    return Intl.message("Disable Wallet Password",
        desc: 'Allows user to deencrypt wallet with a password',
        name: 'disableWalletPassword');
  }

  String get encryptionFailedError {
    return Intl.message("Failed to set a wallet password",
        desc: 'If encrypting a wallet raised an error',
        name: 'encryptionFailedError');
  }

  String get setPasswordSuccess {
    return Intl.message("Password has been set successfully",
        desc: 'Setting a Wallet Password was successful',
        name: 'setPasswordSuccess');
  }

  String get disablePasswordSuccess {
    return Intl.message("Password has been disabled",
        desc: 'Disabling a Wallet Password was successful',
        name: 'disablePasswordSuccess');
  }

  /// -- END SECURITY SETTINGS SUBMENU

  /// -- EXAMPLE HOME SCREEN CARDS

  String get exampleCardIntro {
    return Intl.message(
        "Welcome to my Bismuth Wallet. Once you receive BIS, transactions will show up like this:",
        desc: 'example_card_intro',
        name: 'exampleCardIntro');
  }

  String get exampleCardLittle {
    return Intl.message("A little",
        desc: 'example_card_little', name: 'exampleCardLittle');
  }

  String get exampleCardLot {
    return Intl.message("A lot of",
        desc: 'example_card_lot', name: 'exampleCardLot');
  }

  String get exampleCardTo {
    return Intl.message("to someone",
        desc: 'example_card_to', name: 'exampleCardTo');
  }

  String get exampleCardFrom {
    return Intl.message("from someone",
        desc: 'example_card_from', name: 'exampleCardFrom');
  }

  /// -- END EXAMPLE HOME SCREEN CARDS

  /// -- START MULTI-ACCOUNT

  String get defaultAccountName {
    return Intl.message("Main Account",
        desc: "Default account name", name: 'defaultAccountName');
  }

  String get defaultNewAccountName {
    return Intl.message("Account %1",
        desc: "Default new account name - e.g. Account 1",
        name: 'defaultNewAccountName');
  }

  String get newAccountIntro {
    return Intl.message(
        "This is your new account. Once you receive BIS, transactions will show up like this:",
        desc: 'Alternate account intro card',
        name: 'newAccountIntro');
  }

  String get account {
    return Intl.message("Account", desc: "Account text", name: 'account');
  }

  String get accounts {
    return Intl.message("Accounts", desc: "Accounts header", name: 'accounts');
  }

  String get addAccount {
    return Intl.message("Add Account",
        desc: "Default new account name - e.g. Account 1", name: 'addAccount');
  }

  String get hideAccountHeader {
    return Intl.message("Hide Account?",
        desc: "Confirmation dialog header", name: 'hideAccountHeader');
  }

  String get removeAccountText {
    return Intl.message(
        "Are you sure you want to hide this account? You can re-add it later by tapping the \"%1\" button.",
        desc: "Remove account dialog body",
        name: 'removeAccountText');
  }

  /// -- END MULTI-ACCOUNT

  String get tapToReveal {
    return Intl.message("Tap to reveal",
        desc: "Tap to reveal hidden content", name: 'tapToReveal');
  }

  String get tapToHide {
    return Intl.message("Tap to hide",
        desc: "Tap to hide content", name: 'tapToHide');
  }

  String get copied {
    return Intl.message("Copied",
        desc: "Copied (to clipboard)", name: 'copied');
  }

  String get copy {
    return Intl.message("Copy", desc: "Copy (to clipboard)", name: 'copy');
  }

  String get seedDescription {
    return Intl.message(
        "A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you'll have access to your funds.",
        desc: "Describing what a seed is",
        name: 'seedDescription');
  }

  String get importSecretPhrase {
    return Intl.message("Import Secret Phrase",
        desc: "Header for restoring using mnemonic",
        name: 'importSecretPhrase');
  }

  String get importSecretPhraseHint {
    return Intl.message(
        "Please enter your 24-word secret phrase below. Each word should be separated by a space.",
        desc: 'helper message for importing mnemnic',
        name: 'importSecretPhraseHint');
  }

  String get qrMnemonicError {
    return Intl.message("QR does not contain a valid secret phrase",
        desc: 'When QR does not contain a valid mnemonic phrase',
        name: 'qrMnemonicError');
  }

  String get mnemonicInvalidWord {
    return Intl.message("%1 is not a valid word",
        desc: 'A word that is not part of bip39', name: 'mnemonicInvalidWord');
  }

  String get mnemonicSizeError {
    return Intl.message("Secret phrase may only contain 24 words",
        desc: 'err', name: 'mnemonicSizeError');
  }

  String get secretPhrase {
    return Intl.message("Secret Phrase",
        desc: 'Secret (mnemonic) phrase', name: 'secretPhrase');
  }

  String get backupConfirmButton {
    return Intl.message("I've Backed It Up",
        desc: 'Has backed up seed confirmation button',
        name: 'backupConfirmButton');
  }

  String get secretInfoHeader {
    return Intl.message("Safety First!",
        desc: 'secret info header', name: 'secretInfoHeader');
  }

  String get secretInfo {
    return Intl.message(
        "In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone.",
        desc: 'Description for seed',
        name: 'secretInfo');
  }

  String get secretWarning {
    return Intl.message(
        "If you lose your device or uninstall the application, you'll need your secret phrase or seed to recover your funds!",
        desc: 'Secret warning',
        name: 'secretWarning');
  }

  String get gotItButton {
    return Intl.message("Got It!",
        desc: 'Got It! Acknowledgement button', name: 'gotItButton');
  }

  String get ackBackedUp {
    return Intl.message(
        "Are you sure that you've backed up your secret phrase or seed?",
        desc: 'Ack backed up',
        name: 'ackBackedUp');
  }

  String get secretPhraseCopy {
    return Intl.message("Copy Secret Phrase",
        desc: 'Copy secret phrase to clipboard', name: 'secretPhraseCopy');
  }

  String get secretPhraseCopied {
    return Intl.message("Secret Phrase Copied",
        desc: 'Copied secret phrase to clipboard', name: 'secretPhraseCopied');
  }

  String get import {
    return Intl.message("Import", desc: "Generic import", name: 'import');
  }

  String get importSeedInstead {
    return Intl.message("Import Seed Instead",
        desc: "importSeedInstead", name: 'importSeedInstead');
  }

  String get switchToSeed {
    return Intl.message("Switch to Seed",
        desc: "switchToSeed", name: 'switchToSeed');
  }

  String get backupSecretPhrase {
    return Intl.message("Backup Secret Phrase",
        desc: 'backup seed', name: 'backupSecretPhrase');
  }

  /// -- SEED PROCESS

  /// -- END SEED PROCESS

  /// HINTS
  String get createPasswordHint {
    return Intl.message("Create a password",
        desc: 'A text field hint that tells the user to create a password',
        name: 'createPasswordHint');
  }

  String get confirmPasswordHint {
    return Intl.message("Confirm the password",
        desc: 'A text field hint that tells the user to confirm the password',
        name: 'confirmPasswordHint');
  }

  String get enterPasswordHint {
    return Intl.message("Enter your password",
        desc: 'A text field hint that tells the users to enter their password',
        name: 'enterPasswordHint');
  }

  String get passwordsDontMatch {
    return Intl.message("Passwords do not match",
        desc: 'An error indicating a password has been confirmed incorrectly',
        name: 'passwordsDontMatch');
  }

  String get passwordBlank {
    return Intl.message("Password cannot be empty",
        desc: 'An error indicating a password has been entered incorrectly',
        name: 'passwordBlank');
  }

  String get invalidPassword {
    return Intl.message("Invalid Password",
        desc: 'An error indicating a password has been entered incorrectly',
        name: 'invalidPassword');
  }

  /// HINTS END

  /// PARAGRAPS
  String get passwordWillBeRequiredToOpenParagraph {
    return Intl.message(
        "This password will be required to open my Bismuth Wallet.",
        desc:
            'A paragraph that tells the users that the created password will be required to open my Bismuth Wallet.',
        name: 'passwordWillBeRequiredToOpenParagraph');
  }

  String get passwordNoLongerRequiredToOpenParagraph {
    return Intl.message(
        "You will not need a password to open my Bismuth Wallet anymore.",
        desc:
            'An info paragraph that tells the user a password will no longer be needed to open my Bismuth Wallet',
        name: 'passwordNoLongerRequiredToOpenParagraph');
  }

  String get createPasswordFirstParagraph {
    return Intl.message(
        "You can create a password to add additional security to your wallet.",
        desc:
            'A paragraph that tells the users that they can create a password for additional security.',
        name: 'createPasswordFirstParagraph');
  }

  String get createPasswordSecondParagraph {
    return Intl.message(
        "Password is optional, and your wallet will be protected with your PIN or biometrics regardless.",
        desc:
            'A paragraph that tells the users that the password creation is optional and the wallet will be still protected with biometrics or PIN regardless.',
        name: 'createPasswordSecondParagraph');
  }

  /// PARAGRAPS END

  /// HEADERS
  String get createAPasswordHeader {
    return Intl.message("Create a password.",
        desc: 'A paragraph that tells the users to create a password.',
        name: 'createAPasswordHeader');
  }

  String get createPasswordSheetHeader {
    return Intl.message("Create",
        desc: 'Prompt user to create a new password',
        name: 'createPasswordSheetHeader');
  }

  String get disablePasswordSheetHeader {
    return Intl.message("Disable",
        desc: 'Prompt user to disable their password',
        name: 'disablePasswordSheetHeader');
  }

  String get requireAPasswordToOpenHeader {
    return Intl.message("Require a password to open my Bismuth Wallet?",
        desc:
            'A paragraph that asks the users if they would like a password to be required to open my Bismuth Wallet.',
        name: 'requireAPasswordToOpenHeader');
  }

  /// HEADERS END

  String get releaseNoteHeader {
    return Intl.message("What's new",
        desc: "What's new", name: 'releaseNoteHeader');
  }

  String get ok {
    return Intl.message("Ok", desc: "", name: 'ok');
  }

  /// BUTTONS
  String get noSkipButton {
    return Intl.message("No, Skip",
        desc: 'A button that declines and skips the mentioned process.',
        name: 'noSkipButton');
  }

  String get yesButton {
    return Intl.message("Yes",
        desc: 'A button that accepts the mentioned process.',
        name: 'yesButton');
  }

  String get nextButton {
    return Intl.message("Next",
        desc: 'A button that goes to the next screen.', name: 'nextButton');
  }

  String get goBackButton {
    return Intl.message("Go Back",
        desc: 'A button that goes to the previous screen.',
        name: 'goBackButton');
  }

  String get supportButton {
    return Intl.message("Support",
        desc: 'A button to open up the live support window',
        name: 'supportButton');
  }

  String get liveSupportButton {
    return Intl.message("Support",
        desc: 'A button to open up the live support window',
        name: 'liveSupportButton');
  }

  /// BUTTONS END

  /// Live chat
  String get connectingHeader {
    return Intl.message("Connecting",
        desc:
            'A header to let the user now that my Bismuth Wallet is currently connecting to (or loading) live chat.',
        name: 'connectingHeader');
  }

  Future<String> getAccountExplorerUrl(String account) async {
    String explorerUrl = await sl.get<SharedPrefsUtil>().getExplorerUrl();
    return explorerUrl.replaceAll("%1", account);
  }

  String get privacyUrl {
    return 'https://hypernodes.bismuth.live/?page_id=2565';
  }

  String get donationsUrl {
    return 'Bis1GbkkAETTh8Q1k5KuHtV2pU2rmBhzUDTHo';
  }

  String get dragginatorAddress {
    return '9ba0f8ca03439a8b4222b256a5f56f4f563f6d83755f525992fa5daf';
  }

  String getDragginatorHelp() {
    return 'https://dragginator.com/help.php';
  }

  String get donationsName {
    return '@Donations';
  }

  String get explorerUrlByDefault {
    return 'https://bismuth.online/search?quicksearch=%1';
  }

  /// -- END NON-TRANSLATABLE ITEMS
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  final LanguageSetting languageSetting;

  const AppLocalizationsDelegate(this.languageSetting);

  @override
  bool isSupported(Locale locale) {
    return languageSetting != null;
  }

  @override
  Future<AppLocalization> load(Locale locale) {
    if (languageSetting.language == AvailableLanguage.DEFAULT) {
      return AppLocalization.load(locale);
    }
    return AppLocalization.load(Locale(languageSetting.getLocaleString()));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}

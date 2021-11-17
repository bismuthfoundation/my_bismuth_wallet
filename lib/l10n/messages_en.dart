// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

// Package imports:
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Are you sure that you\'ve backed up your secret phrase or seed?"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Add Account"),
        "addContact": MessageLookupByLibrary.simpleMessage("Add Contact"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("Address Copied"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Enter Address"),
        "addressMising":
            MessageLookupByLibrary.simpleMessage("Please Enter an Address"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Share Address"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Please Enter an Amount"),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Authentication Method"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automatically Lock"),
        "available": MessageLookupByLibrary.simpleMessage("available"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("I\'ve Backed It Up"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Backup Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure that you backed up your wallet seed?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Backup your seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrics"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Change Currency"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "contactAdded":
            MessageLookupByLibrary.simpleMessage("%1 added to contacts."),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Contact Already Exists"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Contact"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid Contact Name"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Enter a Name @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Choose a Name for this Contact"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 has been removed from contacts!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Contacts"),
        "copied": MessageLookupByLibrary.simpleMessage("Copied"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copy Address"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Copy Seed"),
        "customUrlHeader": MessageLookupByLibrary.simpleMessage("Custom Urls"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Main Account"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Account %1"),
        "diacritic": MessageLookupByLibrary.simpleMessage(
            "Common accents and diacritical signs will be replacing with an equivalent character"),
        "enterAddress": MessageLookupByLibrary.simpleMessage("Enter Address"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Enter Amount"),
        "enterExplorerUrl":
            MessageLookupByLibrary.simpleMessage("Enter a custom url explorer"),
        "enterExplorerUrlInfo": MessageLookupByLibrary.simpleMessage(
            "(ex: https://bismuth.online/search?quicksearch=%1\n\'%1\' will be replaced by BIS address)"),
        "enterExplorerUrlSwitch":
            MessageLookupByLibrary.simpleMessage("Use a custom explorer url"),
        "enterOpenfield":
            MessageLookupByLibrary.simpleMessage("Enter Data (Openfield)"),
        "enterOperation":
            MessageLookupByLibrary.simpleMessage("Enter Operation"),
        "enterTokenApi":
            MessageLookupByLibrary.simpleMessage("Enter url token api"),
        "enterTokenApiInfo": MessageLookupByLibrary.simpleMessage(
            "(ex: https://bismuth.today/api/balances/)"),
        "enterTokenQuantity":
            MessageLookupByLibrary.simpleMessage("Enter Quantity"),
        "enterWalletServer": MessageLookupByLibrary.simpleMessage(
            "Enter a custom wallet server"),
        "enterWalletServerInfo": MessageLookupByLibrary.simpleMessage(
            "ip:port (ex: 11.22.33.44:2000)"),
        "enterWalletServerSwitch":
            MessageLookupByLibrary.simpleMessage("Use a custom wallet server"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("from someone"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Welcome to my Bismuth Wallet. Once you receive BIS, transactions will show up like this:"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("A little"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("A lot of"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("to someone"),
        "fees": MessageLookupByLibrary.simpleMessage("Fees"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Authenticate to backup seed."),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Got It!"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Hide Account?"),
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Import Secret Phrase"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Please enter your 24-word secret phrase below. Each word should be separated by a space."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Import Seed"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Please enter your seed below."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Import Seed Instead"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Import Wallet"),
        "informations": MessageLookupByLibrary.simpleMessage("Informations"),
        "instantly": MessageLookupByLibrary.simpleMessage("Instantly"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Insufficient Balance"),
        "insufficientTokenQuantity": MessageLookupByLibrary.simpleMessage(
            "Insufficient Quantity in your wallet"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Address entered was invalid"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Authenticate on Launch"),
        "locked": MessageLookupByLibrary.simpleMessage("Locked"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Delete Seed and Logout"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Logging out will remove your seed and all my Bismuth Wallet-related data from this device. If your seed is not backed up, you will never be able to access your funds again"),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "As long as you\'ve backed up your seed you have nothing to worry about."),
        "manage": MessageLookupByLibrary.simpleMessage("Manage"),
        "mempool": MessageLookupByLibrary.simpleMessage("Unconfirmed"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 is not a valid word"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Secret phrase may only contain 24 words"),
        "myTokens": MessageLookupByLibrary.simpleMessage("Tokens"),
        "myTokensListHeader":
            MessageLookupByLibrary.simpleMessage("My Token List"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "This is your new account. Once you receive BIS, transactions will show up like this:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("New Wallet"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noTokenOwner":
            MessageLookupByLibrary.simpleMessage("You don\'t have any token"),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "onStr": MessageLookupByLibrary.simpleMessage("On"),
        "openfield": MessageLookupByLibrary.simpleMessage("Data (Openfield)"),
        "operation": MessageLookupByLibrary.simpleMessage("Operation"),
        "optionalParameters":
            MessageLookupByLibrary.simpleMessage("Optional Parameters"),
        "pasteBisUrl":
            MessageLookupByLibrary.simpleMessage("You can paste a BIS url"),
        "pasteBisUrlError": MessageLookupByLibrary.simpleMessage(
            "Your clipboard doesn\'t contain a BIS url"),
        "pasteBisUrlPrefix": MessageLookupByLibrary.simpleMessage(
            "(\'bis://\' or \'bis://pay)\'"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("Pins do not match"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Confirm your pin"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Create a 6-digit pin"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Enter pin"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Invalid pin entered"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinSeedBackup":
            MessageLookupByLibrary.simpleMessage("Enter PIN to Backup Seed"),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid address"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid seed or private key"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "QR does not contain a valid secret phrase"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "received": MessageLookupByLibrary.simpleMessage("Received"),
        "releaseNoteHeader":
            MessageLookupByLibrary.simpleMessage("What\'s new"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to hide this account? You can re-add it later by tapping the \"%1\" button."),
        "removeContact": MessageLookupByLibrary.simpleMessage("Remove Contact"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete %1?"),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Scan a Bismuth \naddress QR code"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Scan QR Code"),
        "searchField": MessageLookupByLibrary.simpleMessage("Search..."),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Safety First!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Secret Phrase"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Secret Phrase Copied"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Copy Secret Phrase"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "If you lose your device or uninstall the application, you\'ll need your secret phrase or seed to recover your funds!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Security"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Below is your wallet\'s seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed Copied to Clipboard\nIt is pasteable for 2 minutes."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed Copied"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "A seed bears the same information as a secret phrase, but in a machine-readable way. As long as you have one of them backed up, you\'ll have access to your funds."),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Seed is Invalid"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendATokenQuestion":
            MessageLookupByLibrary.simpleMessage("Send a token ?"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Send %1 BIS"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "An error occurred. Try again later."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Send From"),
        "sending": MessageLookupByLibrary.simpleMessage("Sending"),
        "sent": MessageLookupByLibrary.simpleMessage("Sent"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Sent To"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Settings"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("Switch to Seed"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("System Default"),
        "tapToHide": MessageLookupByLibrary.simpleMessage("Tap to hide"),
        "tapToReveal": MessageLookupByLibrary.simpleMessage("Tap to reveal"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "tokenMissing":
            MessageLookupByLibrary.simpleMessage("Please choose a Token"),
        "tokenQuantityMissing":
            MessageLookupByLibrary.simpleMessage("Please Enter a Quantity"),
        "tokensListCreatedBy": MessageLookupByLibrary.simpleMessage("By "),
        "tokensListCreatedThe":
            MessageLookupByLibrary.simpleMessage("Created the "),
        "tokensListHeader": MessageLookupByLibrary.simpleMessage("Token List"),
        "tokensListTotalSupply":
            MessageLookupByLibrary.simpleMessage("Total supply : "),
        "tooManyFailedAttempts": MessageLookupByLibrary.simpleMessage(
            "Too many failed unlock attempts."),
        "transactionDetailAmount":
            MessageLookupByLibrary.simpleMessage("Amount"),
        "transactionDetailBlock": MessageLookupByLibrary.simpleMessage("Block"),
        "transactionDetailCopyPaste": MessageLookupByLibrary.simpleMessage(
            "Double click on text to copy to clipboard"),
        "transactionDetailDate": MessageLookupByLibrary.simpleMessage("Date"),
        "transactionDetailFee": MessageLookupByLibrary.simpleMessage("Fee"),
        "transactionDetailFrom":
            MessageLookupByLibrary.simpleMessage("From address"),
        "transactionDetailOpenfield":
            MessageLookupByLibrary.simpleMessage("Data (Openfield)"),
        "transactionDetailOperation":
            MessageLookupByLibrary.simpleMessage("Operation"),
        "transactionDetailReward":
            MessageLookupByLibrary.simpleMessage("Reward"),
        "transactionDetailSignature":
            MessageLookupByLibrary.simpleMessage("Signature"),
        "transactionDetailTo":
            MessageLookupByLibrary.simpleMessage("To address"),
        "transactionDetailTxId":
            MessageLookupByLibrary.simpleMessage("Transaction id"),
        "transactionHeader":
            MessageLookupByLibrary.simpleMessage("Transaction"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "unlock": MessageLookupByLibrary.simpleMessage("Unlock"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Authenticate to Unlock my Bismuth Wallet"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Enter PIN to Unlock my Bismuth Wallet"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Welcome to my Bismuth Wallet. To begin, you may create a new wallet or import an existing one."),
        "xMinute": MessageLookupByLibrary.simpleMessage("After %1 minute"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("After %1 minutes"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}

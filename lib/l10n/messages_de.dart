// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Konto"),
        "accounts": MessageLookupByLibrary.simpleMessage("Konten"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Bist du dir sicher, dass du deine Geheimsequenz oder deinen Seed gesichert hast?"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Konto hinzufügen"),
        "addContact": MessageLookupByLibrary.simpleMessage("Neuer Kontakt"),
        "addressCopied":
            MessageLookupByLibrary.simpleMessage("Adresse kopiert"),
        "addressHint": MessageLookupByLibrary.simpleMessage("Adresse eingeben"),
        "addressMising":
            MessageLookupByLibrary.simpleMessage("Bitte Adresse eingeben"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Teilen"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Bitte Betrag eingeben"),
        "authMethod": MessageLookupByLibrary.simpleMessage(
            "Authentifizierungs-Verfahren"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Automatisch sperren"),
        "available": MessageLookupByLibrary.simpleMessage("verfügbar"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("Ich habe den Seed gesichert"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz sichern"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Seed sichern"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Bist du sicher, dass du deinen Seed gesichert hast?"),
        "backupYourSeed":
            MessageLookupByLibrary.simpleMessage("Sichere deinen Seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrie"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "changeCurrency":
            MessageLookupByLibrary.simpleMessage("Währung ändern"),
        "close": MessageLookupByLibrary.simpleMessage("Schließen"),
        "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Passwort bestätigen"),
        "connectingHeader": MessageLookupByLibrary.simpleMessage("Verbindet"),
        "contactAdded": MessageLookupByLibrary.simpleMessage(
            "%1 zu Kontakten hinzugefügt!"),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Kontakt bereits vorhanden"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Kontakt"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Ungültiger Kontaktname"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Namen eingeben @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Gib diesem Kontakt einen Namen"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 wurde aus den Kontakten gelöscht!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Kontakte"),
        "copied": MessageLookupByLibrary.simpleMessage("Kopiert"),
        "copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Adresse kopieren"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Seed kopieren"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Wähle ein Passwort."),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Für zusätzliche Sicherheit kannst du ein Passwort festlegen."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Ein Passwort wählen"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "Das Passwort ist optional. Dein Wallet wird immer mithilfe einer PIN oder biometrischen Daten geschützt."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Wählen"),
        "currency": MessageLookupByLibrary.simpleMessage("Währung"),
        "customUrlHeader":
            MessageLookupByLibrary.simpleMessage("Definierte Urls"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Hauptkonto"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Name des neuen Kontos %1"),
        "diacritic": MessageLookupByLibrary.simpleMessage(
            "Gemeinsame Akzente und diakritische Zeichen werden durch ein gleichwertiges Zeichen ersetzt"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Deaktivieren"),
        "disablePasswordSuccess":
            MessageLookupByLibrary.simpleMessage("Passwort wurde deaktiviert"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort deaktivieren"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort konnte nicht festgelegt werden"),
        "enterAddress":
            MessageLookupByLibrary.simpleMessage("Adresse eingeben"),
        "enterAmount": MessageLookupByLibrary.simpleMessage("Betrag eingeben"),
        "enterExplorerUrl": MessageLookupByLibrary.simpleMessage(
            "Trage eigene Explorer Url ein"),
        "enterExplorerUrlInfo": MessageLookupByLibrary.simpleMessage(
            "(z.B. https://bismuth.online/search?quicksearch=%1\n\'%1\' wird durch BIS Adresse ersetzt)"),
        "enterExplorerUrlSwitch":
            MessageLookupByLibrary.simpleMessage("Benutze eigene Explorer Url"),
        "enterOpenfield":
            MessageLookupByLibrary.simpleMessage("Data (Openfield) eingeben"),
        "enterOperation":
            MessageLookupByLibrary.simpleMessage("Enter Operation"),
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
        "enterTokenApi":
            MessageLookupByLibrary.simpleMessage("Trage URL Token API ein"),
        "enterTokenApiInfo": MessageLookupByLibrary.simpleMessage(
            "(ex: https://bismuth.today/api/balances/)"),
        "enterTokenQuantity":
            MessageLookupByLibrary.simpleMessage("Anzahl Eingeben"),
        "enterWalletServer": MessageLookupByLibrary.simpleMessage(
            "Trage eigenen Wallet Server ein"),
        "enterWalletServerInfo": MessageLookupByLibrary.simpleMessage(
            "ip:port (ex: 11.22.33.44:2000)"),
        "enterWalletServerSwitch": MessageLookupByLibrary.simpleMessage(
            "Benutze eignen Wallet Server"),
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("Von jemandem"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei my Bismuth Wallet. Wenn du Bismuth sendest oder empfängst, sieht es aus wie folgt: "),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Ein paar"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Ein paar mehr"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("An jemanden"),
        "exit": MessageLookupByLibrary.simpleMessage("Verlassen"),
        "fees": MessageLookupByLibrary.simpleMessage("Gebühren"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Fingerabdruck scannen, um Seed zu sichern."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Zurück"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Verstanden!"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Konto verbergen?"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Ich verstehe die Risiken"),
        "import": MessageLookupByLibrary.simpleMessage("Importieren"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz importieren"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Bitte gib unten deine 24-wörtige Geheimsequenz ein. Trenne die Wörter dabei mit Leerzeichen."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Seed importieren"),
        "importSeedHint":
            MessageLookupByLibrary.simpleMessage("Bitte füge deinen Seed ein."),
        "importSeedInstead": MessageLookupByLibrary.simpleMessage(
            "Stattdessen Seed importieren"),
        "importWallet":
            MessageLookupByLibrary.simpleMessage("Wallet importieren"),
        "informations": MessageLookupByLibrary.simpleMessage("Informationen"),
        "instantly": MessageLookupByLibrary.simpleMessage("Sofort"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Nicht genügend Guthaben"),
        "insufficientTokenQuantity": MessageLookupByLibrary.simpleMessage(
            "Unzureichende Anzahl im Wallet"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Ungültige Empfänger-Adresse"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Ungültiges Passwort"),
        "language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "liveSupportButton": MessageLookupByLibrary.simpleMessage("Support"),
        "lockAppSetting": MessageLookupByLibrary.simpleMessage(
            "Authentifizierung beim Öffnen"),
        "locked": MessageLookupByLibrary.simpleMessage("Gesperrt"),
        "logout": MessageLookupByLibrary.simpleMessage("Ausloggen"),
        "logoutAction":
            MessageLookupByLibrary.simpleMessage("Seed löschen und ausloggen"),
        "logoutAreYouSure":
            MessageLookupByLibrary.simpleMessage("Bist du dir sicher?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Beim Ausloggen werden dein Seed und alle mit my Bismuth Wallet verbundenen Daten von diesem Gerät gelöscht. Falls du deinen Seed nicht gesichert hast, verlierst du dauerhaft den Zugriff auf dein Guthaben."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Solange du deinen Seed gesichert hast, musst du dir keine Gedanken machen."),
        "manage": MessageLookupByLibrary.simpleMessage("Verwaltung"),
        "mempool": MessageLookupByLibrary.simpleMessage("Unbestätigt"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 ist kein gültiges Wort"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "Die Geheimsequenz muss 24 Wörter enthalten"),
        "myTokens": MessageLookupByLibrary.simpleMessage("Tokens"),
        "myTokensListHeader":
            MessageLookupByLibrary.simpleMessage("Meine Token Liste"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Dies ist dein neues Konto. Sobald du deine ersten Bismuth erhalten hast, werden die Transktionen wie folgt angezeigt:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Neues Wallet"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Weiter"),
        "no": MessageLookupByLibrary.simpleMessage("Nein"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("Überspringen"),
        "noTokenOwner":
            MessageLookupByLibrary.simpleMessage("Du hast keine Token"),
        "off": MessageLookupByLibrary.simpleMessage("Aus"),
        "onStr": MessageLookupByLibrary.simpleMessage("An"),
        "openfield": MessageLookupByLibrary.simpleMessage("Data (Openfield)"),
        "operation": MessageLookupByLibrary.simpleMessage("Operation"),
        "optionalParameters":
            MessageLookupByLibrary.simpleMessage("Optionale Parameter"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "Passwort darf nicht leer sein"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Zum Öffnen der App wird jetzt kein Passwort mehr benötigt."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Dieses Passwort wird benötigt, um my Bismuth Wallet zu öffnen."),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Passwörter stimmen nicht überein"),
        "pasteBisUrl": MessageLookupByLibrary.simpleMessage(
            "Du kannst eine BIS url einfügen"),
        "pasteBisUrlError": MessageLookupByLibrary.simpleMessage(
            "Die Zwischenablage beinhaltet keine BIS url"),
        "pasteBisUrlPrefix": MessageLookupByLibrary.simpleMessage(
            "(\'bis://\' or \'bis://pay)\'"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("PINs stimmen nicht überein"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Bestätige deine PIN"),
        "pinCreateTitle": MessageLookupByLibrary.simpleMessage(
            "Erstelle eine 6-stellige PIN"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("PIN eingeben"),
        "pinInvalid":
            MessageLookupByLibrary.simpleMessage("Falsche PIN eingegeben"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "PIN eingeben, um Seed zu sehen."),
        "preferences": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Datenschutz"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "QR-Code enthält kein gültiges Ziel"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Bitte Kamerazugriff erlauben, um QR-Codes zu scannen"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "Der QR-Code enthält keinen gültigen Seed oder Private Key"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "Der QR-Code enthält keine gültige Geheimsequenz"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage(
            "QR-Code konnte nicht gelesen werden"),
        "receive": MessageLookupByLibrary.simpleMessage("Empfangen"),
        "received": MessageLookupByLibrary.simpleMessage("Empfangen"),
        "releaseNoteHeader":
            MessageLookupByLibrary.simpleMessage("Neuigkeiten"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Bist du dir sicher, dass du dieses Konto verbergen willst? Du kannst es später durch Tippen auf den \"%1\"-Button wieder hinzufügen."),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Kontakt löschen"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Willst du %1 wirklich löschen?"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Passwortabfrage beim Öffnen der App?"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Es sieht aus, als seien Änderungen an deinem Gerät vorgenommen worden, welche dessen Sicherheit beeinträchtigen. Es wird empfohlen, das Gerät in seinen Originalzustand zurückzusetzen."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Scanne einen\nBismuth-Address-QR-Code"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
        "searchField": MessageLookupByLibrary.simpleMessage("Suche..."),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Auf der nächsten Seite siehst du deine Geheimsequenz. Diese erlaubt dir Zugriff auf dein Guthaben. Es ist sehr wichtig, dass du sie sicherst und geheim hältst."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Sicherheit geht vor!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Geheimsequenz"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz kopiert"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Geheimsequenz kopieren"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Solltest du dein Gerät verlieren oder die App löschen, benötigst du deine Geheimsequenz oder deinen Seed, um auf dein Guthaben zugreifen zu können!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Sicherheit"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Unten siehst du deinen Seed. Es ist extrem wichtig, dass du ein Backup deines Seeds erstellst. Sichere deinen Seed niemals als Klartext oder mit einem Screenshot."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed in Zwischenablage kopiert.\n Du kannst ihn jetzt 2 Minuten lang einfügen."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed kopiert"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Ein Seed enthält dieselben Informationen wie eine Geheimsequenz, ist jedoch maschinell lesbar. Solange du eines der beiden gesichert hast, hast du Zugriff auf dein Guthaben."),
        "seedInvalid":
            MessageLookupByLibrary.simpleMessage("Seed ist ungültig."),
        "send": MessageLookupByLibrary.simpleMessage("Senden"),
        "sendATokenQuestion":
            MessageLookupByLibrary.simpleMessage("Token Senden ?"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("%1 Bismuth senden?"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Ein Fehler ist aufgetreten. Bitte versuche es später erneut."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Senden von"),
        "sending": MessageLookupByLibrary.simpleMessage("Sende"),
        "sent": MessageLookupByLibrary.simpleMessage("Gesendet"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Gesendet an"),
        "setPassword":
            MessageLookupByLibrary.simpleMessage("Passwort festlegen"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Passwort erfolgreich festgelegt"),
        "setWalletPassword":
            MessageLookupByLibrary.simpleMessage("Wallet-Passwort festlegen"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "switchToSeed":
            MessageLookupByLibrary.simpleMessage("Zum Seed wechseln"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Systemsprache"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Zum Verbergen tippen"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Zum Anzeigen tippen"),
        "to": MessageLookupByLibrary.simpleMessage("An"),
        "tokenMissing":
            MessageLookupByLibrary.simpleMessage("Wähle einen Token"),
        "tokenQuantityMissing":
            MessageLookupByLibrary.simpleMessage("Bitte Anzahl einfügen"),
        "tokensListCreatedBy": MessageLookupByLibrary.simpleMessage("Von "),
        "tokensListCreatedThe":
            MessageLookupByLibrary.simpleMessage("Erstellt von "),
        "tokensListHeader": MessageLookupByLibrary.simpleMessage("Token Liste"),
        "tokensListTotalSupply":
            MessageLookupByLibrary.simpleMessage("Gesamtanzahl : "),
        "tooManyFailedAttempts":
            MessageLookupByLibrary.simpleMessage("Zu viele Fehlversuche."),
        "transactionDetailAmount":
            MessageLookupByLibrary.simpleMessage("Betrag"),
        "transactionDetailBlock": MessageLookupByLibrary.simpleMessage("Block"),
        "transactionDetailCopyPaste": MessageLookupByLibrary.simpleMessage(
            "Auf Text doppelklicken um Zwischenablage zu kopieren"),
        "transactionDetailDate": MessageLookupByLibrary.simpleMessage("Datum"),
        "transactionDetailFee": MessageLookupByLibrary.simpleMessage("Gebühr"),
        "transactionDetailFrom":
            MessageLookupByLibrary.simpleMessage("Von Addresse"),
        "transactionDetailOpenfield":
            MessageLookupByLibrary.simpleMessage("Data (Openfield)"),
        "transactionDetailOperation":
            MessageLookupByLibrary.simpleMessage("Operation"),
        "transactionDetailReward":
            MessageLookupByLibrary.simpleMessage("Miner Vergütung"),
        "transactionDetailSignature":
            MessageLookupByLibrary.simpleMessage("Signatur"),
        "transactionDetailTo":
            MessageLookupByLibrary.simpleMessage("An Addresse"),
        "transactionDetailTxId":
            MessageLookupByLibrary.simpleMessage("Transaktion ID"),
        "transactionHeader":
            MessageLookupByLibrary.simpleMessage("Transaktion"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transaktionen"),
        "unlock": MessageLookupByLibrary.simpleMessage("Entsperrt"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Authentifizieren, um my Bismuth Wallet zu entsperren"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "PIN eingeben, um my Bismuth Wallet zu entsperren"),
        "warning": MessageLookupByLibrary.simpleMessage("WARNUNG"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Willkommen bei my Bismuth Wallet. Um fortzufahren, benötigst du ein Wallet. Erstelle bitte ein neues Wallet oder importiere ein bereits existierendes Wallet."),
        "xMinute": MessageLookupByLibrary.simpleMessage("Nach %1 Minute"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Nach %1 Minute"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Ja")
      };
}

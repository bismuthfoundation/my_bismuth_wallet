// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "ackBackedUp": MessageLookupByLibrary.simpleMessage(
            "Sei sicuro di aver fatto una copia della tua frase segreta o seed?"),
        "addAccount": MessageLookupByLibrary.simpleMessage("Aggiungi"),
        "addContact": MessageLookupByLibrary.simpleMessage("Aggiungi"),
        "addressCopied": MessageLookupByLibrary.simpleMessage("Copiato"),
        "addressHint":
            MessageLookupByLibrary.simpleMessage("Inserisci Indirizzo"),
        "addressMising":
            MessageLookupByLibrary.simpleMessage("Inserisci un indirizzo"),
        "addressShare": MessageLookupByLibrary.simpleMessage("Condividi"),
        "amountMissing":
            MessageLookupByLibrary.simpleMessage("Inserisci un importo"),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Metodo di Autenticazione"),
        "autoLockHeader":
            MessageLookupByLibrary.simpleMessage("Blocco Automatico"),
        "available": MessageLookupByLibrary.simpleMessage("available"),
        "backupConfirmButton":
            MessageLookupByLibrary.simpleMessage("L\'ho Conservata"),
        "backupSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Salva Frase Segreta"),
        "backupSeed": MessageLookupByLibrary.simpleMessage("Salva Seed"),
        "backupSeedConfirm": MessageLookupByLibrary.simpleMessage(
            "Sei sicuro di aver fatto un backup del tuo seed?"),
        "backupYourSeed": MessageLookupByLibrary.simpleMessage("Salva il seed"),
        "biometricsMethod": MessageLookupByLibrary.simpleMessage("Biometrica"),
        "cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
        "changeCurrency": MessageLookupByLibrary.simpleMessage("Cambia Valuta"),
        "close": MessageLookupByLibrary.simpleMessage("Chiudi"),
        "confirm": MessageLookupByLibrary.simpleMessage("Conferma"),
        "confirmPasswordHint":
            MessageLookupByLibrary.simpleMessage("Conferma la password"),
        "connectingHeader":
            MessageLookupByLibrary.simpleMessage("In connessione"),
        "contactAdded": MessageLookupByLibrary.simpleMessage(
            "%1 è stato aggiunto ai contatti!"),
        "contactExists":
            MessageLookupByLibrary.simpleMessage("Contatto Già Esistente"),
        "contactHeader": MessageLookupByLibrary.simpleMessage("Contatto"),
        "contactInvalid":
            MessageLookupByLibrary.simpleMessage("Nome Contatto Invalido"),
        "contactNameHint":
            MessageLookupByLibrary.simpleMessage("Inserisci un Nome @"),
        "contactNameMissing": MessageLookupByLibrary.simpleMessage(
            "Non ci sono contatti da esportare"),
        "contactRemoved": MessageLookupByLibrary.simpleMessage(
            "%1 è stato rimosso dai contatti!"),
        "contactsHeader": MessageLookupByLibrary.simpleMessage("Contatti"),
        "copied": MessageLookupByLibrary.simpleMessage("Copiato"),
        "copy": MessageLookupByLibrary.simpleMessage("Copia"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Copia Indirizzo"),
        "copySeed": MessageLookupByLibrary.simpleMessage("Copia Seed"),
        "createAPasswordHeader":
            MessageLookupByLibrary.simpleMessage("Crea una password."),
        "createPasswordFirstParagraph": MessageLookupByLibrary.simpleMessage(
            "Puoi creare una password per rendere il tuo portafoglio ancora più sicuro."),
        "createPasswordHint":
            MessageLookupByLibrary.simpleMessage("Crea una password"),
        "createPasswordSecondParagraph": MessageLookupByLibrary.simpleMessage(
            "La password è opzionale, e il tuo portafoglio sarà comunque protetto dal PIN o dal riconoscimento biometrico."),
        "createPasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Crea"),
        "currency": MessageLookupByLibrary.simpleMessage("Valuta"),
        "customUrlHeader": MessageLookupByLibrary.simpleMessage("Custom Urls"),
        "defaultAccountName":
            MessageLookupByLibrary.simpleMessage("Principale"),
        "defaultNewAccountName":
            MessageLookupByLibrary.simpleMessage("Account %1"),
        "diacritic": MessageLookupByLibrary.simpleMessage(
            "Accenti comuni e segni diacritici verranno sostituiti con un carattere equivalente"),
        "disablePasswordSheetHeader":
            MessageLookupByLibrary.simpleMessage("Disabilita"),
        "disablePasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "La password è stata disabilitata"),
        "disableWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Disabilita Password Portafoglio"),
        "encryptionFailedError": MessageLookupByLibrary.simpleMessage(
            "Errore nell’impostazione della password"),
        "enterAddress":
            MessageLookupByLibrary.simpleMessage("Inserisci Indirizzo"),
        "enterAmount":
            MessageLookupByLibrary.simpleMessage("Inserisci Importo"),
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
        "enterPasswordHint":
            MessageLookupByLibrary.simpleMessage("Inserisci la password"),
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
        "exampleCardFrom": MessageLookupByLibrary.simpleMessage("da qualcuno"),
        "exampleCardIntro": MessageLookupByLibrary.simpleMessage(
            "Benvenuto in my Bismuth Wallet. Una volta ricevuti dei BIS, le transazioni compariranno in questo modo"),
        "exampleCardLittle": MessageLookupByLibrary.simpleMessage("Un po\' di"),
        "exampleCardLot": MessageLookupByLibrary.simpleMessage("Un sacco di"),
        "exampleCardTo": MessageLookupByLibrary.simpleMessage("a qualcuno"),
        "exit": MessageLookupByLibrary.simpleMessage("Esci"),
        "fees": MessageLookupByLibrary.simpleMessage("Fees"),
        "fingerprintSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Conferma l\'impronta per salvare il seed."),
        "goBackButton": MessageLookupByLibrary.simpleMessage("Indietro"),
        "gotItButton": MessageLookupByLibrary.simpleMessage("Capito!"),
        "hideAccountHeader":
            MessageLookupByLibrary.simpleMessage("Nascondere l\'Account?"),
        "iUnderstandTheRisks":
            MessageLookupByLibrary.simpleMessage("Sono Consapevole dei Rischi"),
        "import": MessageLookupByLibrary.simpleMessage("Importa"),
        "importSecretPhrase":
            MessageLookupByLibrary.simpleMessage("Importa Frase Segreta"),
        "importSecretPhraseHint": MessageLookupByLibrary.simpleMessage(
            "Inserisci la tua frase segreta da 24 parole qui sotto. Ogni parola deve essere separata da uno spazio."),
        "importSeed": MessageLookupByLibrary.simpleMessage("Importa seed"),
        "importSeedHint": MessageLookupByLibrary.simpleMessage(
            "Inserisci il seed qui in basso."),
        "importSeedInstead":
            MessageLookupByLibrary.simpleMessage("Oppure Importa Seed"),
        "importWallet": MessageLookupByLibrary.simpleMessage("Importa"),
        "informations": MessageLookupByLibrary.simpleMessage("Informations"),
        "instantly": MessageLookupByLibrary.simpleMessage("Subito"),
        "insufficientBalance":
            MessageLookupByLibrary.simpleMessage("Saldo Insufficiente"),
        "insufficientTokenQuantity": MessageLookupByLibrary.simpleMessage(
            "Insufficient Quantity in your wallet"),
        "invalidAddress":
            MessageLookupByLibrary.simpleMessage("Indirizzo invalido"),
        "invalidPassword":
            MessageLookupByLibrary.simpleMessage("Password Invalida"),
        "language": MessageLookupByLibrary.simpleMessage("Lingua"),
        "liveSupportButton": MessageLookupByLibrary.simpleMessage("Supporto"),
        "lockAppSetting":
            MessageLookupByLibrary.simpleMessage("Autenticazione all\'Avvio"),
        "locked": MessageLookupByLibrary.simpleMessage("Bloccato"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutAction": MessageLookupByLibrary.simpleMessage(
            "Elimina seed e fai il logout"),
        "logoutAreYouSure": MessageLookupByLibrary.simpleMessage("Sei sicuro?"),
        "logoutDetail": MessageLookupByLibrary.simpleMessage(
            "Facendo il logout il tuo seed e tutti i dati relativi a my Bismuth Wallet verranno rimossi dal dispositivo. Se non hai salvato il tuo seed, non sarai più in grado di accedere ai tuoi fondi."),
        "logoutReassurance": MessageLookupByLibrary.simpleMessage(
            "Finché avrai un backup del seed non avrai nulla di cui preoccuparti."),
        "manage": MessageLookupByLibrary.simpleMessage("Gestisci"),
        "mempool": MessageLookupByLibrary.simpleMessage("Non confirmé"),
        "mnemonicInvalidWord":
            MessageLookupByLibrary.simpleMessage("%1 non è una parola valida"),
        "mnemonicSizeError": MessageLookupByLibrary.simpleMessage(
            "La frase segreta può contenere solo 24 parole"),
        "myTokens": MessageLookupByLibrary.simpleMessage("Tokens"),
        "myTokensListHeader":
            MessageLookupByLibrary.simpleMessage("My Token List"),
        "newAccountIntro": MessageLookupByLibrary.simpleMessage(
            "Questo è il tuo nuovo account. Una volta ricevuti NANO, le transazioni appariranno così:"),
        "newWallet": MessageLookupByLibrary.simpleMessage("Nuovo"),
        "nextButton": MessageLookupByLibrary.simpleMessage("Avanti"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noSkipButton": MessageLookupByLibrary.simpleMessage("No, Salta"),
        "noTokenOwner":
            MessageLookupByLibrary.simpleMessage("You don\'t have any token"),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "onStr": MessageLookupByLibrary.simpleMessage("On"),
        "openfield": MessageLookupByLibrary.simpleMessage("Data (Openfield)"),
        "operation": MessageLookupByLibrary.simpleMessage("Operation"),
        "optionalParameters":
            MessageLookupByLibrary.simpleMessage("Optional Parameters"),
        "passwordBlank": MessageLookupByLibrary.simpleMessage(
            "La password non può essere vuota"),
        "passwordNoLongerRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Non avrai più bisogno di una password per aprire my Bismuth Wallet."),
        "passwordWillBeRequiredToOpenParagraph":
            MessageLookupByLibrary.simpleMessage(
                "Questa password sarà richiesta per aprire my Bismuth Wallet."),
        "passwordsDontMatch": MessageLookupByLibrary.simpleMessage(
            "Le password non corrispondono"),
        "pasteBisUrl":
            MessageLookupByLibrary.simpleMessage("You can paste a BIS url"),
        "pasteBisUrlError": MessageLookupByLibrary.simpleMessage(
            "Your clipboard doesn\'t contain a BIS url"),
        "pasteBisUrlPrefix": MessageLookupByLibrary.simpleMessage(
            "(\'bis://\' or \'bis://pay)\'"),
        "pinConfirmError":
            MessageLookupByLibrary.simpleMessage("I pin non combaciano"),
        "pinConfirmTitle":
            MessageLookupByLibrary.simpleMessage("Conferma il pin"),
        "pinCreateTitle":
            MessageLookupByLibrary.simpleMessage("Crea un pin a 6 cifre"),
        "pinEnterTitle": MessageLookupByLibrary.simpleMessage("Inserisci pin"),
        "pinInvalid": MessageLookupByLibrary.simpleMessage("Pin errato"),
        "pinMethod": MessageLookupByLibrary.simpleMessage("PIN"),
        "pinSeedBackup": MessageLookupByLibrary.simpleMessage(
            "Inserisci il pin per vedere il seed."),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferenze"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Politica sulla Privacy"),
        "qrInvalidAddress": MessageLookupByLibrary.simpleMessage(
            "Il codice QR non contiene una destinazione valida"),
        "qrInvalidPermissions": MessageLookupByLibrary.simpleMessage(
            "Abilita l’accesso alla fotocamera per scansionare i codici QR"),
        "qrInvalidSeed": MessageLookupByLibrary.simpleMessage(
            "Il codice QR non contiene un seed o una chiave privata validi"),
        "qrMnemonicError": MessageLookupByLibrary.simpleMessage(
            "Il QR non contiene una frase segreta valida"),
        "qrUnknownError": MessageLookupByLibrary.simpleMessage(
            "Errore nella Lettura del codice QR"),
        "receive": MessageLookupByLibrary.simpleMessage("Ricevi"),
        "received": MessageLookupByLibrary.simpleMessage("Ricevuti"),
        "releaseNoteHeader":
            MessageLookupByLibrary.simpleMessage("What\'s new"),
        "removeAccountText": MessageLookupByLibrary.simpleMessage(
            "Sei sicuro di voler nascondere questo account? Potrai riaggiungerlo in futuro cliccando sul pulsante \"%1\"."),
        "removeContact":
            MessageLookupByLibrary.simpleMessage("Rimuovi Contatto"),
        "removeContactConfirmation": MessageLookupByLibrary.simpleMessage(
            "Sei sicuro di voler rimuovere %1?"),
        "requireAPasswordToOpenHeader": MessageLookupByLibrary.simpleMessage(
            "Richiedi una password per aprire my Bismuth Wallet ?"),
        "rootWarning": MessageLookupByLibrary.simpleMessage(
            "Sembra che il tuo dispositivo sia “rooted”, “jailbroken”, o abbia una modifica che ne compromette la sicurezza. Prima di procedere, è consigliato eseguire un ripristino del dispositivo al suo stato originale."),
        "scanInstructions": MessageLookupByLibrary.simpleMessage(
            "Scansiona un \ncodice QR Bismuth"),
        "scanQrCode": MessageLookupByLibrary.simpleMessage("Codice QR"),
        "searchField": MessageLookupByLibrary.simpleMessage("Search..."),
        "secretInfo": MessageLookupByLibrary.simpleMessage(
            "Nella prossima schermata, vedrai la tua frase segreta. È la password per accedere ai tuoi fondi. È fondamentale che tu ne faccia una copia e che non la condivida con nessuno."),
        "secretInfoHeader":
            MessageLookupByLibrary.simpleMessage("Sicurezza al primo posto!"),
        "secretPhrase": MessageLookupByLibrary.simpleMessage("Frase Segreta"),
        "secretPhraseCopied":
            MessageLookupByLibrary.simpleMessage("Frase Segreta Copiata"),
        "secretPhraseCopy":
            MessageLookupByLibrary.simpleMessage("Copia Frase Segreta"),
        "secretWarning": MessageLookupByLibrary.simpleMessage(
            "Se perdi il tuo device o disinstalli l\'applicazione, avrai bisogno della tua frase segreta o del seed per recuperare i tuoi fondi!"),
        "securityHeader": MessageLookupByLibrary.simpleMessage("Sicurezza"),
        "seed": MessageLookupByLibrary.simpleMessage("Seed"),
        "seedBackupInfo": MessageLookupByLibrary.simpleMessage(
            "Qui sotto c\'è il seed del tuo portafoglio. È fondamentale che tu faccia un backup del seed evitando di conservarlo in chiaro o con uno screenshot."),
        "seedCopied": MessageLookupByLibrary.simpleMessage(
            "Seed copiato negli appunti.\n Potrai incollarlo per 2 minuti."),
        "seedCopiedShort": MessageLookupByLibrary.simpleMessage("Seed Copiato"),
        "seedDescription": MessageLookupByLibrary.simpleMessage(
            "Un seed contiene le stesse informazioni di una frase segreta, ma può essere letto da una macchina. Finché ne avrai una copia, avrai accesso ai tuoi fondi. "),
        "seedInvalid": MessageLookupByLibrary.simpleMessage("Seed non valido"),
        "send": MessageLookupByLibrary.simpleMessage("Invia"),
        "sendATokenQuestion":
            MessageLookupByLibrary.simpleMessage("Send a token ?"),
        "sendAmountConfirm":
            MessageLookupByLibrary.simpleMessage("Inviare %1 Bismuth?"),
        "sendError": MessageLookupByLibrary.simpleMessage(
            "Si è verificato un errore. Riprova più tardi."),
        "sendFrom": MessageLookupByLibrary.simpleMessage("Invia Da"),
        "sending": MessageLookupByLibrary.simpleMessage("Inviando"),
        "sent": MessageLookupByLibrary.simpleMessage("Inviati"),
        "sentTo": MessageLookupByLibrary.simpleMessage("Inviato A"),
        "setPassword": MessageLookupByLibrary.simpleMessage("Imposta Password"),
        "setPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "La password è stata impostata correttamente"),
        "setWalletPassword": MessageLookupByLibrary.simpleMessage(
            "Imposta Password Portafoglio"),
        "settingsHeader": MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "switchToSeed": MessageLookupByLibrary.simpleMessage("Passa al Seed"),
        "systemDefault": MessageLookupByLibrary.simpleMessage("Predefinito"),
        "tapToHide":
            MessageLookupByLibrary.simpleMessage("Tocca per nascondere"),
        "tapToReveal":
            MessageLookupByLibrary.simpleMessage("Tocca per visualizzare"),
        "to": MessageLookupByLibrary.simpleMessage("A"),
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
            "Troppi tentativi di sblocco falliti."),
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
        "transactions": MessageLookupByLibrary.simpleMessage("Transazioni"),
        "unlock": MessageLookupByLibrary.simpleMessage("Sblocca"),
        "unlockBiometrics": MessageLookupByLibrary.simpleMessage(
            "Autenticati per Sbloccare my Bismuth Wallet"),
        "unlockPin": MessageLookupByLibrary.simpleMessage(
            "Inserisci il PIN per Sbloccare my Bismuth Wallet"),
        "warning": MessageLookupByLibrary.simpleMessage("ATTENZIONE"),
        "welcomeText": MessageLookupByLibrary.simpleMessage(
            "Benvenuto in my Bismuth Wallet. Per continuare, puoi creare un nuovo portafoglio o importarne uno esistente."),
        "xMinute": MessageLookupByLibrary.simpleMessage("Dopo %1 minuto"),
        "xMinutes": MessageLookupByLibrary.simpleMessage("Dopo %1 minuti"),
        "yes": MessageLookupByLibrary.simpleMessage("Si"),
        "yesButton": MessageLookupByLibrary.simpleMessage("Si")
      };
}

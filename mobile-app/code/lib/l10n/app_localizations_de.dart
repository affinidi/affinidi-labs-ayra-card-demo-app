// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get poweredBy => 'Powered by';

  @override
  String get messagingEngine => 'Affinidi-Nachrichten';

  @override
  String get appName => 'Treffpunkt';

  @override
  String tabsTitle(String tabName) {
    String _temp0 = intl.Intl.selectLogic(tabName, {
      'connections': 'Invitations',
      'contacts': 'Channels',
      'identities': 'Identities',
      'settings': 'Settings',
      'ayra': 'Ayra',
      'other': 'Invalid',
    });
    return '$_temp0';
  }

  @override
  String get publishOffer => 'Einladung veröffentlichen';

  @override
  String get publishGroupOffer => 'Gruppeneinladung veröffentlichen';

  @override
  String get meetingPlaceBannerText =>
      'Meeting Place ermöglicht es Ihnen, anonym und privat eine Einladung zu veröffentlichen, um sich mit Ihnen zu verbinden. Geben Sie eine Überschrift und eine Beschreibung sowie Details zur Gültigkeit an, um die Verfügbarkeit des Angebots zu begrenzen.';

  @override
  String get connectionOfferDetails => 'Details zur Einladung';

  @override
  String get createGroupChatOffer => 'Gruppenchat';

  @override
  String get groupOfferHelperText =>
      'Die Einladung stellt einen Gruppenchat dar, an dem mehrere Kontakte teilnehmen und chatten können. Sie haben weiterhin die Kontrolle darüber, wer dem Gruppenchat beitreten kann.';

  @override
  String get generateRandomPhraseHelperEnabled =>
      'Generieren einer zufälligen Phrase';

  @override
  String get generateRandomPhraseHelperDisabled =>
      'Die von Ihnen eingegebene benutzerdefinierte Phrase wird verwendet, um diese Einladung zur Verbindung eindeutig zu identifizieren. Es muss einzigartig im Meeting Place-Universum sein.';

  @override
  String get customPhrase => 'Benutzerdefinierte Phrase';

  @override
  String get enterCustomPhrase => 'Benutzerdefinierte Phrase eingeben';

  @override
  String get customPhraseHelperText =>
      'Geben Sie eine eindeutige benutzerdefinierte Phrase ein. Sie können so viele Wörter verwenden, wie Sie möchten, getrennt durch Leerzeichen.';

  @override
  String get chatGroupName => 'Name der Chat-Gruppe';

  @override
  String get headline => 'Schlagzeile';

  @override
  String get description => 'Beschreibung';

  @override
  String get validityVisibilitySettings =>
      'Gültigkeits- und Sichtbarkeitseinstellungen';

  @override
  String get searchableAtMeetingPlace => 'Durchsuchbar bei meetingplace.world';

  @override
  String get searchableHelperText =>
      'Wenn diese Option ausgewählt ist, können die Details, die Sie in diesem Angebot teilen, unter meetingplace.world';

  @override
  String get setExpiry => 'Ablauf festlegen';

  @override
  String get setExpiryHelperEnabled =>
      'Die Einladung läuft zum angegebenen Datum und zur angegebenen Uhrzeit ab';

  @override
  String get setExpiryHelperDisabled =>
      'Die Einladung bleibt gültig, bis sie gelöscht wird, und läuft nicht ab';

  @override
  String expiresAt(String date, String time) {
    return 'Läuft ab: $date um $time';
  }

  @override
  String get scanCustomMediatorQrCode =>
      'Scannen Sie den QR-Code des benutzerdefinierten Nachrichtenservers';

  @override
  String get chooseMediatorHelper =>
      'Wählen Sie aus, welcher Message-Server für Ihre Verbindungen verwendet werden soll. Sie können benutzerdefinierte Nachrichtenserver hinzufügen, indem Sie deren QR-Code scannen.';

  @override
  String get setMediatorName => 'Festlegen des Namens des Nachrichtenservers';

  @override
  String newConnectionOptionTitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Direct share QR Code',
      'scanQRCode': 'Direct scan a QR Code',
      'claimAnOffer': 'Accept Meeting Place Invitation',
      'publishAnOffer': 'Publish Meeting Place Invitation',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get setExpiryDateTime =>
      'Festlegen des Ablaufdatums und der Ablaufzeit';

  @override
  String get selectExpiryHelperText =>
      'Wählen Sie aus, wann dieses Angebot ablaufen soll';

  @override
  String get changeButton => 'Veränderung';

  @override
  String get limitNumberOfUses => 'Begrenzen Sie die Anzahl der Verwendungen';

  @override
  String get limitUsesHelperEnabled =>
      'Die Einladung kann nur so oft verwendet werden';

  @override
  String get limitUsesHelperDisabled =>
      'Die Einladung kann unbegrenzt oft verwendet werden';

  @override
  String canBeUsedTimes(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Can be used $amount times',
      one: 'Can be used only once',
    );
    return '$_temp0';
  }

  @override
  String newConnectionOptionSubtitle(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'shareQRCode': 'Gives you complete privacy and confidentiality',
      'scanQRCode': 'Scan a QR Code with your camera',
      'claimAnOffer': 'Connect with someone through Meeting Place',
      'publishAnOffer': 'Advertise your invitation to connect on Meeting Place',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get unableToDetectCamera => 'Eine Kamera kann nicht erkannt werden';

  @override
  String get newConnectionsOptionsHeader =>
      'Wählen Sie eine Option aus, um eine neue Verbindung zu erstellen';

  @override
  String get oobQrPresentInvitationMessage =>
      'Zeigen Sie diesen QR-Code mit jemandem, um eine Verbindung herzustellen';

  @override
  String get connectionsNowConnected => 'Sie sind nun verbunden mit';

  @override
  String get connectionsPanelOobFailedTitle => 'Fehler bei der Kanalerstellung';

  @override
  String get connectionsPanelOobFailedBody =>
      'Die Verbindung kann nicht hergestellt werden. Bitte versuchen Sie es erneut.';

  @override
  String connectionsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'offers': 'Offers',
      'claims': 'Claims',
      'complete': 'Complete',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noConnections => 'Keine Verbindungen in dieser Ansicht';

  @override
  String connectionDeleteHeading(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Delete invitations',
      one: 'Delete invitation',
    );
    return '$_temp0';
  }

  @override
  String get selectMaxUsagesHelperText =>
      'Wählen Sie aus, wie oft dieses Angebot genutzt werden kann';

  @override
  String get mediator => 'Message-Server';

  @override
  String get mediatorHelperText =>
      'Dies ist der Nachrichtenserver, der für die Kommunikation mit jedem Kontakt verwendet wird, der sich über dieses Angebot verbindet';

  @override
  String get errorLoadingMediator => 'Fehler beim Laden des Meldungsservers';

  @override
  String get publishToMeetingPlace => 'Auf Meeting Place veröffentlichen';

  @override
  String connectWithFirstName(String firstName) {
    return 'Verbinden Sie sich mit $firstName!';
  }

  @override
  String firstNameChatGroup(String firstName) {
    return ' Chatgruppe von$firstName';
  }

  @override
  String get passphraseDescription =>
      'Verbinden Sie sich mit mir über Meeting Place!';

  @override
  String get headlineRequired => 'Überschrift ist erforderlich';

  @override
  String get descriptionRequired => 'Beschreibung ist erforderlich';

  @override
  String get customPhraseRequired =>
      'Benutzerdefinierte Phrase ist erforderlich, wenn keine zufällige Phrase verwendet wird';

  @override
  String get expiryDateRequired =>
      'Das Ablaufdatum ist erforderlich, wenn der Ablauf aktiviert ist';

  @override
  String get expiryDateFuture => 'Das Ablaufdatum muss in der Zukunft liegen';

  @override
  String get maxUsagesGreaterThanZero =>
      'Die maximale Nutzung muss größer als 0 sein.';

  @override
  String failedToPublishOffer(String error) {
    return 'Einladung konnte nicht veröffentlicht werden: $error';
  }

  @override
  String get selectMediator => 'Message-Server auswählen';

  @override
  String connectionDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Are you sure you want to delete $amount selected connections?',
      one: 'Are you sure you want to delete one selected connection?',
    );
    return '$_temp0';
  }

  @override
  String get generalCancel => 'Abbrechen';

  @override
  String get generalDelete => 'Löschen';

  @override
  String get generalDone => 'Fertig';

  @override
  String get connectionsPanelSubtitle =>
      'Wischen und tippen Sie, um Ihre Einladungen zu verwalten und Kanäle zum Chatten mit Ihren Kontakten einzurichten';

  @override
  String get findPersonAiBusinessDescription =>
      'Um sich mit einer Person oder einem KI-Agenten auf Meeting Place zu verbinden, geben Sie die Verbindungsphrase ein, die sie mit Ihnen geteilt haben.';

  @override
  String get enterPassphrase => 'Passphrase eingeben';

  @override
  String get claimOfferTitle => 'Eine Einladung auf Meeting Place finden';

  @override
  String get generalSearch => 'Suchen';

  @override
  String get generalConnect => 'Verbinden';

  @override
  String vCardFieldName(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'firstName': 'First name',
      'lastName': 'Last name',
      'email': 'Email',
      'mobile': 'Mobile',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get offerDetailsHeader => 'Meine Einladungsinformationen';

  @override
  String get acceptOfferTitle => 'Details zur Einladungsanfrage';

  @override
  String get offerDetailsDescription =>
      'Verbinden Sie sich mit mir über Meeting Place!';

  @override
  String get errorOwnerCannotClaimOffer =>
      'Sie können diese Einladung nicht beanspruchen, da Sie der Eigentümer sind';

  @override
  String get aliasPickerTitle =>
      'Verbindung mit dieser ausgewählten Identität herstellen';

  @override
  String get aliasPickerDescription =>
      'Identitäten helfen Ihnen, Ihre persönlichen Daten privat und unter Ihrer Kontrolle zu halten. Sie können den von Ihnen konfigurierten Alias für die primäre Identität verwenden oder einen Ihrer zusätzlichen Identitätsaliase für diese Einladung auswählen.';

  @override
  String error(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(errorCode, {
      'connection_offer_owned_by_claiming_party':
          'You cannot accept this invitation because you are the inviter!',
      'connection_offer_already_claimed_by_claiming_party':
          'You cannot accept this invitation because you already requested to connect and have an outstanding claim in progress',
      'connection_offer_not_found_error':
          'The details you provided did not match any active invitations.',
      'discovery_register_offer_group_generic': 'Failed to publish invitation.',
      'missingDeviceToken': 'Unable to find device notification token',
      'offerOwnedByClaimingParty':
          'You cannot claim this invitation because you are the owner',
      'offerAlreadyClaimedByParty':
          'You cannot claim this offer because you already accepted the invitation and have an outstanding request in progress',
      'offerNotFound':
          'The details you provided did not match any active invitations.',
      'other': '$errorCode',
      'mediatorAlreadyExists':
          'Message server with the same DID already exists.',
      'mediator_get_did_error': 'No message server found at the provided URL',
      'unableToFindMediator': 'No message server found at the provided URL',
    });
    return '$_temp0';
  }

  @override
  String get offerCreated => 'Einladung erstellt';

  @override
  String offerExpiresAt(String formattedExpiry) {
    return 'Die Einladung endet um $formattedExpiry';
  }

  @override
  String get offerValidityNote =>
      'Die Einladung ist bis zu dem oben genannten Datum und der oben genannten Uhrzeit gültig, es sei denn, es wird eine maximale Anzahl von Zugriffen erreicht';

  @override
  String get offerUnlimitedUsages =>
      'Diese Einladung kann beliebig oft verwendet werden';

  @override
  String offerMaxUsages(int maxUsages) {
    String _temp0 = intl.Intl.pluralLogic(
      maxUsages,
      locale: localeName,
      other: 'This invitation can be used $maxUsages times',
      one: 'This invitation can be used 1 time',
    );
    return '$_temp0';
  }

  @override
  String get noExpirySetHelperText =>
      'Es wurde kein Ablaufdatum festgelegt, sodass diese Einladung zur Verbindung nicht abläuft';

  @override
  String get validityVisibilityDetails =>
      'Details zur Gültigkeit und Sichtbarkeit';

  @override
  String get personalInformationShared => 'Geteilte personenbezogene Daten';

  @override
  String get myAliasProfile => 'Mein Alias-Profil';

  @override
  String get didInformation => 'DID-Informationen';

  @override
  String didSha256(String didSha256) {
    return '$didSha256 (SHA256)';
  }

  @override
  String get offerUsesPrimaryIdentity =>
      'Diese Einladung verwendet Ihre primäre Identität';

  @override
  String offerUsesAliasIdentity(String alias) {
    return 'Diese Einladung verwendet den Identitätsalias mit dem Namen \"$alias\"';
  }

  @override
  String get aliasProfileDescription =>
      'Ihr Alias-Profil hilft Ihnen, Ihre Identität privat und unter Kontrolle zu halten.';

  @override
  String get generalOk => 'Okay';

  @override
  String get contactsPanelSubtitle =>
      'Tippen Sie auf einen Kontakt, um zu chatten, doppeltippen Sie, um Details anzuzeigen, tippen und halten Sie ihn gedrückt, um ihn zu löschen.';

  @override
  String contactsFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'any': 'Any',
      'person': 'Person',
      'service': 'AI Agent',
      'business': 'Business',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get noContactsYet => 'Keine Kontakte in dieser Ansicht';

  @override
  String get contactDeleteHeading => 'Kontakt löschen';

  @override
  String contactDeletePrompt(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Are you sure you want to delete $amount selected channels?',
      one: 'Are you sure you want to delete this channel?',
      zero: 'Are you sure you want to delete this channel?',
    );
    return '$_temp0';
  }

  @override
  String connectedVia(String mediatorName) {
    return 'Verbunden über $mediatorName';
  }

  @override
  String contactAdded(String dateAdded) {
    return 'Hinzugefügte $dateAdded';
  }

  @override
  String get filter => 'Filter...';

  @override
  String get noContactsMatchFilter =>
      'Es gibt keine Kontakte, die mit Ihrem Filter übereinstimmen';

  @override
  String connectionPhrase(String phrase) {
    return 'Phrase: $phrase';
  }

  @override
  String usesIdentityViaMediator(String identity, String mediator) {
    return 'Verwendet Ihre $identity Identität über $mediator';
  }

  @override
  String get timeAgoJustNow => 'Gerade';

  @override
  String timeAgoMinute(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoMinuteWorded => 'Vor einer Minute';

  @override
  String timeAgoHourNumeric(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoHourWorded => 'Vor einer Stunde';

  @override
  String timeAgoDay(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'Gestern';

  @override
  String timeAgoWeek(num weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoLastWeek => 'Letzte Woche';

  @override
  String timeAgoSecond(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String createdValidUntil(String createdTimeAgo, String validUntilDate) {
    return 'Angelegt $createdTimeAgo, gültig bis $validUntilDate';
  }

  @override
  String createdValidWithoutExpiration(String createdTimeAgo) {
    return 'Erstellt ${createdTimeAgo}ohne Ablaufdatum';
  }

  @override
  String get displayName => 'Anzeigename';

  @override
  String get generalName => 'Name';

  @override
  String get displayNameHelperText =>
      'Sie können den Anzeigenamen für diesen Kontakt ändern. Der anderen Partei wird dieser Name nicht angezeigt.';

  @override
  String get generalEmail => 'E-Mail';

  @override
  String get generalMobile => 'Mobil';

  @override
  String get generalDid => 'TAT';

  @override
  String get generalDidSha256 => 'DIS (SHA256)';

  @override
  String get connectionEstablished => 'Kanal eingerichtet';

  @override
  String get generalMediator => 'Message-Server';

  @override
  String get connectionApproach => 'Ansatz zur Kanaleinrichtung';

  @override
  String get theirDetails => 'Ihre Details';

  @override
  String get mySharedIdentityDetails =>
      'Details zu meiner gemeinsamen Identität';

  @override
  String get connectionDetails => 'Details zur Kanalverbindung';

  @override
  String get myIdentity => 'Meine Identität';

  @override
  String get identitiesPanelSubtitle =>
      'Wischen Sie nach links und rechts, um Ihre Identitätsliste zu überprüfen und hinzuzufügen, ziehen Sie sie zum Löschen nach unten ';

  @override
  String identitiesFilterLabel(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'All',
      'primary': 'Primary',
      'aliases': 'Aliases',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get identityDeleteHeading => 'Identität löschen';

  @override
  String identityDeletePrompt(Object identity) {
    return 'Sind Sie sicher, dass Sie die Identität \"$identity\" löschen möchten?\n\nSie können eine Identität nicht wiederherstellen!';
  }

  @override
  String get displayNamePrimary => 'Primäre Identität';

  @override
  String get displayNameAddNew => 'Neue Identität hinzufügen';

  @override
  String get displayNameAlias => 'Identitäts-Alias';

  @override
  String get subtitlePrimary => 'Ihre primäre Identität';

  @override
  String get subtitleAddNew => 'Erstellen eines neuen Alias';

  @override
  String get subtitleAlias => 'Alias-Identität';

  @override
  String get notShared => 'Nicht geteilt';

  @override
  String get unknownUser => 'Unbekannter Benutzer';

  @override
  String get addNewIdentityAlias => 'Hinzufügen eines neuen Identitätsalias';

  @override
  String get identityAliasesDescription =>
      'Übernehmen Sie die Kontrolle über Ihre Privatsphäre, indem Sie Identitätsaliase erstellen, um sich gegenüber Kontakten, mit denen Sie sich verbinden, zu repräsentieren';

  @override
  String get generalReject => 'Ablehnen';

  @override
  String get generalApprove => 'Billigen';

  @override
  String get zalgoTextDetectedError =>
      'Ungewöhnliche Zeichen erkannt. Bitte entfernen Sie sie und versuchen Sie es erneut.';

  @override
  String get chatTooLong => 'Die Chat-Nachricht ist zu lang';

  @override
  String get splashScreenTitle => 'Treffpunkt';

  @override
  String get toProtectData =>
      'Um Ihre Daten zu schützen, erfordert diese Anwendung eine sichere Authentifizierung, um fortzufahren.';

  @override
  String get authInstructionAndroid =>
      'Gehen Sie zu Einstellungen > Sicherheit > Bildschirmsperre und aktivieren Sie eine PIN, ein Muster oder einen Fingerabdruck.';

  @override
  String get authInstructionIos =>
      'Gehe zu \"Einstellungen\" > \"Face ID & Code\" (oder \"Touch ID & Code\") und richte Face ID, Touch ID oder einen Geräte-Code ein.';

  @override
  String get authInstructionMacos =>
      'Gehen Sie zu den Systemeinstellungen > Touch ID & Passwort (oder Anmeldepasswort) und richten Sie Touch ID oder ein sicheres Passwort ein.';

  @override
  String get authUnlockReason =>
      'Bitte entsperren Sie Ihr Gerät, um fortzufahren';

  @override
  String chatTypeMessagePrompt(String name) {
    return 'Nachricht an $name';
  }

  @override
  String get chatAddMessageToMediaPrompt => 'Eine Nachricht hinzufügen';

  @override
  String get chatTypeMessagePromptGroup => 'Nachricht an den Kanal';

  @override
  String get updatePrimaryIdentity => 'Aktualisieren der primären Identität';

  @override
  String get newIdentityAlias => 'Neuer Identitätsalias';

  @override
  String editIdentityTitle(String identityName) {
    return 'Identität bearbeiten: $identityName';
  }

  @override
  String get customiseIdentityCard => 'Personalausweis anpassen';

  @override
  String get nameTooLong => 'Der Name ist zu lang';

  @override
  String get descriptionTooLong => 'Die Beschreibung ist zu lang';

  @override
  String get invalidEmail => 'Die E-Mail-Adresse ist ungültig';

  @override
  String get emailTooLong => 'Die E-Mail-Adresse ist zu lang';

  @override
  String get invalidMobileNumber => 'Die Handynummer ist ungültig';

  @override
  String get mobileTooLong => 'Die Handynummer ist zu lang';

  @override
  String get aliasTooLong => 'Der Alias ist zu lang';

  @override
  String get thisFieldIsRequired => 'Dieses Feld ist ein Pflichtfeld';

  @override
  String get identityAliasPersonalDetails =>
      'Identitätsalias persönliche Daten';

  @override
  String get profilePictureChangePrompt =>
      'Tippen Sie hier, um Ihr Profilbild zu ändern';

  @override
  String get firstName => 'Vorname';

  @override
  String get enterFirstName => 'Geben Sie den Vornamen ein';

  @override
  String get lastName => 'Nachname';

  @override
  String get enterLastName => 'Nachname eingeben';

  @override
  String get email => 'E-Mail';

  @override
  String get enterEmail => 'E-Mail-Adresse eingeben';

  @override
  String get mobile => 'Mobil';

  @override
  String get enterMobile => 'Hier kommt das Handy ins Spiel';

  @override
  String get anonymous => 'Anonym';

  @override
  String get aliasLabel => 'Alias-Beschriftung';

  @override
  String get enterAliasLabel => 'Alias-Label eingeben';

  @override
  String get aliasLabelHelperText =>
      'Die Alias-Beschriftung ist die Art und Weise, wie Sie beim Herstellen einer Verbindung auf diesen Alias verweisen. Verwenden Sie einen aussagekräftigen Namen, um die Identifizierung zu erleichtern.';

  @override
  String get setupPrimaryIdentityTitle =>
      'Lassen Sie uns Ihre primäre Identität einrichten!';

  @override
  String get setupPrimaryIdentityDescription =>
      'Ihre primäre Identität wird standardmäßig verwendet, wenn Sie sich mit anderen verbinden.';

  @override
  String get primaryIdentityInformation =>
      'Ihre primären Identitätsinformationen';

  @override
  String get primaryIdentityComplete =>
      'Meine primäre Identität ist vollständig';

  @override
  String get keepMeAnonymous => 'Anonym bleiben';

  @override
  String typingMessage(String names, int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: '$names are typing',
      one: '$names is typing',
    );
    return '$_temp0';
  }

  @override
  String awaitingMembersToJoin(String names, int namesCount, int othersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      othersCount,
      locale: localeName,
      other: '$othersCount others',
      one: '1 other',
    );
    String _temp1 = intl.Intl.pluralLogic(
      namesCount,
      locale: localeName,
      other: 'Awaiting $names and $_temp0 to join',
      one: 'Awaiting $names to join',
    );
    return '$_temp1';
  }

  @override
  String get unknownType => 'Unbekannter Typ';

  @override
  String get loadImageFailed => 'Bild konnte nicht geladen werden';

  @override
  String get chatRequestPermissionToJoinGroupFailed =>
      'Fehler beim Beitritt zur Gruppe';

  @override
  String get genWordConciergeMessage => 'Nachricht des Concierges';

  @override
  String chatRequestPermissionToJoinGroup(String memberName) {
    return '$memberName möchte der Gruppe beitreten';
  }

  @override
  String get genWordNo => 'Nein';

  @override
  String get genWordLater => 'Später';

  @override
  String get genWordYes => 'Ja';

  @override
  String get chatRequestPermissionToUpdateProfileGroup =>
      'Die Profildetails, die für diese Gruppe freigegeben wurden, haben sich geändert. Möchten Sie alle Mitglieder auf dem Laufenden halten?';

  @override
  String get chatRequestPermissionToUpdateProfile =>
      'Die Profildetails, die für diesen Kontakt freigegeben wurden, haben sich geändert. Möchten Sie ihnen ein Update senden?';

  @override
  String chatStartOfConversationInitiatedByMe(String date, String time) {
    return 'Sie haben diesen Kanal am $date bei ${time}eingerichtet. ';
  }

  @override
  String get messageCopiedClipboard =>
      'Nachricht in die Zwischenablage kopiert';

  @override
  String chatItemStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'queued': 'Queued',
      'delivered': 'Delivered',
      'sending': 'Sending',
      'sent': 'Sent',
      'error': 'Error',
      'groupDeleted': 'Group deleted',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get qrScannerTitle => 'QR-Code scannen';

  @override
  String get qrScannerInstructions =>
      'Positionieren Sie den QR-Code innerhalb des Rahmens';

  @override
  String qrScannerStatus(String status) {
    return 'Status des Scanners: $status';
  }

  @override
  String get useCamera => 'Kamera verwenden';

  @override
  String get chooseFromGallery => 'Wählen Sie aus der Galerie';

  @override
  String get qrScannerCameraNotAvailable => 'Kamera nicht verfügbar';

  @override
  String get qrScannerCameraPermissionHelp =>
      'Bitte überprüfen Sie die Kameraberechtigungen und versuchen Sie es erneut';

  @override
  String get qrScannerConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String qrScannerConnectionFailedMessage(String error) {
    return 'Verbindung konnte nicht hergestellt werden: $error';
  }

  @override
  String get qrScannerTryAgain => 'Wiederholen';

  @override
  String get qrScannerTimeoutError =>
      'Zeitüberschreitung bei der Annahme des OOB-Flusses nach 30 Sekunden';

  @override
  String get customMediators => 'Benutzerdefinierte Nachrichtenserver';

  @override
  String get addCustomMediator =>
      'Hinzufügen eines benutzerdefinierten Nachrichtenservers';

  @override
  String get manageCustomMediators =>
      'Verwalten von benutzerdefinierten Nachrichtenservern';

  @override
  String get configureCustomMediatorEndpoint =>
      'Konfigurieren eines eigenen Nachrichtenserver-Endpunkts';

  @override
  String get noCustomMediatorsConfigured =>
      'Es sind noch keine benutzerdefinierten Nachrichtenserver konfiguriert';

  @override
  String customMediatorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom message servers configured',
      one: '1 custom message server configured',
    );
    return '$_temp0';
  }

  @override
  String addedMediatorSuccess(String name) {
    return 'Message-Server \"$name\" hinzugefügt';
  }

  @override
  String failedToAddMediator(String error) {
    return 'Fehler beim Hinzufügen des Nachrichtenservers: $error';
  }

  @override
  String get mediatorName => 'Name des Message-Servers';

  @override
  String get mediatorDid => 'DID des Nachrichtenservers';

  @override
  String get myCustomMediator => 'Mein benutzerdefinierter Nachrichtenserver';

  @override
  String get pleaseEnterName => 'Bitte geben Sie einen Namen ein';

  @override
  String get pleaseEnterDid => 'Bitte geben Sie eine DID ein';

  @override
  String get didMustStartWith => 'DID muss mit \"did:\" beginnen.';

  @override
  String get deleteCustomMediator =>
      'Benutzerdefinierten Message-Server löschen';

  @override
  String deleteCustomMediatorConfirm(String name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String deletedMediatorSuccess(String name) {
    return 'Gelöschter Message-Server \"$name\"';
  }

  @override
  String renamedMediatorSuccess(String name) {
    return 'Umbenennung des Message-Servers in \"$name\"';
  }

  @override
  String failedToDeleteMediator(String error) {
    return 'Fehler beim Löschen des Nachrichtenservers: $error';
  }

  @override
  String failedToRenameMediator(String error) {
    return 'Fehler beim Umbenennen des Nachrichtenservers: $error';
  }

  @override
  String get generalRetry => 'Wiederholen';

  @override
  String get generalClose => 'Schließen';

  @override
  String get generalAdd => 'Hinzufügen';

  @override
  String get noIdentityDetected =>
      'Keine Identität erkannt, bitte erstellen Sie eine, um fortzufahren.';

  @override
  String get connectWithPersonAiServiceBusiness =>
      'Verbinden Sie sich mit einer Person oder einem KI-Agenten';

  @override
  String get chatScreenTapForMemberDetails =>
      'Tippen Sie hier, um die Details der Mitglieder anzuzeigen.';

  @override
  String get debugPanelTitle => 'Bereich \"Debuggen\"';

  @override
  String get debugPanelSubtitle =>
      'Anzeigen von Anwendungsprotokollen und Debuginformationen';

  @override
  String get debugPanelNoLogs => 'Keine Protokolle verfügbar';

  @override
  String get debugPanelLogsAppearMessage =>
      'Hier werden Protokolle angezeigt, wenn Sie die App verwenden';

  @override
  String get debugPanelClearLogs => 'Protokolle löschen';

  @override
  String get debugPanelCopyLogs =>
      'Kopieren von Protokollen in die Zwischenablage';

  @override
  String get debugPanelAddTestLog => 'Hinzufügen eines Testprotokolls';

  @override
  String get debugPanelLogsCopied =>
      'Protokolle, die in die Zwischenablage kopiert werden';

  @override
  String get serverSettings => 'Server-Einstellungen';

  @override
  String get serverSettingsHelperText =>
      'Wählen Sie den Standardserver für die Messaging-Kommunikation aus';

  @override
  String get debugSettingsTitle => 'Debug-Einstellungen';

  @override
  String get debugModeLabel => 'Debug-Modus';

  @override
  String debugModeHelperText(int tapCount) {
    return 'Der Debug-Modus ist aktiviert. Tippen Sie $tapCount Mal auf Versionsinformationen, um umzuschalten.';
  }

  @override
  String get settingsScreenSubtitle =>
      'Konfigurieren Sie Ihre App-Einstellungen und -Einstellungen';

  @override
  String get versionInfoHeader => 'Version des Treffpunkts';

  @override
  String versionInfoVersion(String version) {
    return 'Version $version';
  }

  @override
  String versionInfoBuild(String buildNumber) {
    return 'Baujahr: $buildNumber';
  }

  @override
  String get easterEggEnabled =>
      '🎉 Easter Egg freigeschaltet! Debug-Modus aktiviert';

  @override
  String get debugModeDisabled => 'Debug-Modus deaktiviert';

  @override
  String get generalCamera => 'Kamera';

  @override
  String get generalPhoto => 'Foto';

  @override
  String get generalBalloons => 'Ballone';

  @override
  String get generalConfetti => 'Konfetti';

  @override
  String get chatItemStatusError => 'Fehler';

  @override
  String get formValidationHeadlineRequired => 'Überschrift ist erforderlich';

  @override
  String get formValidationDescriptionRequired =>
      'Beschreibung ist erforderlich';

  @override
  String get formValidationCustomPhraseRequired =>
      'Benutzerdefinierte Phrase ist erforderlich, wenn keine zufällige Phrase verwendet wird';

  @override
  String get formValidationExpiryDateRequired =>
      'Das Ablaufdatum ist erforderlich, wenn der Ablauf aktiviert ist';

  @override
  String get formValidationExpiryDateFuture =>
      'Das Ablaufdatum muss in der Zukunft liegen';

  @override
  String get formValidationMaxUsagesGreaterThanZero =>
      'Die maximale Nutzung muss größer als 0 sein.';

  @override
  String get genericPublishError => 'Fehler beim Veröffentlichen des Angebots';

  @override
  String get groupDetails => 'Details zum Gruppenkanal';

  @override
  String groupMessageInfo(String memberName, String date, String time) {
    return '$memberName auf $date bei $time';
  }

  @override
  String contactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Pending Approval',
      'pendingInauguration': 'Establishing Connection',
      'approved': 'Active Contact',
      'rejected': 'Rejected',
      'error': 'Error',
      'deleted': 'Deleted',
      'active': 'Active Contact',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String groupContactStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pendingApproval': 'Pending Approval',
      'pendingInauguration': 'Establishing Channel',
      'approved': 'Active Group Channel',
      'rejected': 'Rejected',
      'error': 'Error',
      'deleted': 'Deleted',
      'active': 'Active Group Channel',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String contactOrigin(String origin) {
    String _temp0 = intl.Intl.selectLogic(origin, {
      'directInteractive': 'Direct Interactive',
      'individualOfferPublished': 'Meeting Place Invitation Offered',
      'individualOfferRequested': 'Meeting Place Invitation Accepted',
      'groupOfferPublished': 'Meeting Place Group invitation Offered',
      'groupOfferRequested': 'Meeting Place Group Invitation Accepted',
      'unknown': 'Unknown',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get groupMembers => 'Gruppenmitglieder';

  @override
  String get showExited => 'Beendet anzeigen';

  @override
  String get groupMemberExited => 'Aus der Gruppe verlassen';

  @override
  String get groupNoMembersToChat =>
      'Sie sind derzeit das einzige Mitglied dieser Gruppe. Sie können mit dem Chatten beginnen, wenn ein anderes Mitglied beitritt.';

  @override
  String get generalJoined => 'Angegliedert';

  @override
  String get you => 'Du';

  @override
  String get groupAdmin => 'Gruppen-Admin';

  @override
  String get onboardingPage1Title => 'Herzlich Willkommen bei\nTreffpunkt';

  @override
  String get onboardingPage1Desc => 'Powered by\nAffinidi';

  @override
  String get onboardingPage2Title => 'Privat & Sicher';

  @override
  String get onboardingPage2Desc =>
      'Verbinden Sie sich sicher und privat mit anderen durch Ende-zu-Ende-Verschlüsselung';

  @override
  String get onboardingPage3Title =>
      'Übernehmen Sie die Kontrolle über Ihre Identität';

  @override
  String get onboardingPage3Desc =>
      'Schützen Sie Ihre Privatsphäre mit Aliasnamen. Weisen Sie Ihre Identität mit verifizierten Anmeldeinformationen nach';

  @override
  String get onboardingPage4Title => 'Bereit zu beginnen';

  @override
  String get onboardingPage4Desc =>
      'Richten Sie Ihre Identität ein\nund legen Sie los!';

  @override
  String get setUpMyIdentity => 'Meine Identität einrichten';

  @override
  String get revealConnectionCode => 'Passphrase für Einladung anzeigen';

  @override
  String versionInfoAppName(String appName) {
    return 'Meeting Place \"$appName\"';
  }

  @override
  String get platformNotSupported =>
      'Dieses Plugin wird auf Ihrer aktuellen Plattform nicht unterstützt';

  @override
  String get generalOfferInformation => 'Informationen zur Einladung';

  @override
  String get generalOfferLink => 'Einladungs-Link';

  @override
  String get generalMnemonic => 'Mnemonisch';

  @override
  String get generalConnectionType => 'Verbindungsart';

  @override
  String get generalExternalRef => 'Externe Referenz';

  @override
  String get generalGroupDid => 'Gruppe DID';

  @override
  String get generalGroupId => 'Gruppen-ID';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String connectionStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'published': 'Created',
      'finalised': 'Completed',
      'accepted': 'Waiting',
      'channelInaugurated': 'Active',
      'deleted': 'Deleted',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get publishing => 'Veröffentlichen';

  @override
  String get loading => 'Laden';

  @override
  String get deleting => 'Löschen';

  @override
  String get showQrScannerForOffers => 'QR-Scanner für Einladungen anzeigen';

  @override
  String get meetingPlaceControlPlane => 'Steuerungsebene für Treffpunkte';

  @override
  String get searching => 'Suche';

  @override
  String get connecting => 'Verbindend';

  @override
  String get approving => 'Beifällig';

  @override
  String get rejecting => 'Zurückweisend';

  @override
  String get sending => 'Entsendung';

  @override
  String get connectionRequestRejected =>
      'Die Verbindungsanforderung wurde abgelehnt';

  @override
  String get connectionRequestInProgress =>
      'Die Annahme der Einladung ist in Bearbeitung. Es kann einige Augenblicke dauern, bis die andere Partei antwortet und den Kanal fertigstellt.';

  @override
  String requestToConnect(Object firstName) {
    return 'Die Annahme der Einladung wurde ${firstName}gesendet. Es kann einige Augenblicke dauern, bis sie auf Ihre Anfrage antworten.';
  }

  @override
  String contactsDeleted(int amount) {
    String _temp0 = intl.Intl.pluralLogic(
      amount,
      locale: localeName,
      other: 'Channels deleted',
      one: 'Channel deleted',
    );
    return '$_temp0';
  }

  @override
  String joiningGroup(String memberName) {
    return '$memberName ist der Gruppe beigetreten';
  }

  @override
  String leavingGroup(String memberName) {
    return '$memberName hat die Gruppe verlassen';
  }

  @override
  String get concierge => 'Hausmeister';

  @override
  String get groupDeleted => 'Diese Gruppe wurde gelöscht';
}

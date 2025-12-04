// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get poweredBy => 'Funciona con';

  @override
  String get messagingEngine => 'Mensajería de Affinidi';

  @override
  String get appName => 'Lugar de encuentro';

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
  String get publishOffer => 'Publicar invitación';

  @override
  String get publishGroupOffer => 'Publicar invitación de grupo';

  @override
  String get meetingPlaceBannerText =>
      'Meeting Place le permite publicar de forma anónima y privada una invitación para conectarse con usted. Proporcione un título y una descripción, así como detalles de validez para limitar el tiempo que la oferta está disponible.';

  @override
  String get connectionOfferDetails => 'Detalles de la invitación';

  @override
  String get createGroupChatOffer => 'Chat grupal';

  @override
  String get groupOfferHelperText =>
      'La invitación representará un chat grupal para que varios contactos se unan y chateen. Todavía tienes control sobre quién puede unirse al chat grupal.';

  @override
  String get generateRandomPhraseHelperEnabled => 'Generar una frase aleatoria';

  @override
  String get generateRandomPhraseHelperDisabled =>
      'La frase personalizada que ingrese se utilizará para identificar de manera única esta invitación a conectarse. Debe ser único en el universo de Meeting Place.';

  @override
  String get customPhrase => 'Frase personalizada';

  @override
  String get enterCustomPhrase => 'Introducir frase personalizada';

  @override
  String get customPhraseHelperText =>
      'Introduzca una frase personalizada única. Puedes usar tantas palabras como quieras, separadas por espacios.';

  @override
  String get chatGroupName => 'Nombre del grupo de chat';

  @override
  String get headline => 'Titular';

  @override
  String get description => 'Descripción';

  @override
  String get validityVisibilitySettings =>
      'Configuración de validez y visibilidad';

  @override
  String get searchableAtMeetingPlace =>
      'Se puede buscar en meetingplace.world';

  @override
  String get searchableHelperText =>
      'Cuando se selecciona, los detalles que comparta en esta oferta se podrán buscar públicamente en meetingplace.world';

  @override
  String get setExpiry => 'Establecer caducidad';

  @override
  String get setExpiryHelperEnabled =>
      'La invitación caducará en la fecha y hora especificadas';

  @override
  String get setExpiryHelperDisabled =>
      'La invitación seguirá siendo válida hasta que se elimine y no caducará';

  @override
  String expiresAt(String date, String time) {
    return 'Expira: $date a las $time';
  }

  @override
  String get scanCustomMediatorQrCode =>
      'Escanear el código QR del servidor de mensajes personalizado';

  @override
  String get chooseMediatorHelper =>
      'Elija qué servidor de mensajes usar para sus conexiones. Puede agregar servidores de mensajes personalizados escaneando su código QR.';

  @override
  String get setMediatorName => 'Establecer el nombre del servidor de mensajes';

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
  String get setExpiryDateTime => 'Establecer fecha y hora de caducidad';

  @override
  String get selectExpiryHelperText =>
      'Selecciona cuándo debe caducar esta oferta';

  @override
  String get changeButton => 'Cambio';

  @override
  String get limitNumberOfUses => 'Limitar el número de usos';

  @override
  String get limitUsesHelperEnabled =>
      'La invitación solo se puede usar tantas veces';

  @override
  String get limitUsesHelperDisabled =>
      'La invitación se puede utilizar un número ilimitado de veces';

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
  String get unableToDetectCamera => 'No se puede detectar una cámara';

  @override
  String get newConnectionsOptionsHeader =>
      'Seleccione una opción para crear una nueva conexión';

  @override
  String get oobQrPresentInvitationMessage =>
      'Muestre este código QR con alguien para establecer una conexión';

  @override
  String get connectionsNowConnected => 'Ahora está conectado con';

  @override
  String get connectionsPanelOobFailedTitle => 'Error en la creación del canal';

  @override
  String get connectionsPanelOobFailedBody =>
      'No se puede establecer la conexión. Por favor, inténtalo de nuevo.';

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
  String get noConnections => 'No hay conexiones en esta vista';

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
      'Seleccione cuántas veces se puede usar esta oferta';

  @override
  String get mediator => 'Servidor de mensajes';

  @override
  String get mediatorHelperText =>
      'Este es el servidor de mensajes que se utilizará para la comunicación con cualquier contacto que se conecte a través de esta oferta';

  @override
  String get errorLoadingMediator => 'Error al cargar el servidor de mensajes';

  @override
  String get publishToMeetingPlace => 'Publicar en el lugar de reunión';

  @override
  String connectWithFirstName(String firstName) {
    return '¡Conéctate con $firstName!';
  }

  @override
  String firstNameChatGroup(String firstName) {
    return '${firstName}grupo de chat';
  }

  @override
  String get passphraseDescription =>
      '¡Conéctate conmigo usando Meeting Place!';

  @override
  String get headlineRequired => 'Se requiere título';

  @override
  String get descriptionRequired => 'Se requiere descripción';

  @override
  String get customPhraseRequired =>
      'Se requiere una frase personalizada cuando no se usa una frase aleatoria';

  @override
  String get expiryDateRequired =>
      'La fecha de caducidad es necesaria cuando la caducidad está habilitada';

  @override
  String get expiryDateFuture => 'La fecha de caducidad debe ser futura';

  @override
  String get maxUsagesGreaterThanZero =>
      'Los usos máximos deben ser mayores que 0';

  @override
  String failedToPublishOffer(String error) {
    return 'No se pudo publicar la invitación: $error';
  }

  @override
  String get selectMediator => 'Seleccione Servidor de mensajes';

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
  String get generalCancel => 'Cancelar';

  @override
  String get generalDelete => 'BORRAR';

  @override
  String get generalDone => 'Hecho';

  @override
  String get connectionsPanelSubtitle =>
      'Desliza y toca para administrar tus invitaciones.';

  @override
  String get findPersonAiBusinessDescription =>
      'Para conectarse con una persona o un agente de IA en Meeting Place, ingrese la frase de conexión que ha compartido con usted.';

  @override
  String get enterPassphrase => 'Introducir frase de contraseña';

  @override
  String get claimOfferTitle => 'Encuentra una invitación en Meeting Place';

  @override
  String get generalSearch => 'Buscar';

  @override
  String get generalConnect => 'Conectar';

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
  String get offerDetailsHeader => 'Información de mi invitación';

  @override
  String get acceptOfferTitle => 'Detalles de la solicitud de invitación';

  @override
  String get offerDetailsDescription =>
      '¡Conéctate conmigo usando Meeting Place!';

  @override
  String get errorOwnerCannotClaimOffer =>
      'No puedes reclamar esta invitación porque eres el propietario';

  @override
  String get aliasPickerTitle => 'Conexión con esta identidad seleccionada';

  @override
  String get aliasPickerDescription =>
      'Las identidades lo ayudan a mantener su información personal privada y bajo su control. Puede optar por utilizar el alias de identidad principal que ha configurado o seleccionar uno de sus alias de identidad adicionales para esta invitación.';

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
  String get offerCreated => 'Invitación creada';

  @override
  String offerExpiresAt(String formattedExpiry) {
    return 'La invitación vence a las $formattedExpiry';
  }

  @override
  String get offerValidityNote =>
      'La invitación es válida hasta la fecha y hora anteriores, a menos que se alcance un número máximo de accesos';

  @override
  String get offerUnlimitedUsages =>
      'Esta invitación se puede utilizar cualquier número de veces';

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
      'No se ha establecido una fecha de caducidad, por lo que esta invitación a conectarse no caduca';

  @override
  String get validityVisibilityDetails => 'Detalles de validez y visibilidad';

  @override
  String get personalInformationShared => 'Información personal compartida';

  @override
  String get myAliasProfile => 'Mi perfil de alias';

  @override
  String get didInformation => 'Información DID';

  @override
  String didSha256(String didSha256) {
    return '$didSha256 (SHA256)';
  }

  @override
  String get offerUsesPrimaryIdentity =>
      'Esta invitación utiliza tu identidad principal';

  @override
  String offerUsesAliasIdentity(String alias) {
    return 'Esta invitación utiliza el alias de identidad llamado \"$alias\"';
  }

  @override
  String get aliasProfileDescription =>
      'Tu perfil de alias te ayuda a mantener tu identidad privada y bajo tu control.';

  @override
  String get generalOk => 'DE ACUERDO';

  @override
  String get contactsPanelSubtitle =>
      'Toca un contacto para chatear, toca dos veces para ver los detalles, toca y mantén presionado para eliminar.';

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
  String get noContactsYet => 'No hay contactos en esta vista';

  @override
  String get contactDeleteHeading => 'Eliminar contacto';

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
    return 'Conectado a través de $mediatorName';
  }

  @override
  String contactAdded(String dateAdded) {
    return 'Añadido $dateAdded';
  }

  @override
  String get filter => 'Filtro...';

  @override
  String get noContactsMatchFilter =>
      'No hay contactos que coincidan con tu filtro';

  @override
  String connectionPhrase(String phrase) {
    return 'Frase: $phrase';
  }

  @override
  String usesIdentityViaMediator(String identity, String mediator) {
    return 'Utiliza su identidad $identity a través de $mediator';
  }

  @override
  String get timeAgoJustNow => 'Justo ahora';

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
  String get timeAgoMinuteWorded => 'Hace un minuto';

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
  String get timeAgoHourWorded => 'Hace una hora';

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
  String get timeAgoYesterday => 'Ayer';

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
  String get timeAgoLastWeek => 'La semana pasada';

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
    return 'Creado $createdTimeAgo, válido hasta $validUntilDate';
  }

  @override
  String createdValidWithoutExpiration(String createdTimeAgo) {
    return 'Creado $createdTimeAgo, sin fecha de caducidad';
  }

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get generalName => 'Nombre';

  @override
  String get displayNameHelperText =>
      'Puede cambiar el nombre para mostrar de este contacto. La otra parte no verá este nombre.';

  @override
  String get generalEmail => 'Correo electrónico';

  @override
  String get generalMobile => 'Móvil';

  @override
  String get generalDid => '¿LO HUDÓ?';

  @override
  String get generalDidSha256 => 'TID (SHA256)';

  @override
  String get connectionEstablished => 'Canal establecido';

  @override
  String get generalMediator => 'Servidor de mensajes';

  @override
  String get connectionApproach => 'Enfoque de establecimiento de canales';

  @override
  String get theirDetails => 'Sus detalles';

  @override
  String get mySharedIdentityDetails => 'Mis datos de identidad compartidos';

  @override
  String get connectionDetails => 'Detalles de conexión de canal';

  @override
  String get myIdentity => 'Mi identidad';

  @override
  String get identitiesPanelSubtitle =>
      'Desliza el dedo hacia la izquierda y hacia la derecha para revisar y agregar a tu lista de identidades, arrastra hacia abajo para eliminar ';

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
  String get identityDeleteHeading => 'Eliminar identidad';

  @override
  String identityDeletePrompt(Object identity) {
    return '¿Está seguro de que desea eliminar la identidad \"$identity\"?\n\n¡No puedes recuperar una identidad!';
  }

  @override
  String get displayNamePrimary => 'Identidad primaria';

  @override
  String get displayNameAddNew => 'Agregar nueva identidad';

  @override
  String get displayNameAlias => 'Alias de identidad';

  @override
  String get subtitlePrimary => 'Su identidad principal';

  @override
  String get subtitleAddNew => 'Crear un nuevo alias';

  @override
  String get subtitleAlias => 'Identidad de alias';

  @override
  String get notShared => 'No compartido';

  @override
  String get unknownUser => 'Usuario desconocido';

  @override
  String get addNewIdentityAlias => 'Agregar nuevo alias de identidad';

  @override
  String get identityAliasesDescription =>
      'Toma el control de tu privacidad, creando alias de identidad para representarte a ti mismo ante los contactos con los que te conectas';

  @override
  String get generalReject => 'RECHAZAR';

  @override
  String get generalApprove => 'APROBAR';

  @override
  String get zalgoTextDetectedError =>
      'Personajes inusuales detectados. Por favor, elimínelos e inténtelo de nuevo.';

  @override
  String get chatTooLong => 'El mensaje de chat es demasiado largo';

  @override
  String get splashScreenTitle => 'Lugar de encuentro';

  @override
  String get toProtectData =>
      'Para proteger sus datos, esta aplicación requiere una autenticación segura para continuar.';

  @override
  String get authInstructionAndroid =>
      'Ve a Configuración > Seguridad > Bloqueo de pantalla y habilita un PIN, un patrón o una huella digital.';

  @override
  String get authInstructionIos =>
      'Ve a Configuración > Face ID y código de acceso (o Touch ID y código de acceso) y configura Face ID, Touch ID o un código de acceso del dispositivo.';

  @override
  String get authInstructionMacos =>
      'Ve a Configuración del sistema > Touch ID y contraseña (o contraseña de inicio de sesión) y configura Touch ID o una contraseña segura.';

  @override
  String get authUnlockReason => 'Desbloquea tu dispositivo para continuar';

  @override
  String chatTypeMessagePrompt(String name) {
    return 'Mensaje para $name';
  }

  @override
  String get chatAddMessageToMediaPrompt => 'Agregar un mensaje';

  @override
  String get chatTypeMessagePromptGroup => 'Mensaje al canal';

  @override
  String get updatePrimaryIdentity => 'Actualización de la identidad principal';

  @override
  String get newIdentityAlias => 'Nuevo alias de identidad';

  @override
  String editIdentityTitle(String identityName) {
    return 'Editar identidad: $identityName';
  }

  @override
  String get customiseIdentityCard => 'Personaliza el documento de identidad';

  @override
  String get nameTooLong => 'El nombre es demasiado largo';

  @override
  String get descriptionTooLong => 'La descripción es demasiado larga';

  @override
  String get invalidEmail => 'La dirección de correo electrónico no es válida';

  @override
  String get emailTooLong =>
      'La dirección de correo electrónico es demasiado larga';

  @override
  String get invalidMobileNumber => 'El número de teléfono móvil no es válido';

  @override
  String get mobileTooLong => 'El número de móvil es demasiado largo';

  @override
  String get aliasTooLong => 'El alias es demasiado largo';

  @override
  String get thisFieldIsRequired => 'Este campo es obligatorio';

  @override
  String get identityAliasPersonalDetails =>
      'Datos personales de alias de identidad';

  @override
  String get profilePictureChangePrompt =>
      'Pulsa aquí para cambiar tu foto de perfil';

  @override
  String get firstName => 'Nombre';

  @override
  String get enterFirstName => 'Ingrese el nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get enterLastName => 'Ingrese el apellido';

  @override
  String get email => 'Correo electrónico';

  @override
  String get enterEmail => 'Ingrese el correo electrónico';

  @override
  String get mobile => 'Móvil';

  @override
  String get enterMobile => 'Ingrese al móvil';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get aliasLabel => 'Etiqueta de alias';

  @override
  String get enterAliasLabel => 'Introduzca la etiqueta de alias';

  @override
  String get aliasLabelHelperText =>
      'La etiqueta de alias es la forma en que se referirá a este alias cuando se conecte. Use un nombre descriptivo para que sea más fácil de identificar.';

  @override
  String get setupPrimaryIdentityTitle =>
      '¡Configuremos tu identidad principal!';

  @override
  String get setupPrimaryIdentityDescription =>
      'Tu identidad principal se utilizará de forma predeterminada cuando te conectes con otras personas.';

  @override
  String get primaryIdentityInformation =>
      'Su información de identidad principal';

  @override
  String get primaryIdentityComplete => 'Mi identidad principal está completa';

  @override
  String get keepMeAnonymous => 'Mantenme en el anonimato';

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
  String get unknownType => 'Tipo desconocido';

  @override
  String get loadImageFailed => 'Error al cargar la imagen';

  @override
  String get chatRequestPermissionToJoinGroupFailed =>
      'No se pudo unir al grupo';

  @override
  String get genWordConciergeMessage => 'Mensaje de conserjería';

  @override
  String chatRequestPermissionToJoinGroup(String memberName) {
    return '$memberName quiere unirse al grupo';
  }

  @override
  String get genWordNo => 'No';

  @override
  String get genWordLater => 'Más tarde';

  @override
  String get genWordYes => 'Sí';

  @override
  String get chatRequestPermissionToUpdateProfileGroup =>
      'Los detalles del perfil compartidos con este grupo han cambiado. ¿Le gustaría actualizar a todos los miembros?';

  @override
  String get chatRequestPermissionToUpdateProfile =>
      'Los detalles del perfil compartidos con este contacto han cambiado. ¿Te gustaría enviarles una actualización?';

  @override
  String chatStartOfConversationInitiatedByMe(String date, String time) {
    return 'Estableciste este canal en $date en $time';
  }

  @override
  String get messageCopiedClipboard => 'Mensaje copiado en el portapapeles';

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
  String get qrScannerTitle => 'Escanear código QR';

  @override
  String get qrScannerInstructions => 'Coloca el código QR dentro del marco';

  @override
  String qrScannerStatus(String status) {
    return 'Estado del escáner: $status';
  }

  @override
  String get useCamera => 'Usar cámara';

  @override
  String get chooseFromGallery => 'Elige de la galería';

  @override
  String get qrScannerCameraNotAvailable => 'Cámara no disponible';

  @override
  String get qrScannerCameraPermissionHelp =>
      'Verifique los permisos de la cámara e inténtelo de nuevo';

  @override
  String get qrScannerConnectionFailed => 'Error de conexión';

  @override
  String qrScannerConnectionFailedMessage(String error) {
    return 'No se pudo establecer la conexión: $error';
  }

  @override
  String get qrScannerTryAgain => 'Vuelve a intentarlo';

  @override
  String get qrScannerTimeoutError =>
      'Se agotó el tiempo de espera de aceptación del flujo OOB después de 30 segundos';

  @override
  String get customMediators => 'Servidores de mensajes personalizados';

  @override
  String get addCustomMediator => 'Agregar servidor de mensajes personalizado';

  @override
  String get manageCustomMediators =>
      'Administrar el servidor de mensajes personalizados';

  @override
  String get configureCustomMediatorEndpoint =>
      'Configurar su propio punto de conexión del servidor de mensajes';

  @override
  String get noCustomMediatorsConfigured =>
      'Aún no hay servidores de mensajes personalizados configurados';

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
    return 'Añadido servidor de mensajes \"$name\"';
  }

  @override
  String failedToAddMediator(String error) {
    return 'No se pudo agregar el servidor de mensajes: $error';
  }

  @override
  String get mediatorName => 'Nombre del servidor de mensajes';

  @override
  String get mediatorDid => 'Servidor de mensajes DID';

  @override
  String get myCustomMediator => 'Mi servidor de mensajes personalizado';

  @override
  String get pleaseEnterName => 'Por favor, introduzca un nombre';

  @override
  String get pleaseEnterDid => 'Por favor, introduzca un DID';

  @override
  String get didMustStartWith => 'DID debe comenzar con \"did:\"';

  @override
  String get deleteCustomMediator =>
      'Eliminar servidor de mensajes personalizados';

  @override
  String deleteCustomMediatorConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?\n\nEsta acción no se puede deshacer.';
  }

  @override
  String deletedMediatorSuccess(String name) {
    return 'Servidor de mensajes eliminados \"$name\"';
  }

  @override
  String renamedMediatorSuccess(String name) {
    return 'Se ha cambiado el nombre del servidor de mensajes a \"$name\"';
  }

  @override
  String failedToDeleteMediator(String error) {
    return 'No se pudo eliminar el servidor de mensajes: $error';
  }

  @override
  String failedToRenameMediator(String error) {
    return 'No se pudo cambiar el nombre del servidor de mensajes: $error';
  }

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get generalClose => 'Cerrar';

  @override
  String get generalAdd => 'Agregar';

  @override
  String get noIdentityDetected =>
      'No se detectó ninguna identidad, cree una para continuar.';

  @override
  String get connectWithPersonAiServiceBusiness =>
      'Conéctese con una persona o un agente de IA';

  @override
  String get chatScreenTapForMemberDetails =>
      'Toque para obtener los detalles del miembro';

  @override
  String get debugPanelTitle => 'Panel de depuración';

  @override
  String get debugPanelSubtitle =>
      'Ver registros de aplicaciones e información de depuración';

  @override
  String get debugPanelNoLogs => 'No hay registros disponibles';

  @override
  String get debugPanelLogsAppearMessage =>
      'Los registros aparecerán aquí a medida que use la aplicación';

  @override
  String get debugPanelClearLogs => 'Borrar registros';

  @override
  String get debugPanelCopyLogs => 'Copiar registros en el portapapeles';

  @override
  String get debugPanelAddTestLog => 'Agregar registro de pruebas';

  @override
  String get debugPanelLogsCopied => 'Registros copiados en el portapapeles';

  @override
  String get serverSettings => 'Configuración del servidor';

  @override
  String get serverSettingsHelperText =>
      'Seleccione el servidor predeterminado para la comunicación de mensajería';

  @override
  String get debugSettingsTitle => 'Configuración de depuración';

  @override
  String get debugModeLabel => 'Modo de depuración';

  @override
  String debugModeHelperText(int tapCount) {
    return 'El modo de depuración está habilitado. Toca información de la versión $tapCount veces para alternar.';
  }

  @override
  String get settingsScreenSubtitle =>
      'Configurar los ajustes y preferencias de la aplicación';

  @override
  String get versionInfoHeader => 'Versión del lugar de reunión';

  @override
  String versionInfoVersion(String version) {
    return 'Versión $version';
  }

  @override
  String versionInfoBuild(String buildNumber) {
    return 'Construcción: $buildNumber';
  }

  @override
  String get easterEggEnabled =>
      '🎉 ¡Huevo de Pascua desbloqueado! Modo de depuración habilitado';

  @override
  String get debugModeDisabled => 'Modo de depuración deshabilitado';

  @override
  String get generalCamera => 'Cámara';

  @override
  String get generalPhoto => 'Foto';

  @override
  String get generalBalloons => 'Globos';

  @override
  String get generalConfetti => 'Confeti';

  @override
  String get chatItemStatusError => 'Error';

  @override
  String get formValidationHeadlineRequired => 'Se requiere título';

  @override
  String get formValidationDescriptionRequired => 'Se requiere descripción';

  @override
  String get formValidationCustomPhraseRequired =>
      'Se requiere una frase personalizada cuando no se usa una frase aleatoria';

  @override
  String get formValidationExpiryDateRequired =>
      'La fecha de caducidad es necesaria cuando la caducidad está habilitada';

  @override
  String get formValidationExpiryDateFuture =>
      'La fecha de caducidad debe ser futura';

  @override
  String get formValidationMaxUsagesGreaterThanZero =>
      'Los usos máximos deben ser mayores que 0';

  @override
  String get genericPublishError => 'No se pudo publicar la oferta';

  @override
  String get groupDetails => 'Detalles del canal de grupo';

  @override
  String groupMessageInfo(String memberName, String date, String time) {
    return '$memberName en $date en $time';
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
  String get groupMembers => 'Miembros del grupo';

  @override
  String get showExited => 'Mostrar salido';

  @override
  String get groupMemberExited => 'Salió del grupo';

  @override
  String get groupNoMembersToChat =>
      'Actualmente eres el único miembro de este grupo. Puede comenzar a chatear cuando otro miembro se una.';

  @override
  String get generalJoined => 'Unido';

  @override
  String get you => 'Tú';

  @override
  String get groupAdmin => 'Administrador de grupos';

  @override
  String get onboardingPage1Title => 'Bienvenidos a\nLugar de encuentro';

  @override
  String get onboardingPage1Desc => 'Funciona con\nMensajería de Affinidi';

  @override
  String get onboardingPage2Title => 'Privado y seguro';

  @override
  String get onboardingPage2Desc =>
      'Conéctese con otras personas de forma segura y privada con cifrado de extremo a extremo';

  @override
  String get onboardingPage3Title => 'Toma el control de tu identidad';

  @override
  String get onboardingPage3Desc =>
      'Protege tu privacidad con alias. Demuestra tu identidad con credenciales verificadas';

  @override
  String get onboardingPage4Title => 'Listo para empezar';

  @override
  String get onboardingPage4Desc =>
      'Configuremos tu identidad\n¡y te ayudaré a comenzar!';

  @override
  String get setUpMyIdentity => 'Configurar mi identidad';

  @override
  String get revealConnectionCode =>
      'Revelar frase de contraseña de invitación';

  @override
  String versionInfoAppName(String appName) {
    return 'Meeting Place \"$appName\"';
  }

  @override
  String get platformNotSupported =>
      'Este plugin no es compatible con tu plataforma actual';

  @override
  String get generalOfferInformation => 'Información sobre la invitación';

  @override
  String get generalOfferLink => 'Enlace de invitación';

  @override
  String get generalMnemonic => 'Mnemotécnico';

  @override
  String get generalConnectionType => 'Tipo de conexión';

  @override
  String get generalExternalRef => 'Referencia externa';

  @override
  String get generalGroupDid => 'Grupo DID';

  @override
  String get generalGroupId => 'ID de grupo';

  @override
  String get copiedToClipboard => 'Copiado en el portapapeles';

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
  String get publishing => 'Publicando';

  @override
  String get loading => 'Cargando';

  @override
  String get deleting => 'Eliminando';

  @override
  String get showQrScannerForOffers => 'Mostrar escáner QR para invitaciones';

  @override
  String get meetingPlaceControlPlane =>
      'Plano de control del lugar de reunión';

  @override
  String get searching => 'Minucioso';

  @override
  String get connecting => 'Conectivo';

  @override
  String get approving => 'Aprobatorio';

  @override
  String get rejecting => 'RECHAZAR';

  @override
  String get sending => 'Envío';

  @override
  String get connectionRequestRejected =>
      'La solicitud de conexión ha sido rechazada';

  @override
  String get connectionRequestInProgress =>
      'Aceptación de invitación en curso. La otra parte puede tardar unos minutos en responder y finalizar el canal.';

  @override
  String requestToConnect(Object firstName) {
    return 'La aceptación de la invitación se ha enviado $firstName. Es posible que tarden unos minutos en responder a su solicitud.';
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
    return '$memberName se ha unido al grupo';
  }

  @override
  String leavingGroup(String memberName) {
    return '$memberName ha dejado el grupo';
  }

  @override
  String get concierge => 'Conserje';

  @override
  String get groupDeleted => 'Este grupo ha sido eliminado';
}

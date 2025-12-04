import '../../models/contacts/contact.dart';

enum OOBQrResultType { canceled, automaticallyAccepted }

class OOBQrResultWithContact {
  OOBQrResultWithContact(this.resultType, {this.contact});

  OOBQrResultType resultType;
  Contact? contact;
}

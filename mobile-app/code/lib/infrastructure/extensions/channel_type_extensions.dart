import 'package:meeting_place_core/meeting_place_core.dart';

import '../../domain/models/contacts/contact_type.dart';

/// Map MPX ChannelType to the app's ContactType.
extension ChannelTypeContactType on ChannelType {
  ContactType toContactType() {
    switch (this) {
      case ChannelType.oob:
      case ChannelType.individual:
        return ContactType.individual;
      case ChannelType.group:
        return ContactType.group;
    }
  }
}

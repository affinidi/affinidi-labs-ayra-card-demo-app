import 'models/verifier_client.dart';

class ClientsList {
  static VerifierClient kioskClient = clientsAvailable[0];
  static VerifierClient roundtableClient = clientsAvailable[1];
  static VerifierClient checkinDeskClient = clientsAvailable[2];
  static VerifierClient coffeeshopClient = clientsAvailable[3];
}

final clientsAvailable = [
  VerifierClient(
    id: "kiosk",
    name: 'Building Access',
    type: 'internal',
    description: 'Secure access control for office building',
    purpose: 'Share your credentials to get secure access to the building',
  ),
  VerifierClient(
    id: "roundtable",
    name: 'Strategy Session',
    type: 'internal',
    description: 'Secure access control for 6th floor session',
    purpose: 'Share your credentials to have session in secure area',
  ),
  VerifierClient(
    id: "check-in-desk",
    name: 'Hotel Check-in',
    type: 'external',
    description: 'Fast and secure hotel check-in',
    purpose: 'Share your credentials to have a smooth check-in experience',
  ),
  VerifierClient(
    id: "coffeeshop",
    name: 'Coffee Shop',
    type: 'external',
    description: 'Exclusive offers and rewards',
    purpose: 'Share your credentials to get exclusive offers/rewards',
  ),
];

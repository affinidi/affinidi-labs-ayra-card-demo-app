enum ContactOrigin {
  directInteractive(1),
  individualOfferPublished(2),
  individualOfferRequested(3),
  groupOfferPublished(4),
  groupOfferRequested(5),
  unknown(0);

  const ContactOrigin(this.value);

  final int value;
}

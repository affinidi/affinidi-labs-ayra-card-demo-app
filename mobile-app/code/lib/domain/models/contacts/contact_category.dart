enum ContactCategory {
  unknown(0),
  person(1),
  adult(2),
  robot(4),
  service(8),
  organization(16),
  poll(32),
  group(64);

  const ContactCategory(this.value);

  final int value;
}

enum ContactType {
  individual(1),
  group(2),
  unknown(0);

  const ContactType(this.value);

  final int value;
}

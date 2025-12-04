enum ContactStatus {
  pendingApproval(1),
  pendingInauguration(2),
  approved(3),
  rejected(4),
  error(5),
  deleted(6),
  unknown(0),
  active(7);

  const ContactStatus(this.value);

  final int value;
}

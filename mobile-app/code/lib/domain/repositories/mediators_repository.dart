import '../models/mediator/mediator.dart';

abstract interface class MediatorsRepository {
  Future<List<Mediator>> listMediators();
  Future<List<Mediator>> listDefaultMediators();
  Future<List<Mediator>> listCustomMediators();
  Future<void> addCustomMediator({required String did, required String name});
  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  });
  Future<void> removeMediator(String did);
}

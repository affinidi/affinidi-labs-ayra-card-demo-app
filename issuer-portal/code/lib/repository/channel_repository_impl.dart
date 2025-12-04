import 'dart:convert';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../storage/storage_interface.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  static const String channelPrefix = 'channel_';

  final IStorage _storage;

  ChannelRepositoryImpl({required IStorage storage}) : _storage = storage;

  @override
  Future<void> createChannel(Channel channel) async {
    return _writeChannel(channel);
  }

  @override
  Future<Channel?> findChannelByDid(String did) async {
    final channels = await _storage.getCollection(channelPrefix);
    for (final entry in channels) {
      final channel = Channel.fromJson(
        json.decode(entry) as Map<String, dynamic>,
      );
      if (channel.permanentChannelDid == did ||
          channel.otherPartyPermanentChannelDid == did) {
        return channel;
      }
    }
    return null;
  }

  @override
  Future<Channel?> findChannelByOtherPartyPermanentChannelDid(
    String did,
  ) async {
    final channels = await _storage.getCollection(channelPrefix);
    for (final entry in channels) {
      final channel = Channel.fromJson(
        json.decode(entry) as Map<String, dynamic>,
      );
      if (channel.otherPartyPermanentChannelDid == did) {
        return channel;
      }
    }
    return null;
  }

  @override
  Future<Channel?> findChannelByOfferLink(String offerLink) async {
    final channels = await _storage.getCollection(channelPrefix);
    for (final entry in channels) {
      final channel = Channel.fromJson(
        json.decode(entry) as Map<String, dynamic>,
      );
      if (channel.offerLink == offerLink) {
        return channel;
      }
    }
    return null;
  }

  @override
  Future<void> updateChannel(Channel channel) async {
    return _writeChannel(channel);
  }

  @override
  Future<void> deleteChannel(Channel channel) async {
    await _storage.remove('$channelPrefix${channel.id}');
  }

  Future<void> _writeChannel(Channel channel) async {
    await _storage.put(
      '$channelPrefix${channel.id}',
      json.encode(channel.toJson()),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_shared.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IsolateMessage _$IsolateMessageFromJson(Map<String, dynamic> json) =>
    _IsolateMessage(
      name: $enumDecode(_$MessageNameEnumMap, json['name']),
      destination: $enumDecodeNullable(
        _$MessageDestinationEnumMap,
        json['destination'],
      ),
      id: (json['id'] as num?)?.toInt(),
      alerts:
          (json['alerts'] as List<dynamic>?)
              ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
              .toList(),
      sourceData:
          json['sourceData'] == null
              ? null
              : AlertSourceDataUpdate.fromJson(
                json['sourceData'] as Map<String, dynamic>,
              ),
      forceRefreshNow: json['forceRefreshNow'] as bool?,
      alreadyFetching: json['alreadyFetching'] as bool?,
    );

Map<String, dynamic> _$IsolateMessageToJson(_IsolateMessage instance) =>
    <String, dynamic>{
      'name': _$MessageNameEnumMap[instance.name]!,
      'destination': _$MessageDestinationEnumMap[instance.destination],
      'id': instance.id,
      'alerts': instance.alerts,
      'sourceData': instance.sourceData,
      'forceRefreshNow': instance.forceRefreshNow,
      'alreadyFetching': instance.alreadyFetching,
    };

const _$MessageNameEnumMap = {
  MessageName.alertsInit: 'alertsInit',
  MessageName.alertsFetching: 'alertsFetching',
  MessageName.alertsFetched: 'alertsFetched',
  MessageName.fetchAlerts: 'fetchAlerts',
  MessageName.refreshTimer: 'refreshTimer',
  MessageName.initSources: 'initSources',
  MessageName.addSource: 'addSource',
  MessageName.updateSource: 'updateSource',
  MessageName.removeSource: 'removeSource',
  MessageName.enableNotifications: 'enableNotifications',
  MessageName.disableNotifications: 'disableNotifications',
  MessageName.toggleSounds: 'toggleSounds',
  MessageName.playDesktopSound: 'playDesktopSound',
  MessageName.sourcesChanged: 'sourcesChanged',
  MessageName.sourcesFailure: 'sourcesFailure',
  MessageName.showRefreshIndicator: 'showRefreshIndicator',
  MessageName.updateLastSeen: 'updateLastSeen',
  MessageName.confirmSources: 'confirmSources',
  MessageName.confirmSourcesReply: 'confirmSourcesReply',
  MessageName.backgroundReady: 'backgroundReady',
  MessageName.alertFiltersChanged: 'alertFiltersChanged',
};

const _$MessageDestinationEnumMap = {
  MessageDestination.drop: 'drop',
  MessageDestination.alerts: 'alerts',
  MessageDestination.notifications: 'notifications',
  MessageDestination.refreshIcon: 'refreshIcon',
  MessageDestination.sourceSettings: 'sourceSettings',
  MessageDestination.accountEditing: 'accountEditing',
};

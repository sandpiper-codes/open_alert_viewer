// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Alert _$AlertFromJson(Map<String, dynamic> json) => _Alert(
  source: (json['source'] as num).toInt(),
  kind: $enumDecode(_$AlertTypeEnumMap, json['kind']),
  hostname: json['hostname'] as String,
  service: json['service'] as String,
  message: json['message'] as String,
  serviceUrl: json['serviceUrl'] as String,
  monitorUrl: json['monitorUrl'] as String,
  age: Duration(microseconds: (json['age'] as num).toInt()),
  downtimeScheduled: json['downtimeScheduled'] as bool,
  silenced: json['silenced'] as bool,
  active: json['active'] as bool,
  enabled: json['enabled'] as bool,
);

Map<String, dynamic> _$AlertToJson(_Alert instance) => <String, dynamic>{
  'source': instance.source,
  'kind': _$AlertTypeEnumMap[instance.kind]!,
  'hostname': instance.hostname,
  'service': instance.service,
  'message': instance.message,
  'serviceUrl': instance.serviceUrl,
  'monitorUrl': instance.monitorUrl,
  'age': instance.age.inMicroseconds,
  'downtimeScheduled': instance.downtimeScheduled,
  'silenced': instance.silenced,
  'active': instance.active,
  'enabled': instance.enabled,
};

const _$AlertTypeEnumMap = {
  AlertType.okay: 'okay',
  AlertType.warning: 'warning',
  AlertType.error: 'error',
  AlertType.pending: 'pending',
  AlertType.unknown: 'unknown',
  AlertType.up: 'up',
  AlertType.unreachable: 'unreachable',
  AlertType.down: 'down',
  AlertType.hostPending: 'hostPending',
  AlertType.syncFailure: 'syncFailure',
};

_AlertSourceData _$AlertSourceDataFromJson(Map<String, dynamic> json) =>
    _AlertSourceData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
      authType: (json['authType'] as num).toInt(),
      baseURL: json['baseURL'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      failing: json['failing'] as bool,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      priorFetch: DateTime.parse(json['priorFetch'] as String),
      lastFetch: DateTime.parse(json['lastFetch'] as String),
      errorMessage: json['errorMessage'] as String,
      isValid: json['isValid'] as bool?,
      accessToken: json['accessToken'] as String,
      visible: json['visible'] as bool,
      notifications: json['notifications'] as bool,
      serial: (json['serial'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AlertSourceDataToJson(_AlertSourceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'authType': instance.authType,
      'baseURL': instance.baseURL,
      'username': instance.username,
      'password': instance.password,
      'failing': instance.failing,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'priorFetch': instance.priorFetch.toIso8601String(),
      'lastFetch': instance.lastFetch.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'isValid': instance.isValid,
      'accessToken': instance.accessToken,
      'visible': instance.visible,
      'notifications': instance.notifications,
      'serial': instance.serial,
    };

_AlertSourceDataUpdate _$AlertSourceDataUpdateFromJson(
  Map<String, dynamic> json,
) => _AlertSourceDataUpdate(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  type: (json['type'] as num).toInt(),
  authType: (json['authType'] as num?)?.toInt(),
  baseURL: json['baseURL'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  errorMessage: json['errorMessage'] as String,
  isValid: json['isValid'] as bool?,
  accessToken: json['accessToken'] as String,
  serial: (json['serial'] as num?)?.toInt(),
);

Map<String, dynamic> _$AlertSourceDataUpdateToJson(
  _AlertSourceDataUpdate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'authType': instance.authType,
  'baseURL': instance.baseURL,
  'username': instance.username,
  'password': instance.password,
  'errorMessage': instance.errorMessage,
  'isValid': instance.isValid,
  'accessToken': instance.accessToken,
  'serial': instance.serial,
};

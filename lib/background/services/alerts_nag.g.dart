// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_nag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NagAlertsData _$NagAlertsDataFromJson(Map<String, dynamic> json) =>
    _NagAlertsData(
      data:
          json['data'] == null
              ? null
              : NagDataSection.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NagAlertsDataToJson(_NagAlertsData instance) =>
    <String, dynamic>{'data': instance.data};

_NagDataSection _$NagDataSectionFromJson(Map<String, dynamic> json) =>
    _NagDataSection(
      hostlist: (json['hostlist'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          e == null ? null : NagAlertData.fromJson(e as Map<String, dynamic>),
        ),
      ),
      servicelist: (json['servicelist'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              e == null
                  ? null
                  : NagAlertData.fromJson(e as Map<String, dynamic>),
            ),
          ),
        ),
      ),
    );

Map<String, dynamic> _$NagDataSectionToJson(_NagDataSection instance) =>
    <String, dynamic>{
      'hostlist': instance.hostlist,
      'servicelist': instance.servicelist,
    };

_NagAlertData _$NagAlertDataFromJson(
  Map<String, dynamic> json,
) => _NagAlertData(
  description: json['description'] as String?,
  status: (json['status'] as num?)?.toInt(),
  scheduled_downtime_depth: (json['scheduled_downtime_depth'] as num?)?.toInt(),
  problem_has_been_acknowledged: json['problem_has_been_acknowledged'] as bool?,
  last_state_change: (json['last_state_change'] as num?)?.toInt(),
  last_hard_state_change: (json['last_hard_state_change'] as num?)?.toInt(),
  last_check: (json['last_check'] as num?)?.toInt(),
  state_type: (json['state_type'] as num?)?.toInt(),
  plugin_output: json['plugin_output'] as String?,
);

Map<String, dynamic> _$NagAlertDataToJson(_NagAlertData instance) =>
    <String, dynamic>{
      'description': instance.description,
      'status': instance.status,
      'scheduled_downtime_depth': instance.scheduled_downtime_depth,
      'problem_has_been_acknowledged': instance.problem_has_been_acknowledged,
      'last_state_change': instance.last_state_change,
      'last_hard_state_change': instance.last_hard_state_change,
      'last_check': instance.last_check,
      'state_type': instance.state_type,
      'plugin_output': instance.plugin_output,
    };

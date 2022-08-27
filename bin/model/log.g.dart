// GENERATED CODE - DO NOT MODIFY BY HAND

part of './log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      id: json['id'] as String?,
      alertID: json['alert_id'] as String,
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'alert_id': instance.alertID,
      'time': instance.time.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of './action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Action _$ActionFromJson(Map<String, dynamic> json) => Action(
      id: json['id'] as String?,
      alertID: json['alert_id'] as String,
      deviceID: json['device_id'] as String,
      attributeID: json['attribute_id'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$ActionToJson(Action instance) => <String, dynamic>{
      'id': instance.id,
      'alert_id': instance.alertID,
      'device_id': instance.deviceID,
      'attribute_id': instance.attributeID,
      'value': instance.value,
    };

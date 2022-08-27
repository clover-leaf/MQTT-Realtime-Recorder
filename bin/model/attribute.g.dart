// GENERATED CODE - DO NOT MODIFY BY HAND

part of './attribute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attribute _$AttributeFromJson(Map<String, dynamic> json) => Attribute(
      id: json['id'] as String?,
      deviceID: json['device_id'] as String,
      name: json['name'] as String,
      jsonPath: json['json_path'] as String,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$AttributeToJson(Attribute instance) => <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceID,
      'name': instance.name,
      'json_path': instance.jsonPath,
      'unit': instance.unit,
    };

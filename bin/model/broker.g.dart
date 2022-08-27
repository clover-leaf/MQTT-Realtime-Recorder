// GENERATED CODE - DO NOT MODIFY BY HAND

part of './broker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Broker _$BrokerFromJson(Map<String, dynamic> json) => Broker(
      schema: json['schema'] as String,
      id: json['id'] as String,
      projectID: json['project_id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      port: json['port'] as int,
      account: json['account'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$BrokerToJson(Broker instance) => <String, dynamic>{
      'schema': instance.schema,
      'id': instance.id,
      'project_id': instance.projectID,
      'name': instance.name,
      'url': instance.url,
      'port': instance.port,
      'account': instance.account,
      'password': instance.password,
    };

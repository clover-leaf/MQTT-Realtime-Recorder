// GENERATED CODE - DO NOT MODIFY BY HAND

part of './condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Condition _$ConditionFromJson(Map<String, dynamic> json) => Condition(
      id: json['id'] as String?,
      alertID: json['alert_id'] as String,
      attributeID: json['attribute_id'] as String,
      comparison: ComparationX.fromString(json['comparison'] as String),
      value: json['value'] as String,
    );

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
      'id': instance.id,
      'alert_id': instance.alertID,
      'attribute_id': instance.attributeID,
      'comparison': instance.comparison.toString(),
      'value': instance.value,
    };

extension ComparationX on Comparison {
  static Comparison fromString(String str) {
    switch (str) {
      case 'geq':
        return Comparison.geq;
      case 'g':
        return Comparison.g;
      case 'eq':
        return Comparison.eq;
      case 'l':
        return Comparison.l;
      case 'leq':
        return Comparison.leq;
      default:
        return Comparison.leq;
    }
  }

  String get name {
    switch (this) {
      case Comparison.geq:
        return 'geq';
      case Comparison.g:
        return 'g';
      case Comparison.eq:
        return 'eq';
      case Comparison.l:
        return 'l';
      case Comparison.leq:
        return 'leq';
      default:
        return 'leq';
    }
  }
}

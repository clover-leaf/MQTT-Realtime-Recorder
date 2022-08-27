import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'condition.g.dart';

/// Condition model for an API providing to access condition
class Condition extends Equatable {
  /// {macro Condition}
  Condition({
    String? id,
    required this.alertID,
    required this.attributeID,
    required this.comparison,
    required this.value,
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// The ID
  final String id;

  /// The alert ID
  final String alertID;

  /// The attribute ID
  final String attributeID;

  /// The name of condition
  final Comparison comparison;

  /// The value
  final String value;

  /// Deserializes the given [Map<String, dynamic>] into a [Condition].
  static Condition fromJson(Map<String, dynamic> json) {
    return _$ConditionFromJson(json);
  }

  /// Converts this [Condition] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$ConditionToJson(this);

  /// Returns a copy of [Condition] with given parameters
  Condition copyWith({
    String? id,
    String? alertID,
    String? attributeID,
    Comparison? comparison,
    String? value,
  }) {
    return Condition(
      id: id ?? this.id,
      alertID: alertID ?? this.alertID,
      attributeID: attributeID ?? this.attributeID,
      comparison: comparison ?? this.comparison,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, alertID, attributeID, comparison, value];
}

/// Condition comparison
// ignore_for_file: public_member_api_docs

enum Comparison {
  ///
  geq,

  ///
  g,

  ///
  eq,

  ///
  l,

  ///
  leq
}

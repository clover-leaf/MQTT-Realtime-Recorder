import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'action.g.dart';

/// Action model for an API providing to access condition
class Action extends Equatable {
  /// {macro Action}
  Action({
    String? id,
    required this.alertID,
    required this.deviceID,
    required this.attributeID,
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
  final String deviceID;

  /// The attribute ID
  final String attributeID;

  /// The name of condition
  final String value;

  /// Deserializes the given [Map<String, dynamic>] into a [Action].
  static Action fromJson(Map<String, dynamic> json) {
    return _$ActionFromJson(json);
  }

  /// Converts this [Action] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$ActionToJson(this);

  /// Returns a copy of [Action] with given parameters
  Action copyWith({
    String? id,
    String? alertID,
    String? deviceID,
    String? attributeID,
    String? value,
  }) {
    return Action(
      id: id ?? this.id,
      alertID: alertID ?? this.alertID,
      deviceID: deviceID ?? this.deviceID,
      attributeID: attributeID ?? this.attributeID,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, alertID, deviceID, attributeID, value];
}

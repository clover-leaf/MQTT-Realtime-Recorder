import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'attribute.g.dart';

/// Attribute model for an API providing to access attribute
class Attribute extends Equatable {
  /// {macro Attribute}
  Attribute({
    String? id,
    required this.deviceID,
    required this.name,
    required this.jsonPath,
    this.unit,
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// The ID
  final String id;

  /// The device ID
  final String deviceID;

  /// The name of attribute
  final String name;

  /// The json path of attribute
  final String jsonPath;

  /// The unit of attribute
  final String? unit;

  /// Deserializes the given [Map<String, dynamic>] into a [Attribute].
  static Attribute fromJson(Map<String, dynamic> json) {
    return _$AttributeFromJson(json);
  }

  /// Converts this [Attribute] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$AttributeToJson(this);

  /// Returns a copy of [Attribute] with given parameters
  Attribute copyWith({
    String? id,
    String? deviceID,
    String? name,
    String? jsonPath,
    String? unit,
  }) {
    return Attribute(
      id: id ?? this.id,
      deviceID: deviceID ?? this.deviceID,
      name: name ?? this.name,
      jsonPath: jsonPath ?? this.jsonPath,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [id, deviceID, name, jsonPath, unit];
}

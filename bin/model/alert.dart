import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'alert.g.dart';

/// Alert model for an API providing to access alert
class Alert extends Equatable {
  /// {macro Alert}
  Alert({
    String? id,
    required this.deviceID,
    required this.name,
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// The ID
  final String id;

  /// The project ID
  final String deviceID;

  /// The name of alert
  final String name;

  /// Deserializes the given [Map<String, dynamic>] into a [Alert].
  static Alert fromJson(Map<String, dynamic> json) {
    return _$AlertFromJson(json);
  }

  /// Converts this [Alert] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$AlertToJson(this);

  /// Returns a copy of [Alert] with given parameters
  Alert copyWith({
    String? id,
    String? deviceID,
    String? name,
  }) {
    return Alert(
      id: id ?? this.id,
      deviceID: deviceID ?? this.deviceID,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, deviceID, name];
}

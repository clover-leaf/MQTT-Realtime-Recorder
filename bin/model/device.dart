import 'package:equatable/equatable.dart';

part 'device.g.dart';

/// Device model for an API providing to access device
class Device extends Equatable {
  /// {macro Device}
  Device({
    required this.id,
    required this.groupID,
    required this.brokerID,
    required this.name,
    required this.topic,
  });

  /// The ID
  final String id;

  /// The parent group ID
  final String groupID;

  /// The broker ID
  final String brokerID;

  /// The name of device
  final String name;

  /// The topic of device
  final String topic;

  /// Deserializes the given [Map<String, dynamic>] into a [Device].
  static Device fromJson(Map<String, dynamic> json) {
    return _$DeviceFromJson(json);
  }

  /// Converts this [Device] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  /// Returns a copy of [Device] with given parameters
  Device copyWith({
    String? id,
    String? groupID,
    String? brokerID,
    String? name,
    String? topic,
  }) {
    return Device(
      id: id ?? this.id,
      groupID: groupID ?? this.groupID,
      brokerID: brokerID ?? this.brokerID,
      name: name ?? this.name,
      topic: topic ?? this.topic,
    );
  }

  @override
  List<Object> get props => [id, groupID, brokerID, name, topic];
}

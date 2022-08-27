import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'log.g.dart';

/// Log model for an API providing to access log
class Log extends Equatable {
  /// {macro Log}
  Log({
    String? id,
    required this.alertID,
    required this.time,
  })  : assert(
          id == null || id.isNotEmpty,
          'id can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4();

  /// The ID
  final String id;

  /// The alert ID
  final String alertID;

  /// The alert ID
  final DateTime time;

  /// Deserializes the given [Map<String, dynamic>] into a [Log].
  static Log fromJson(Map<String, dynamic> json) {
    return _$LogFromJson(json);
  }

  /// Converts this [Log] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$LogToJson(this);

  /// Returns a copy of [Log] with given parameters
  Log copyWith({
    String? id,
    String? alertID,
    DateTime? time,
  }) {
    return Log(
      id: id ?? this.id,
      alertID: alertID ?? this.alertID,
      time: time ?? this.time,
    );
  }

  @override
  List<Object?> get props => [id, alertID, time];
}

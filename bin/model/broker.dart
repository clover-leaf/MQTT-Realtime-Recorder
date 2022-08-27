import 'package:equatable/equatable.dart';

part 'broker.g.dart';

/// Broker model for an API providing to access broker
class Broker extends Equatable {
  /// {macro Broker}
  Broker({
    required this.schema,
    required this.id,
    required this.projectID,
    required this.name,
    required this.url,
    required this.port,
    required this.account,
    required this.password,
  });

  /// The schema
  final String schema;

  /// The ID
  final String id;

  /// The project ID
  final String projectID;

  /// The name of broker
  final String name;

  /// The url of broker
  final String url;

  /// The port of broker
  final int port;

  /// The account of broker
  final String? account;

  /// The password of broker
  final String? password;

  /// Deserializes the given [Map<String, dynamic>] into a [Broker].
  static Broker fromJson(Map<String, dynamic> json) {
    return _$BrokerFromJson(json);
  }

  /// Converts this [Broker] into a [Map<String, dynamic>].
  Map<String, dynamic> toJson() => _$BrokerToJson(this);

  /// Returns a copy of [Broker] with given parameters
  Broker copyWith({
    String? schema,
    String? id,
    String? projectID,
    String? name,
    String? url,
    int? port,
    String? account,
    String? password,
  }) {
    return Broker(
      schema: schema ?? this.schema,
      id: id ?? this.id,
      projectID: projectID ?? this.projectID,
      name: name ?? this.name,
      url: url ?? this.url,
      port: port ?? this.port,
      account: account ?? this.account,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props =>
      [schema, id, projectID, name, url, port, account, password];
}

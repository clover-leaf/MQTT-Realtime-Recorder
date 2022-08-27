part of 'counter_bloc.dart';

class CounterState extends Equatable {
  CounterState(
      {this.gatewayClientView = const {},
      this.brokerTopics = const {},
      this.deviceAttributeView = const {},
      this.deviceAlertView = const {},
      this.alertConditionView = const {},
      this.alertActionView = const {},
      this.brokers = const [],
      this.devices = const [],
      this.attributes = const [],
      this.alerts = const [],
      this.conditions = const [],
      this.actions = const [],
      this.schemaDatabaseView = const {}});

  /// <BrokerID, GatewayClient>
  /// cặp project ID và gateway client
  /// phụ thuộc brokers
  final Map<String, GatewayClient> gatewayClientView;

  /// <BrokerID, [topic]>
  /// giá trị phụ thuộc vào brokers, devices
  final Map<String, List<String>> brokerTopics;

  /// <DeviceID, List<Attribute> in device>
  final Map<String, List<Attribute>> deviceAttributeView;

  /// <DeviceID, List<Alert> in device>
  final Map<String, List<Alert>> deviceAlertView;

  /// <AlertID, List<Condition> in alert>
  final Map<String, List<Condition>> alertConditionView;

  /// <AlertID, List<Action> in alert>
  final Map<String, List<Action>> alertActionView;

  // === Update by stream ===
  final List<Broker> brokers;
  final List<Device> devices;
  final List<Attribute> attributes;
  final List<Alert> alerts;
  final List<Condition> conditions;
  final List<Action> actions;
  // <schema, DatabaseClient>
  final Map<String, DatabaseClient> schemaDatabaseView;

  // ===
  late final Map<String, Broker> brokerView = {
    for (final br in brokers) br.id: br
  };

  late final Map<String, Device> deviceView = {
    for (final dv in devices) dv.id: dv
  };

  late final Map<String, Attribute> attributeView = {
    for (final att in attributes) att.id: att
  };

  late final Map<String, Alert> alertView = {
    for (final al in alerts) al.id: al
  };

  late final Map<String, Condition> conditionView = {
    for (final cd in conditions) cd.id: cd
  };

  late final Map<String, Action> actionView = {
    for (final ac in actions) ac.id: ac
  };

  CounterState copyWith({
    Map<String, GatewayClient>? gatewayClientView,
    Map<String, List<String>>? brokerTopics,
    Map<String, DatabaseClient>? schemaDatabaseView,
    Map<String, List<Attribute>>? deviceAttributeView,
    Map<String, List<Alert>>? deviceAlertView,
    Map<String, List<Condition>>? alertConditionView,
    Map<String, List<Action>>? alertActionView,
    List<Broker>? brokers,
    List<Device>? devices,
    List<Attribute>? attributes,
    List<Alert>? alerts,
    List<Condition>? conditions,
    List<Action>? actions,
  }) =>
      CounterState(
        gatewayClientView: gatewayClientView ?? this.gatewayClientView,
        brokerTopics: brokerTopics ?? this.brokerTopics,
        schemaDatabaseView: schemaDatabaseView ?? this.schemaDatabaseView,
        deviceAttributeView: deviceAttributeView ?? this.deviceAttributeView,
        deviceAlertView: deviceAlertView ?? this.deviceAlertView,
        alertConditionView: alertConditionView ?? this.alertConditionView,
        alertActionView: alertActionView ?? this.alertActionView,
        brokers: brokers ?? this.brokers,
        devices: devices ?? this.devices,
        attributes: attributes ?? this.attributes,
        alerts: alerts ?? this.alerts,
        conditions: conditions ?? this.conditions,
        actions: actions ?? this.actions,
      );

  @override
  List<Object?> get props => [
        gatewayClientView,
        schemaDatabaseView,
        deviceAttributeView,
        deviceAlertView,
        alertConditionView,
        alertActionView,
        brokers,
        devices,
        attributes,
        alerts,
        conditions,
        actions,
      ];
}

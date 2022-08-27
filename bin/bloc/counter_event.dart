part of 'counter_bloc.dart';

class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

class InitializationRequested extends CounterEvent {
  const InitializationRequested();
}

class PrintRequested extends CounterEvent {
  const PrintRequested();
}

class BrokerConnectionRequested extends CounterEvent {
  const BrokerConnectionRequested(this.gatewayClient);

  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [gatewayClient];
}

class GatewayListenRequested extends CounterEvent {
  const GatewayListenRequested(this.gatewayClient);

  final GatewayClient gatewayClient;

  @override
  List<Object?> get props => [gatewayClient];
}

// ==== Schema manipulate ====
class SchemaAdded extends CounterEvent {
  const SchemaAdded(this.schema);

  final String schema;

  @override
  List<Object?> get props => [schema];
}

class SchemaDeleted extends CounterEvent {
  const SchemaDeleted(this.schema);

  final String schema;

  @override
  List<Object?> get props => [schema];
}

// ==== Broker manipulate ====
class BrokerAdded extends CounterEvent {
  const BrokerAdded(this.broker);

  final Broker broker;

  @override
  List<Object?> get props => [broker];
}

class BrokerEdited extends CounterEvent {
  const BrokerEdited(this.broker);

  final Broker broker;

  @override
  List<Object?> get props => [broker];
}

class BrokerDeleted extends CounterEvent {
  const BrokerDeleted(this.brokerID);

  final String brokerID;

  @override
  List<Object?> get props => [brokerID];
}

// ==== Device manipulate ====
class DeviceAdded extends CounterEvent {
  const DeviceAdded(this.device);

  final Device device;

  @override
  List<Object?> get props => [device];
}

class DeviceEdited extends CounterEvent {
  const DeviceEdited(this.device);

  final Device device;

  @override
  List<Object?> get props => [device];
}

class DeviceDeleted extends CounterEvent {
  const DeviceDeleted(this.deviceID);

  final String deviceID;

  @override
  List<Object?> get props => [deviceID];
}

// ==== Attribute manipulate ====
class AttributeAdded extends CounterEvent {
  const AttributeAdded(this.attribute);

  final Attribute attribute;

  @override
  List<Object?> get props => [attribute];
}

class AttributeEdited extends CounterEvent {
  const AttributeEdited(this.attribute);

  final Attribute attribute;

  @override
  List<Object?> get props => [attribute];
}

class AttributeDeleted extends CounterEvent {
  const AttributeDeleted(this.attributeID);

  final String attributeID;

  @override
  List<Object?> get props => [attributeID];
}

// ==== Alert manipulate ====
class AlertAdded extends CounterEvent {
  const AlertAdded(this.alert);

  final Alert alert;

  @override
  List<Object?> get props => [alert];
}

class AlertEdited extends CounterEvent {
  const AlertEdited(this.alert);

  final Alert alert;

  @override
  List<Object?> get props => [alert];
}

class AlertDeleted extends CounterEvent {
  const AlertDeleted(this.alertID);

  final String alertID;

  @override
  List<Object?> get props => [alertID];
}

// ==== Condition manipulate ====
class ConditionAdded extends CounterEvent {
  const ConditionAdded(this.condition);

  final Condition condition;

  @override
  List<Object?> get props => [condition];
}

class ConditionEdited extends CounterEvent {
  const ConditionEdited(this.condition);

  final Condition condition;

  @override
  List<Object?> get props => [condition];
}

class ConditionDeleted extends CounterEvent {
  const ConditionDeleted(this.conditionID);

  final String conditionID;

  @override
  List<Object?> get props => [conditionID];
}

// ==== Action manipulate ====
class ActionAdded extends CounterEvent {
  const ActionAdded(this.action);

  final Action action;

  @override
  List<Object?> get props => [action];
}

class ActionEdited extends CounterEvent {
  const ActionEdited(this.action);

  final Action action;

  @override
  List<Object?> get props => [action];
}

class ActionDeleted extends CounterEvent {
  const ActionDeleted(this.actionID);

  final String actionID;

  @override
  List<Object?> get props => [actionID];
}

class BrokerSubscriptionRequested extends CounterEvent {
  const BrokerSubscriptionRequested();
}

class DeviceSubscriptionRequested extends CounterEvent {
  const DeviceSubscriptionRequested();
}

class AttributeSubscriptionRequested extends CounterEvent {
  const AttributeSubscriptionRequested();
}

class AlertSubscriptionRequested extends CounterEvent {
  const AlertSubscriptionRequested();
}

class ConditionSubscriptionRequested extends CounterEvent {
  const ConditionSubscriptionRequested();
}

class ActionSubscriptionRequested extends CounterEvent {
  const ActionSubscriptionRequested();
}

class DatabaseSaveRecordRequested extends CounterEvent {
  const DatabaseSaveRecordRequested({
    required this.databaseClient,
    required this.brokerID,
    required this.topic,
    required this.payload,
  });

  final DatabaseClient databaseClient;
  final String brokerID;
  final String topic;
  final String payload;

  @override
  List<Object?> get props => [databaseClient, brokerID, topic, payload];
}

class DatabaseSaveLogRequested extends CounterEvent {
  const DatabaseSaveLogRequested(
      {required this.databaseClient, required this.log});

  final DatabaseClient databaseClient;
  final Log log;

  @override
  List<Object?> get props => [databaseClient, log];
}

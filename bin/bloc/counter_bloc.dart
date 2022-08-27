import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rfc_6901/rfc_6901.dart';
import 'package:rxdart/subjects.dart';

import '../database_client.dart';
import '../fcm_client.dart';
import '../gateway_client/gateway_client.dart';
import '../model/model.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc(this._fcmClient) : super(CounterState()) {
    on<InitializationRequested>(_onInitialized);
    on<SchemaAdded>(_onSchemaAdded);
    on<SchemaDeleted>(_onSchemaDeleted);
    on<BrokerAdded>(_onBrokerAdded);
    on<BrokerEdited>(_onBrokerEdited);
    on<BrokerDeleted>(_onBrokerDeleted);
    on<DeviceAdded>(_onDeviceAdded);
    on<DeviceEdited>(_onDeviceEdited);
    on<DeviceDeleted>(_onDeviceDeleted);
    on<AttributeAdded>(_onAttributeAdded);
    on<AttributeEdited>(_onAttributeEdited);
    on<AttributeDeleted>(_onAttributeDeleted);
    on<AlertAdded>(_onAlertAdded);
    on<AlertEdited>(_onAlertEdited);
    on<AlertDeleted>(_onAlertDeleted);
    on<ConditionAdded>(_onConditionAdded);
    on<ConditionEdited>(_onConditionEdited);
    on<ConditionDeleted>(_onConditionDeleted);
    on<ActionAdded>(_onActionAdded);
    on<ActionEdited>(_onActionEdited);
    on<ActionDeleted>(_onActionDeleted);
    on<BrokerSubscriptionRequested>(_onBrokerSubscribed);
    on<DeviceSubscriptionRequested>(_onDeviceSubscribed);
    on<AttributeSubscriptionRequested>(_onAttributeSubscribed);
    on<AlertSubscriptionRequested>(_onAlertSubscribed);
    on<ConditionSubscriptionRequested>(_onConditionSubscribed);
    on<ActionSubscriptionRequested>(_onActionSubscribed);
    on<BrokerConnectionRequested>(
      _onBrokerConnected,
      transformer: concurrent(),
    );
    on<GatewayListenRequested>(
      _onGatewayListened,
      transformer: concurrent(),
    );
    on<DatabaseSaveRecordRequested>(
      _onSaveRecord,
      transformer: concurrent(),
    );
    on<DatabaseSaveLogRequested>(
      _onSaveLog,
      transformer: concurrent(),
    );
  }

  final FcmClient _fcmClient;

  final _brokerStreamController = BehaviorSubject<List<Broker>>.seeded([]);
  final _deviceStreamController = BehaviorSubject<List<Device>>.seeded([]);
  final _attributeStreamController =
      BehaviorSubject<List<Attribute>>.seeded([]);
  final _alertStreamController = BehaviorSubject<List<Alert>>.seeded([]);
  final _conditionStreamController =
      BehaviorSubject<List<Condition>>.seeded([]);
  final _actionStreamController = BehaviorSubject<List<Action>>.seeded([]);

  Future<void> _onInitialized(
    InitializationRequested event,
    Emitter<CounterState> emit,
  ) async {
    add(const BrokerSubscriptionRequested());
    add(const DeviceSubscriptionRequested());
    add(const AttributeSubscriptionRequested());
    add(const AlertSubscriptionRequested());
    add(const ConditionSubscriptionRequested());
    add(const ActionSubscriptionRequested());

    final baseDbClient = DatabaseClient('sys');
    final resDbSchemas =
        await baseDbClient.client.rpc('get_db_schemas').execute();
    final rawSchema = resDbSchemas.data.split('=')[1].split(',');
    final schemas = (rawSchema as List<String>).map((sc) => sc.trim()).toList();
    schemas
      ..remove('public')
      ..remove('storage')
      ..remove('sys');
    final schemaClientView = <String, DatabaseClient>{};
    for (final schema in schemas) {
      schemaClientView[schema] = DatabaseClient(schema);
    }

    final brokers = <Broker>[];
    final devices = <Device>[];
    final attributes = <Attribute>[];
    final alerts = <Alert>[];
    final conditions = <Condition>[];
    final actions = <Action>[];
    for (final dbClient in schemaClientView.values) {
      final jsonBrokers = await dbClient.getAllBroker();
      final brokersInDomain =
          jsonBrokers.map((json) => Broker.fromJson(json)).toList();
      brokers.addAll(brokersInDomain);

      final jsonDevices = await dbClient.getAllDevice();
      final devicesInDomain = jsonDevices
          .map((json) => Device.fromJson(json as Map<String, dynamic>))
          .toList();
      devices.addAll(devicesInDomain);

      final jsonAttributes = await dbClient.getAllAttribute();
      final attributesInDomain = jsonAttributes
          .map((json) => Attribute.fromJson(json as Map<String, dynamic>))
          .toList();
      attributes.addAll(attributesInDomain);

      final jsonAlerts = await dbClient.getAllAlert();
      final alertsInDomain = jsonAlerts
          .map((json) => Alert.fromJson(json as Map<String, dynamic>))
          .toList();
      alerts.addAll(alertsInDomain);

      final jsonConditions = await dbClient.getAllCondition();
      final conditionsInDomain = jsonConditions
          .map((json) => Condition.fromJson(json as Map<String, dynamic>))
          .toList();
      conditions.addAll(conditionsInDomain);

      final jsonActions = await dbClient.getAllAction();
      final actionsInDomain = jsonActions
          .map((json) => Action.fromJson(json as Map<String, dynamic>))
          .toList();
      actions.addAll(actionsInDomain);
    }
    _brokerStreamController.add(brokers);
    _deviceStreamController.add(devices);
    _attributeStreamController.add(attributes);
    _alertStreamController.add(alerts);
    _conditionStreamController.add(conditions);
    _actionStreamController.add(actions);
    emit(state.copyWith(schemaDatabaseView: schemaClientView));
  }

  void _onSchemaAdded(SchemaAdded event, Emitter<CounterState> emit) {
    final schemaDatabaseView =
        Map<String, DatabaseClient>.from(state.schemaDatabaseView);
    final databaseClient = DatabaseClient(event.schema);
    schemaDatabaseView[event.schema] = databaseClient;
    emit(state.copyWith(schemaDatabaseView: schemaDatabaseView));
  }

  void _onSchemaDeleted(SchemaDeleted event, Emitter<CounterState> emit) {
    final schemaDatabaseView =
        Map<String, DatabaseClient>.from(state.schemaDatabaseView);
    final brokers = List<Broker>.from(state.brokers);
    final brokerView = Map<String, Broker>.from(state.brokerView);
    final devices = List<Device>.from(state.devices);

    devices.removeWhere((dv) {
      final broker = brokerView[dv.brokerID];
      if (broker != null && broker.schema == event.schema) {
        return true;
      } else {
        return false;
      }
    });
    brokers.removeWhere((br) => br.schema == event.schema);
    schemaDatabaseView.remove(event.schema);

    _deviceStreamController.add(devices);
    _brokerStreamController.add(brokers);
    // _schemaStreamController.add(schemaDatabaseView);
  }

  void _onBrokerAdded(BrokerAdded event, Emitter<CounterState> emit) {
    // clone
    final brokers = List<Broker>.from(state.brokers);
    brokers.add(event.broker);
    _brokerStreamController.add(brokers);
  }

  void _onBrokerEdited(BrokerEdited event, Emitter<CounterState> emit) {
    // clone
    final brokers = List<Broker>.from(state.brokers);
    final brokerView = Map<String, Broker>.from(state.brokerView);
    final oldBroker = brokerView[event.broker.id];
    if (oldBroker != null) {
      final index = brokers.indexOf(oldBroker);
      brokers[index] = event.broker;
      _brokerStreamController.add(brokers);
    }
  }

  void _onBrokerDeleted(BrokerDeleted event, Emitter<CounterState> emit) {
    // clone
    final brokers = List<Broker>.from(state.brokers);
    final devices = List<Device>.from(state.devices);
    brokers.removeWhere((br) => br.id == event.brokerID);
    devices.removeWhere((dv) => dv.brokerID == event.brokerID);
    _deviceStreamController.add(devices);
    _brokerStreamController.add(brokers);
  }

  void _onDeviceAdded(DeviceAdded event, Emitter<CounterState> emit) {
    // clone
    final devices = List<Device>.from(state.devices);
    devices.add(event.device);
    _deviceStreamController.add(devices);
  }

  void _onDeviceEdited(DeviceEdited event, Emitter<CounterState> emit) {
    // clone
    final devices = List<Device>.from(state.devices);
    final deviceView = Map<String, Device>.from(state.deviceView);
    final oldDevice = deviceView[event.device.id];
    if (oldDevice != null) {
      final index = devices.indexOf(oldDevice);
      devices[index] = event.device;
      _deviceStreamController.add(devices);
    }
  }

  void _onDeviceDeleted(DeviceDeleted event, Emitter<CounterState> emit) {
    // clone
    final devices = List<Device>.from(state.devices);
    devices.removeWhere((dv) => dv.id == event.deviceID);
    _deviceStreamController.add(devices);
  }

  void _onAttributeAdded(AttributeAdded event, Emitter<CounterState> emit) {
    // clone
    final attributes = List<Attribute>.from(state.attributes);
    attributes.add(event.attribute);
    _attributeStreamController.add(attributes);
  }

  void _onAttributeEdited(AttributeEdited event, Emitter<CounterState> emit) {
    // clone
    final attributes = List<Attribute>.from(state.attributes);
    final attributeView = Map<String, Attribute>.from(state.attributeView);
    final oldAttribute = attributeView[event.attribute.id];
    if (oldAttribute != null) {
      final index = attributes.indexOf(oldAttribute);
      attributes[index] = event.attribute;
      _attributeStreamController.add(attributes);
    }
  }

  void _onAttributeDeleted(AttributeDeleted event, Emitter<CounterState> emit) {
    // clone
    final attributes = List<Attribute>.from(state.attributes);
    attributes.removeWhere((dv) => dv.id == event.attributeID);
    _attributeStreamController.add(attributes);
  }

  void _onAlertAdded(AlertAdded event, Emitter<CounterState> emit) {
    // clone
    final alerts = List<Alert>.from(state.alerts);
    alerts.add(event.alert);
    _alertStreamController.add(alerts);
  }

  void _onAlertEdited(AlertEdited event, Emitter<CounterState> emit) {
    // clone
    final alerts = List<Alert>.from(state.alerts);
    final alertView = Map<String, Alert>.from(state.alertView);
    final oldAlert = alertView[event.alert.id];
    if (oldAlert != null) {
      final index = alerts.indexOf(oldAlert);
      alerts[index] = event.alert;
      _alertStreamController.add(alerts);
    }
  }

  void _onAlertDeleted(AlertDeleted event, Emitter<CounterState> emit) {
    // clone
    final alerts = List<Alert>.from(state.alerts);
    alerts.removeWhere((dv) => dv.id == event.alertID);
    _alertStreamController.add(alerts);
  }

  void _onConditionAdded(ConditionAdded event, Emitter<CounterState> emit) {
    // clone
    final conditions = List<Condition>.from(state.conditions);
    conditions.add(event.condition);
    _conditionStreamController.add(conditions);
  }

  void _onConditionEdited(ConditionEdited event, Emitter<CounterState> emit) {
    // clone
    final conditions = List<Condition>.from(state.conditions);
    final conditionView = Map<String, Condition>.from(state.conditionView);
    final oldCondition = conditionView[event.condition.id];
    if (oldCondition != null) {
      final index = conditions.indexOf(oldCondition);
      conditions[index] = event.condition;
      _conditionStreamController.add(conditions);
    }
  }

  void _onConditionDeleted(ConditionDeleted event, Emitter<CounterState> emit) {
    // clone
    final conditions = List<Condition>.from(state.conditions);
    conditions.removeWhere((dv) => dv.id == event.conditionID);
    _conditionStreamController.add(conditions);
  }

  void _onActionAdded(ActionAdded event, Emitter<CounterState> emit) {
    // clone
    final actions = List<Action>.from(state.actions);
    actions.add(event.action);
    _actionStreamController.add(actions);
  }

  void _onActionEdited(ActionEdited event, Emitter<CounterState> emit) {
    // clone
    final actions = List<Action>.from(state.actions);
    final actionView = Map<String, Action>.from(state.actionView);
    final oldAction = actionView[event.action.id];
    if (oldAction != null) {
      final index = actions.indexOf(oldAction);
      actions[index] = event.action;
      _actionStreamController.add(actions);
    }
  }

  void _onActionDeleted(ActionDeleted event, Emitter<CounterState> emit) {
    // clone
    final actions = List<Action>.from(state.actions);
    actions.removeWhere((dv) => dv.id == event.actionID);
    _actionStreamController.add(actions);
  }

  Future<void> _onBrokerConnected(
    BrokerConnectionRequested event,
    Emitter<CounterState> emit,
  ) async {
    try {
      await event.gatewayClient.connect();
      // clone and update brokerTopicPayloads
      final brokerTopics = Map<String, List<String>>.from(state.brokerTopics);
      final brokerTopic =
          brokerTopics[event.gatewayClient.brokerID] ?? <String>[];
      for (final dv in state.devices) {
        if (dv.brokerID == event.gatewayClient.brokerID) {
          event.gatewayClient.subscribe(dv.topic);
          if (!brokerTopic.contains(dv.topic)) {
            brokerTopic.add(dv.topic);
          }
        }
      }
      brokerTopics[event.gatewayClient.brokerID] = brokerTopic;
      add(GatewayListenRequested(event.gatewayClient));
      emit(state.copyWith(brokerTopics: brokerTopics));
    } catch (e) {
      Future.delayed(Duration(seconds: 6),
          () => add(BrokerConnectionRequested(event.gatewayClient)));
    }
  }

  Future<void> _onGatewayListened(
    GatewayListenRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit.forEach<Map<String, String>>(
      getPublishMessage(event.gatewayClient),
      onData: (message) {
        final schema = message['schema']!;
        final brokerID = message['broker_id']!;
        final topic = message['topic']!;
        final payload = message['payload']!;
        final databaseClient = state.schemaDatabaseView[schema];
        if (databaseClient != null) {
          add(DatabaseSaveRecordRequested(
            databaseClient: databaseClient,
            brokerID: brokerID,
            topic: topic,
            payload: payload,
          ));
        }
        for (final dv in state.devices) {
          if (dv.brokerID == brokerID && dv.topic == topic) {
            print('${dv.name} receive: $payload');
            final attributeInDevice = state.deviceAttributeView[dv.id];
            if (attributeInDevice != null) {
              for (final att in attributeInDevice) {
                final value =
                    readJson(expression: att.jsonPath, payload: payload);
                print('${att.name} (${att.jsonPath}): $value');
              }
            }
            final alertInDevice = state.deviceAlertView[dv.id];
            if (alertInDevice != null) {
              for (final alert in alertInDevice) {
                final conditionInAlert = state.alertConditionView[alert.id];
                var active = conditionInAlert?.isNotEmpty ?? false;
                if (conditionInAlert != null) {
                  for (final condition in conditionInAlert) {
                    final attributeOfCondition =
                        state.attributeView[condition.attributeID];
                    if (attributeOfCondition != null) {
                      final value = readJson(
                          expression: attributeOfCondition.jsonPath,
                          payload: payload);
                      final valueDouble = double.tryParse(value);
                      final thresholdDouble = double.tryParse(condition.value);
                      if (valueDouble != null && thresholdDouble != null) {
                        switch (condition.comparison) {
                          case Comparison.g:
                            active = active && valueDouble > thresholdDouble;
                            break;
                          case Comparison.geq:
                            active = active && valueDouble >= thresholdDouble;
                            break;
                          case Comparison.eq:
                            active = active && valueDouble == thresholdDouble;
                            break;
                          case Comparison.leq:
                            active = active && valueDouble <= thresholdDouble;
                            break;
                          case Comparison.l:
                            active = active && valueDouble < thresholdDouble;
                            break;
                          default:
                        }
                      }
                    }
                  }
                }
                if (active) {
                  print('${alert.name} actived');
                  _fcmClient.sendPushNotification(payload: {
                    'included_segments': ['Subscribed Users'],
                    'contents': {
                      'en': 'English or Any Language Message',
                      'es': 'Spanish Message'
                    },
                    'name': 'INTERNAL_CAMPAIGN_NAME'
                  });
                  final log = Log(alertID: alert.id, time: DateTime.now());
                  if (databaseClient != null) {
                    add(DatabaseSaveLogRequested(
                        databaseClient: databaseClient, log: log));
                  }
                  final actionInAlert = state.alertActionView[alert.id];
                  if (actionInAlert != null) {
                    for (final action in actionInAlert) {
                      final deviceOfAction = state.deviceView[action.deviceID];
                      final attributeOfAction =
                          state.attributeView[action.attributeID];
                      if (deviceOfAction != null && attributeOfAction != null) {
                        final gatewayClient =
                            state.gatewayClientView[deviceOfAction.brokerID];
                        final status = gatewayClient?.client.connectionStatus;
                        if (gatewayClient != null &&
                            status != null &&
                            status.state == MqttConnectionState.connected) {
                          final payload = writeJson(
                              expression: attributeOfAction.jsonPath,
                              value: action.value);
                          final topic = deviceOfAction.topic;
                          gatewayClient.published(
                              payload: payload, topic: topic, retain: true);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        return state;
      },
    );
  }

  Future<void> _onSaveRecord(
      DatabaseSaveRecordRequested event, Emitter<CounterState> emit) async {
    final value = {
      'broker_id': event.brokerID,
      'topic': event.topic,
      'payload': event.payload,
    };
    await event.databaseClient.client.from('storage').insert(value).execute();
  }

  Future<void> _onSaveLog(
      DatabaseSaveLogRequested event, Emitter<CounterState> emit) async {
    final value = event.log.toJson();
    await event.databaseClient.client.from('log').insert(value).execute();
  }

  Future<void> _onBrokerSubscribed(
      BrokerSubscriptionRequested event, Emitter<CounterState> emit) async {
    await emit
        .forEach<List<Broker>>(_brokerStreamController.asBroadcastStream(),
            onError: (error, stackTrace) {
      print(error);
      return state;
    }, onData: (brokers) {
      final brokerView = {for (final br in brokers) br.id: br};
      // clone
      final gatewayClientView =
          Map<String, GatewayClient>.from(state.gatewayClientView);
      final brokerTopics = Map<String, List<String>>.from(state.brokerTopics);
      // hanlde new broker
      final newBrokers = brokers
          .where(
            (br) => !state.brokerView.keys.contains(br.id),
          )
          .toList();
      for (final br in newBrokers) {
        final gatewayClient = GatewayClient(
          schema: br.schema,
          brokerID: br.id,
          url: br.url,
          port: br.port,
          account: br.account,
          password: br.password,
        );
        gatewayClientView[br.id] = gatewayClient;
        brokerTopics[br.id] = <String>[];
        add(BrokerConnectionRequested(gatewayClient));
      }
      // handle edited brokers
      final editedBrokers = brokers
          .where(
            (br) =>
                state.brokerView.keys.contains(br.id) &&
                state.brokerView[br.id] != brokerView[br.id],
          )
          .toList();
      for (final br in editedBrokers) {
        final oldBr = state.brokerView[br.id];
        if (oldBr == null) {
          return state;
        }
        // only restart gateway client when either
        // url, port, account, password has changed
        if (oldBr.url != brokerView[br.id]!.url ||
            oldBr.port != brokerView[br.id]!.port ||
            oldBr.account != brokerView[br.id]!.account ||
            oldBr.password != brokerView[br.id]!.password) {
          // disconnect old gwCl
          final oldGatewayClient = gatewayClientView[br.id];
          final status = oldGatewayClient?.client.connectionStatus;
          if (oldGatewayClient != null &&
              status != null &&
              status.state == MqttConnectionState.connected) {
            oldGatewayClient.disconnect();
          }
          // create new gateway client
          final gatewayClient = GatewayClient(
            schema: br.schema,
            brokerID: br.id,
            url: br.url,
            port: br.port,
            account: br.account,
            password: br.password,
          );
          gatewayClientView[br.id] = gatewayClient;
          add(BrokerConnectionRequested(gatewayClient));
        }
      }
      // handle deleted brokers
      final deletedBrokers = state.brokers
          .where((br) => !brokerView.keys.contains(br.id))
          .toList();
      for (final br in deletedBrokers) {
        final gatewayClient = gatewayClientView[br.id];
        final status = gatewayClient?.client.connectionStatus;
        if (gatewayClient != null &&
            status != null &&
            status.state == MqttConnectionState.connected) {
          gatewayClient.disconnect();
        }
        // remove it from brTpPl
        brokerTopics.remove(br.id);
        // remove it from gwClView
        gatewayClientView.remove(br.id);
      }
      return state.copyWith(
        brokers: brokers,
        gatewayClientView: gatewayClientView,
        brokerTopics: brokerTopics,
      );
    });
  }

  Future<void> _onDeviceSubscribed(
    DeviceSubscriptionRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit
        .forEach<List<Device>>(_deviceStreamController.asBroadcastStream(),
            onError: (error, stackTrace) {
      print(error);
      print(stackTrace);
      return state;
    }, onData: (devices) {
      final deviceView = {for (final dv in devices) dv.id: dv};
      // clone
      final brokerTopics = Map<String, List<String>>.from(state.brokerTopics);
      final deviceAttributeView =
          Map<String, List<Attribute>>.from(state.deviceAttributeView);
      final deviceAlertView =
          Map<String, List<Alert>>.from(state.deviceAlertView);
      // handle new device
      final newDevices = devices
          .where(
            (dv) => !state.deviceView.keys.contains(dv.id),
          )
          .toList();
      for (final dv in newDevices) {
        final brokerTopic = brokerTopics[dv.brokerID];
        if (brokerTopic != null) {
          // neu chua subscribe
          if (!brokerTopic.contains(dv.topic)) {
            brokerTopic.add(dv.topic);
            final gatewayClient = state.gatewayClientView[dv.brokerID];
            final status = gatewayClient?.client.connectionStatus;
            if (gatewayClient != null &&
                status != null &&
                status.state == MqttConnectionState.connected) {
              gatewayClient.subscribe(dv.topic);
            }
            brokerTopics[dv.brokerID] = brokerTopic;
          }
        }
        deviceAttributeView[dv.id] = [];
        deviceAlertView[dv.id] = [];
      }
      // handle edited devices
      final editedDevices = devices
          .where(
            (dv) =>
                state.deviceView.containsKey(dv.id) &&
                state.deviceView[dv.id] != deviceView[dv.id],
          )
          .toList();
      for (final dv in editedDevices) {
        final oldDevice = state.deviceView[dv.id];
        if (oldDevice == null) {
          return state;
        }
        // only handle when device changed broker or topic
        if (oldDevice.brokerID != dv.brokerID || oldDevice.topic != dv.topic) {
          // delete old topic from old brokerTopic
          final oldBrokerTopic = brokerTopics[oldDevice.brokerID];
          if (oldBrokerTopic != null) {
            if (oldBrokerTopic.contains(oldDevice.topic)) {
              oldBrokerTopic.remove(oldDevice.topic);
              // unsubscribe old topic
              final gatewayClient = state.gatewayClientView[oldDevice.brokerID];
              if (gatewayClient != null) {
                gatewayClient.unsubscribe(oldDevice.topic);
              }
            }
            brokerTopics[oldDevice.brokerID] = oldBrokerTopic;
          }
        }
        // add new topic to brokerTopic
        final newBrokerTopic = brokerTopics[dv.brokerID];
        if (newBrokerTopic != null) {
          if (!newBrokerTopic.contains(dv.topic)) {
            newBrokerTopic.add(dv.topic);
            final gatewayClient = state.gatewayClientView[dv.brokerID];
            final status = gatewayClient?.client.connectionStatus;
            if (gatewayClient != null &&
                status != null &&
                status.state == MqttConnectionState.connected) {
              gatewayClient.subscribe(dv.topic);
            }
            brokerTopics[dv.brokerID] = newBrokerTopic;
          }
        }
      }
      // handle deleted devices
      final deleteDevices = state.devices
          .where((dv) => !deviceView.keys.contains(dv.id))
          .toList();
      for (final dv in deleteDevices) {
        final brokerTopic = brokerTopics[dv.brokerID];
        if (brokerTopic != null) {
          if (brokerTopic.contains(dv.topic)) {
            brokerTopic.remove(dv.topic);
            final gatewayClient = state.gatewayClientView[dv.brokerID];
            final status = gatewayClient?.client.connectionStatus;
            if (gatewayClient != null &&
                status != null &&
                status.state == MqttConnectionState.connected) {
              gatewayClient.unsubscribe(dv.topic);
            }
            brokerTopics[dv.brokerID] = brokerTopic;
          }
        }
        deviceAttributeView.remove(dv.id);
        deviceAlertView.remove(dv.id);
      }
      return state.copyWith(
        devices: devices,
        brokerTopics: brokerTopics,
        deviceAttributeView: deviceAttributeView,
        deviceAlertView: deviceAlertView,
      );
    });
  }

  Future<void> _onAttributeSubscribed(
    AttributeSubscriptionRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit.forEach<List<Attribute>>(
      _attributeStreamController.asBroadcastStream(),
      onData: (attributes) {
        final attributeView = {for (final att in attributes) att.id: att};
        // clone
        final deviceAttributeView =
            Map<String, List<Attribute>>.from(state.deviceAttributeView);
        // handle new attribute
        final newAttributes = attributes
            .where((att) => !state.attributeView.keys.contains(att.id))
            .toList();
        for (final att in newAttributes) {
          final deviceAttribute = deviceAttributeView[att.deviceID];
          if (deviceAttribute != null) {
            deviceAttributeView[att.deviceID] = [...deviceAttribute, att];
          }
        }
        // handle edited attributes
        final editedAttributes = attributes
            .where((att) =>
                state.attributeView.containsKey(att.id) &&
                state.attributeView[att.id] != attributeView[att.id])
            .toList();
        for (final att in editedAttributes) {
          final oldAtt = state.attributeView[att.id]!;
          final oldDeviceAttribute = deviceAttributeView[oldAtt.deviceID];
          if (oldDeviceAttribute != null) {
            oldDeviceAttribute.removeWhere((att) => att.id == oldAtt.id);
            deviceAttributeView[oldAtt.deviceID] = oldDeviceAttribute;
          }

          final deviceAttribute = deviceAttributeView[att.deviceID];
          if (deviceAttribute != null) {
            deviceAttributeView[att.deviceID] = [...deviceAttribute, att];
          }
        }
        // handle delete attribute
        final deletedAttributes = state.attributes
            .where((att) => !attributeView.keys.contains(att.id))
            .toList();
        for (final att in deletedAttributes) {
          final deviceAttribute = deviceAttributeView[att.deviceID];
          if (deviceAttribute != null) {
            deviceAttribute.remove(att);
            deviceAttributeView[att.deviceID] = deviceAttribute;
          }
        }
        return state.copyWith(
          attributes: attributes,
          deviceAttributeView: deviceAttributeView,
        );
      },
    );
  }

  Future<void> _onAlertSubscribed(
    AlertSubscriptionRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit.forEach<List<Alert>>(
      _alertStreamController.asBroadcastStream(),
      onData: (alerts) {
        final alertView = {for (final al in alerts) al.id: al};
        // clone
        final deviceAlertView =
            Map<String, List<Alert>>.from(state.deviceAlertView);
        final alertConditionView =
            Map<String, List<Condition>>.from(state.alertConditionView);
        final alertActionView =
            Map<String, List<Action>>.from(state.alertActionView);
        // handle new alert
        final newAlerts = alerts
            .where((al) => !state.alertView.keys.contains(al.id))
            .toList();
        for (final al in newAlerts) {
          final deviceAlert = deviceAlertView[al.deviceID];
          if (deviceAlert != null) {
            deviceAlertView[al.deviceID] = [...deviceAlert, al];
          }
          alertConditionView[al.id] = [];
          alertActionView[al.id] = [];
        }
        // handle edited alerts
        final editedAlerts = alerts
            .where((att) =>
                state.alertView.containsKey(att.id) &&
                state.alertView[att.id] != alertView[att.id])
            .toList();
        for (final al in editedAlerts) {
          final oldAtt = state.alertView[al.id]!;
          final oldDeviceAlert = deviceAlertView[oldAtt.deviceID];
          if (oldDeviceAlert != null) {
            oldDeviceAlert.removeWhere((al) => al.id == oldAtt.id);
            deviceAlertView[oldAtt.deviceID] = oldDeviceAlert;
          }

          final deviceAlert = deviceAlertView[al.deviceID];
          if (deviceAlert != null) {
            deviceAlertView[al.deviceID] = [...deviceAlert, al];
          }
        }
        // handle delete alert
        final deletedAlerts = state.alerts
            .where((al) => !alertView.keys.contains(al.id))
            .toList();
        for (final al in deletedAlerts) {
          final deviceAlert = deviceAlertView[al.deviceID];
          if (deviceAlert != null) {
            deviceAlert.remove(al);
            deviceAlertView[al.deviceID] = deviceAlert;
          }
          alertConditionView.remove(al.id);
          alertActionView.remove(al.id);
        }
        return state.copyWith(
          alerts: alerts,
          deviceAlertView: deviceAlertView,
          alertConditionView: alertConditionView,
          alertActionView: alertActionView,
        );
      },
    );
  }

  Future<void> _onConditionSubscribed(
    ConditionSubscriptionRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit.forEach<List<Condition>>(
      _conditionStreamController.asBroadcastStream(),
      onData: (conditions) {
        final conditionView = {for (final al in conditions) al.id: al};
        // clone
        final alertConditionView =
            Map<String, List<Condition>>.from(state.alertConditionView);
        // handle new condition
        final newConditions = conditions
            .where((cd) => !state.conditionView.keys.contains(cd.id))
            .toList();
        for (final cd in newConditions) {
          final alertCondition = alertConditionView[cd.alertID];
          if (alertCondition != null) {
            alertConditionView[cd.alertID] = [...alertCondition, cd];
          }
        }
        // handle edited conditions
        final editedConditions = conditions
            .where((cd) =>
                state.conditionView.containsKey(cd.id) &&
                state.conditionView[cd.id] != conditionView[cd.id])
            .toList();
        for (final cd in editedConditions) {
          final oldCd = state.conditionView[cd.id]!;
          final oldAlertCondition = alertConditionView[oldCd.alertID];
          if (oldAlertCondition != null) {
            oldAlertCondition.removeWhere((cd) => cd.id == oldCd.id);
            alertConditionView[oldCd.alertID] = oldAlertCondition;
          }

          final alertCondition = alertConditionView[cd.alertID];
          if (alertCondition != null) {
            alertConditionView[cd.alertID] = [...alertCondition, cd];
          }
        }
        // handle delete condition
        final deletedConditions = state.conditions
            .where((cd) => !conditionView.keys.contains(cd.id))
            .toList();
        for (final cd in deletedConditions) {
          final alertCondition = alertConditionView[cd.alertID];
          if (alertCondition != null) {
            alertCondition.remove(cd);
            alertConditionView[cd.alertID] = alertCondition;
          }
        }
        return state.copyWith(
          conditions: conditions,
          alertConditionView: alertConditionView,
        );
      },
    );
  }

  Future<void> _onActionSubscribed(
    ActionSubscriptionRequested event,
    Emitter<CounterState> emit,
  ) async {
    await emit.forEach<List<Action>>(
      _actionStreamController.asBroadcastStream(),
      onData: (actions) {
        final actionView = {for (final ac in actions) ac.id: ac};
        // clone
        final alertActionView =
            Map<String, List<Action>>.from(state.alertActionView);
        // handle new action
        final newActions = actions
            .where((ac) => !state.actionView.keys.contains(ac.id))
            .toList();
        for (final ac in newActions) {
          final alertAction = alertActionView[ac.alertID];
          if (alertAction != null) {
            alertActionView[ac.alertID] = [...alertAction, ac];
          }
        }
        // handle edited actions
        final editedActions = actions
            .where((ac) =>
                state.actionView.containsKey(ac.id) &&
                state.actionView[ac.id] != actionView[ac.id])
            .toList();
        for (final ac in editedActions) {
          final oldAc = state.actionView[ac.id]!;
          final oldAlertAction = alertActionView[oldAc.alertID];
          if (oldAlertAction != null) {
            oldAlertAction.removeWhere((ac) => ac.id == oldAc.id);
            alertActionView[oldAc.alertID] = oldAlertAction;
          }

          final alertAction = alertActionView[ac.alertID];
          if (alertAction != null) {
            alertActionView[ac.alertID] = [...alertAction, ac];
          }
        }
        // handle delete action
        final deletedActions = state.actions
            .where((ac) => !actionView.keys.contains(ac.id))
            .toList();
        for (final ac in deletedActions) {
          final alertAction = alertActionView[ac.alertID];
          if (alertAction != null) {
            alertAction.remove(ac);
            alertActionView[ac.alertID] = alertAction;
          }
        }
        return state.copyWith(
          actions: actions,
          alertActionView: alertActionView,
        );
      },
    );
  }

  /// Gets a [Stream] of published msg from given [GatewayClient]
  Stream<Map<String, String>> getPublishMessage(GatewayClient client) {
    return client.getPublishMessage();
  }

  /// get value in json by expression
  String readJson({required String expression, required String payload}) {
    try {
      final decoded = jsonDecode(payload);
      final pointer = JsonPointer(expression);
      final value = pointer.read(decoded);
      if (value == null) {
        return '?';
      }
      switch (value.runtimeType) {
        case String:
          return value as String;
        default:
          return value.toString();
      }
    } catch (e) {
      return '?';
    }
  }

  /// write value to json by expression
  String writeJson({required String expression, required String value}) {
    try {
      final pointer = JsonPointer(expression);
      final payload = pointer.write({}, value);
      return jsonEncode(payload);
    } catch (e) {
      throw Exception();
    }
  }
}

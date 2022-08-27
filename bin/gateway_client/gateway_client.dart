import 'dart:convert';
import 'dart:developer';

import 'package:typed_data/typed_buffers.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

/// {@template gateway_client}
/// The gateway client model that handles MQTT related requests.
/// {@endtemplate}
class GatewayClient {
  /// {@macro gateway_client}
  GatewayClient({
    String? id,
    required this.schema,
    required this.brokerID,
    required this.url,
    required this.port,
    required this.account,
    required this.password,
    String? clientID,
  })  : assert(
          clientID == null || clientID.isNotEmpty,
          'clientID can not be null and should be empty',
        ),
        assert(
          id == null || id.isNotEmpty,
          'clientID can not be null and should be empty',
        ),
        id = id ?? const Uuid().v4(),
        _clientID = clientID ?? const Uuid().v4() {
    client = MqttServerClient.withPort(url, _clientID, port)
      ..clientIdentifier = clientID ?? ''
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onConnected = onConnected
      ..onDisconnected = onDisconnect
      ..onSubscribed = onSubscribe;

    if (account != null &&
        account!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty) {
      client.connectionMessage = MqttConnectMessage().startClean();
    } else {
      client.connectionMessage =
          MqttConnectMessage().withClientIdentifier(_clientID).startClean();
    }
  }

  ///
  final String schema;

  ///
  final String id;

  ///
  final String brokerID;

  ///
  final String url;

  ///
  final int port;

  ///
  final String? account;

  ///
  final String? password;

  /// The id of client
  final String _clientID;

  /// The Mqtt client instance
  late MqttServerClient client;

  /// Connects to the broker
  Future<void> connect() async {
    if (account != null &&
        account!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty) {
      await client.connect(account, password);
    } else {
      await client.connect();
    }
  }

  /// Disconnects to broker
  void disconnect() {
    final status = client.connectionStatus;
    if (status != null && status.state == MqttConnectionState.connected) {
      try {
        client.disconnect();
      } catch (e) {
        print(e);
      }
    }
  }

  /// Subscribes to given topic
  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    // because adafruit not have retain msg system
    // so we must publish topic/get to get retain msg
    if (url == 'io.adafruit.com') {
      published(payload: '', topic: '$topic/get', retain: false);
    }
  }

  /// Unsubscribes to given topic
  void unsubscribe(String topic) {
    client.unsubscribe(topic);
  }

  /// Publishes message to given topic
  void published({
    required String payload,
    required String topic,
    required bool retain,
  }) {
    final encoded = Uint8Buffer()..addAll(utf8.encode(payload));
    client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      encoded,
      retain: retain,
    );
  }

  /// Get a stream of published messages of given topics
  Stream<Map<String, String>> getPublishMessage() {
    return client.published!.map((MqttPublishMessage message) {
      final topic = message.variableHeader!.topicName;
      final payload = utf8.decode(message.payload.message.toList());
      return {
        'schema': schema,
        'broker_id': brokerID,
        'topic': topic,
        'payload': payload,
      };
    });
  }

  /// Connection callback
  void onConnected() {
    log('::MQTT_CLIENT:: $url:$port Ket noi thanh cong...');
  }

  /// Subscribe callback
  void onSubscribe(dynamic whatever) {
    log(
      '::MQTT_CLIENT:: $url:$port'
      ' Subscribe thanh cong... $whatever',
    );
  }

  /// Disconnect callback
  void onDisconnect() {
    log('::MQTT_CLIENT::  $url:$port Ngat ket noi...');
  }
}

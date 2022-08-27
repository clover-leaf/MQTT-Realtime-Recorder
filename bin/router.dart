import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import 'bloc/counter_bloc.dart';
import 'fcm_client.dart';
import 'model/model.dart';

class TRouter {
  Handler get router {
    final oneSignKey = 'NTNmZDBhNGEtYmIzOC00MTQ3LTkyZTctYzI1YTZlMzA4NmQ0';
    final fcmClient =
        FcmClient(httpClient: http.Client(), oneSignKey: oneSignKey);
    final bloc = CounterBloc(fcmClient);
    bloc.add(InitializationRequested());

    final router = Router();

    router.get('/', (Request request) {
      return Response.ok('Hello, World!\n');
    });

    // notify new schema
    router.post('/schema', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final schema = payload['schema'];
      bloc.add(SchemaAdded(schema));
      return Response.ok('OK');
    });

    // notify deleted schema
    router.delete('/schema/<schema>', (Request request, String schema) async {
      bloc.add(SchemaDeleted(schema));
      return Response.ok('OK');
    });

    // notify new broker
    router.post('/broker', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final schema = payload['schema'];
      final id = payload['id'];
      final projectID = payload['project_id'];
      final name = payload['name'];
      final url = payload['url'];
      final port = payload['port'];
      final account = payload['account'];
      final password = payload['password'];
      final broker = Broker(
          schema: schema,
          id: id,
          projectID: projectID,
          name: name,
          url: url,
          port: port,
          account: account,
          password: password);
      bloc.add(BrokerAdded(broker));
      return Response.ok('OK');
    });

    // notify updated broker
    router.put('/broker', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final schema = payload['schema'];
      final id = payload['id'];
      final projectID = payload['project_id'];
      final name = payload['name'];
      final url = payload['url'];
      final port = payload['port'];
      final account = payload['account'];
      final password = payload['password'];
      final broker = Broker(
          schema: schema,
          id: id,
          projectID: projectID,
          name: name,
          url: url,
          port: port,
          account: account,
          password: password);
      bloc.add(BrokerEdited(broker));
      return Response.ok('OK');
    });

    // notify deleted broker
    router.delete('/broker/<broker_id>',
        (Request request, String brokerID) async {
      bloc.add(BrokerDeleted(brokerID));
      return Response.ok('OK');
    });

    // notify new device
    router.post('/device', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final groupID = payload['group_id'];
      final brokerID = payload['broker_id'];
      final name = payload['name'];
      final topic = payload['topic'];
      final device = Device(
        id: id,
        groupID: groupID,
        brokerID: brokerID,
        name: name,
        topic: topic,
      );
      bloc.add(DeviceAdded(device));
      return Response.ok('OK');
    });

    // notify updated device
    router.put('/device', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final groupID = payload['group_id'];
      final brokerID = payload['broker_id'];
      final name = payload['name'];
      final topic = payload['topic'];
      final device = Device(
        id: id,
        groupID: groupID,
        brokerID: brokerID,
        name: name,
        topic: topic,
      );
      bloc.add(DeviceEdited(device));
      return Response.ok('OK');
    });

    // notify deleted device
    router.delete('/device/<device_id>',
        (Request request, String deviceID) async {
      bloc.add(DeviceDeleted(deviceID));
      return Response.ok('OK');
    });

    // notify new attribute
    router.post('/attribute', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final deviceID = payload['device_id'];
      final name = payload['name'];
      final jsonPath = payload['json_path'];
      final unit = payload['unit'];
      final attribute = Attribute(
        id: id,
        deviceID: deviceID,
        name: name,
        jsonPath: jsonPath,
        unit: unit,
      );
      bloc.add(AttributeAdded(attribute));
      return Response.ok('OK');
    });

    // notify updated attribute
    router.put('/attribute', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final deviceID = payload['device_id'];
      final name = payload['name'];
      final jsonPath = payload['json_path'];
      final unit = payload['unit'];
      final attribute = Attribute(
        id: id,
        deviceID: deviceID,
        name: name,
        jsonPath: jsonPath,
        unit: unit,
      );
      bloc.add(AttributeEdited(attribute));
      return Response.ok('OK');
    });

    // notify deleted attribute
    router.delete('/attribute/<attribute_id>',
        (Request request, String attributeID) async {
      bloc.add(AttributeDeleted(attributeID));
      return Response.ok('OK');
    });

    // notify new alert
    router.post('/alert', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final deviceID = payload['device_id'];
      final name = payload['name'];
      final alert = Alert(id: id, deviceID: deviceID, name: name);
      bloc.add(AlertAdded(alert));
      return Response.ok('OK');
    });

    // notify updated alert
    router.put('/alert', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final deviceID = payload['device_id'];
      final name = payload['name'];
      final alert = Alert(id: id, deviceID: deviceID, name: name);
      bloc.add(AlertEdited(alert));
      return Response.ok('OK');
    });

    // notify deleted alert
    router.delete('/alert/<alert_id>', (Request request, String alertID) async {
      bloc.add(AlertDeleted(alertID));
      return Response.ok('OK');
    });

    // notify new condition
    router.post('/condition', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final alertID = payload['alert_id'];
      final attributeID = payload['attribute_id'];
      final comparison = payload['comparison'];
      final value = payload['value'];
      final condition = Condition(
          id: id,
          alertID: alertID,
          attributeID: attributeID,
          comparison: comparison,
          value: value);
      bloc.add(ConditionAdded(condition));
      return Response.ok('OK');
    });

    // notify updated condition
    router.put('/condition', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final alertID = payload['alert_id'];
      final attributeID = payload['attribute_id'];
      final comparison = payload['comparison'];
      final value = payload['value'];
      final condition = Condition(
          id: id,
          alertID: alertID,
          attributeID: attributeID,
          comparison: comparison,
          value: value);
      bloc.add(ConditionEdited(condition));
      return Response.ok('OK');
    });

    // notify deleted condition
    router.delete('/condition/<condition_id>',
        (Request request, String conditionID) async {
      bloc.add(ConditionDeleted(conditionID));
      return Response.ok('OK');
    });

    // notify new action
    router.post('/action', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final alertID = payload['alert_id'];
      final deviceID = payload['device_id'];
      final attributeID = payload['attribute_id'];
      final value = payload['value'];
      final action = Action(
        id: id,
        alertID: alertID,
        deviceID: deviceID,
        attributeID: attributeID,
        value: value,
      );
      bloc.add(ActionAdded(action));
      return Response.ok('OK');
    });

    // notify updated action
    router.put('/action', (Request request) async {
      final payload =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = payload['id'];
      final alertID = payload['alert_id'];
      final deviceID = payload['device_id'];
      final attributeID = payload['attribute_id'];
      final value = payload['value'];
      final action = Action(
        id: id,
        alertID: alertID,
        deviceID: deviceID,
        attributeID: attributeID,
        value: value,
      );
      bloc.add(ActionEdited(action));
      return Response.ok('OK');
    });

    // notify deleted action
    router.delete('/action/<action_id>',
        (Request request, String actionID) async {
      bloc.add(ActionDeleted(actionID));
      return Response.ok('OK');
    });
    return router;
  }
}

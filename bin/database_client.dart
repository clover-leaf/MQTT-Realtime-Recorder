// ignore_for_file: constant_identifier_names
import 'package:supabase/supabase.dart';

const SUPABASE_URL = 'https://mwwncvkpflyreaofpapd.supabase.co';
const SECRET_ROLE =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS'
    'IsInJlZiI6Im13d25jdmtwZmx5cmVhb2ZwYXBkIiwicm9sZSI6InNlcnZpY2V'
    'fcm9sZSIsImlhdCI6MTY1OTE3NjQ3MywiZXhwIjoxOTc0NzUyNDczfQ.'
    'rmqW5s0jSY_1f4NPdIdnuBW9pR1nEJRcMdJWqgB7Ekc';

class DatabaseClient {
  DatabaseClient(this.schema)
      : client = SupabaseClient(SUPABASE_URL, SECRET_ROLE, schema: schema);

  final SupabaseClient client;
  final String schema;

  Future<List<Map<String, dynamic>>> getAllBroker() async {
    final res = await client.from('broker').select().execute();
    if (res.hasError) return [];
    final brokers = res.data as List<dynamic>;
    // add schema to broker json
    final refineBrokers = brokers.map((json) {
      final fJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
      fJson['schema'] = schema;
      return fJson;
    }).toList();
    return refineBrokers;
  }

  Future<List<dynamic>> getAllDevice() async {
    final res = await client.from('device').select().execute();
    if (res.hasError) return [];
    return res.data;
  }

  Future<List<dynamic>> getAllAttribute() async {
    final res = await client.from('attribute').select().execute();
    if (res.hasError) return [];
    return res.data;
  }

  Future<List<dynamic>> getAllAlert() async {
    final res = await client.from('alert').select().execute();
    if (res.hasError) return [];
    return res.data;
  }

  Future<List<dynamic>> getAllCondition() async {
    final res = await client.from('condition').select().execute();
    if (res.hasError) return [];
    return res.data;
  }

  Future<List<dynamic>> getAllAction() async {
    final res = await client.from('action').select().execute();
    if (res.hasError) return [];
    return res.data;
  }
}

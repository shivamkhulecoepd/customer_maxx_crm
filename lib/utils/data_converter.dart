import 'dart:convert';
import 'dart:developer';
import 'package:customer_maxx_crm/screens/dummy_data_example.dart';

/// Utility class for converting JSON data to DummyLead objects
class DataConverter {
  /// Convert a JSON string to a list of DummyLead objects
  static List<DummyLead> jsonToDummyLeads(String jsonString) {
    try {
      final dynamic jsonData = json.decode(jsonString);
      
      // Check if the response has the expected structure
      if (jsonData is Map<String, dynamic> && 
          jsonData['status'] == 'success' && 
          jsonData.containsKey('leads')) {
        final List<dynamic> leadsData = jsonData['leads'] as List<dynamic>;
        return leadsData
            .map((leadJson) => DummyLead.fromJson(leadJson as Map<String, dynamic>))
            .toList();
      } else {
        // If it's just an array of leads
        if (jsonData is List) {
          return jsonData
              .map((leadJson) => DummyLead.fromJson(leadJson as Map<String, dynamic>))
              .toList();
        }
        // If it's a single lead object
        else if (jsonData is Map<String, dynamic>) {
          return [DummyLead.fromJson(jsonData)];
        }
      }
    } catch (e) {
      // Print error for debugging
      // ignore: avoid_print
      log('Error parsing JSON data: $e');
      // Return empty list if parsing fails
      return [];
    }
    
    // Return empty list if structure doesn't match
    return [];
  }
  
  /// Convert a list of maps to DummyLead objects
  static List<DummyLead> mapListToDummyLeads(List<Map<String, dynamic>> mapList) {
    try {
      return mapList
          .map((leadMap) => DummyLead.fromJson(leadMap))
          .toList();
    } catch (e) {
      // Print error for debugging
      // ignore: avoid_print
      log('Error converting map list to DummyLeads: $e');
      // Return empty list if conversion fails
      return [];
    }
  }
}
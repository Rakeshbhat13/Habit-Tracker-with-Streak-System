import 'package:hive_flutter/hive_flutter.dart';

class DbInitService {
  static Future<void> init() async {
    try {
      print('DEBUG: Initializing Hive...');
      await Hive.initFlutter();
      
      print('DEBUG: Opening Hive box: habits');
      await Hive.openBox('habits');
      
      print('DEBUG: Opening Hive box: badges');
      await Hive.openBox('badges');
      
      print('DEBUG: Hive initialized and boxes opened successfully.');
    } catch (e) {
      print('ERROR: Failed to initialize Hive: $e');
    }
  }
}

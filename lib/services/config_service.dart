import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class ConfigService {
  static ConfigService get to => Get.find<ConfigService>();
  String? apiBaseUrl;
  String? apiKey;

  Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    apiBaseUrl = dotenv.env['API_BASE_URL'];
    apiKey = dotenv.env['API_KEY'];
    if (apiBaseUrl == null || apiKey == null) {
      throw Exception('API_BASE_URL or API_KEY not found in .env file');
    }
  }
}

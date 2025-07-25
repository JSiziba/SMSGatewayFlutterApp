import 'package:get/get.dart';
import 'package:smsgateway/repositories/sms_messages_repository.dart';
import 'package:smsgateway/services/api_service.dart';
import 'package:smsgateway/services/config_service.dart';
import 'package:smsgateway/services/sms_service.dart';
import 'package:smsgateway/services/web_socket_service.dart';
import 'package:smsgateway/state/app_state_controller.dart';

Future<void> setupServiceLocator() async {
  final conFigService = Get.put<ConfigService>(ConfigService());
  await conFigService.initialize();
  final smsMessagesRepository =
      Get.put<SMSMessagesRepository>(SMSMessagesRepository());
  final appState = Get.put<AppStateController>(AppStateController());
  final smsService = Get.put<SMSService>(SMSService());
  await smsService.initialize();
  final webSocketService = Get.put<WebSocketService>(WebSocketService());
  final apiService = Get.put<ApiService>(ApiService());
}

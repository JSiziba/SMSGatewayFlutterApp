import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smsgateway/custom_colors.dart';
import 'package:smsgateway/service_locator.dart';
import 'package:smsgateway/services/sms_service.dart';
import 'package:smsgateway/sms_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SMS Gateway',
      onInit: () {
        SMSService.to.initialize();
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.lightPurple,
        ),
      ),
      home: const SMSGateway(),
    );
  }
}

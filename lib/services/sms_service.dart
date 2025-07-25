import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smsgateway/custom_colors.dart';
import 'package:smsgateway/models/sms_message.dart';
import 'package:smsgateway/state/app_state_controller.dart';

class SMSService {
  static SMSService get to => Get.find<SMSService>();
  static const platform = MethodChannel('com.fibonara.sms');
  bool _hasPermission = false;
  AppStateController appStateController = AppStateController.to;

  Future<void> initialize() async {
    await checkPermission();
  }

  void smsReceived(SMSMessage sms) {
    appStateController.addSMSMessage(sms);
    Future.delayed(Duration(milliseconds: 500), () {
      sendSMS(sms);
    });
  }

  Future<bool> hasPermission() async {
    try {
      return await platform.invokeMethod('hasPermission');
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  Future<void> checkPermission() async {
    try {
      _hasPermission = await hasPermission();
      if (!_hasPermission) {
        await Get.defaultDialog(
          title: 'SMS Permission Required',
          middleText: 'This app needs permission to send SMS messages.',
          textConfirm: 'Allow',
          textCancel: 'Cancel',
          confirmTextColor: Colors.white,
          titlePadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          buttonColor: CustomColors.lightPurple,
          onConfirm: () async {
            Get.back();
            await requestPermission();
          },
          onCancel: () {
            Get.back();
            Future.delayed(Duration(milliseconds: 300), () {
              Get.snackbar(
                'Permission Denied',
                'SMS functionality will not work without permission. Please enable it in settings.',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 3),
                backgroundColor: Colors.red.withOpacity(0.8),
                colorText: Colors.white,
                margin: EdgeInsets.all(10),
                borderRadius: 10,
              );
            });
          },
        );
      }
    } catch (e) {
      debugPrint('Error checking or requesting permission: $e');
      Get.snackbar(
        'Permission Error',
        'Unable to check or request SMS permission',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> requestPermission() async {
    try {
      await platform.invokeMethod('requestPermission');
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }

  Future<bool> sendSMS(SMSMessage sms) async {
    try {
      bool sent = await platform.invokeMethod('sendSMS', {
        'phoneNumber': sms.phoneNumber,
        'message': sms.message,
      });
      debugPrint('SMS sent: $sent');
      if (sent) {
        appStateController.updateSMSDeliveryStatus(
          sms.id,
          DeliveryStatus.sent,
        );
      } else {
        appStateController.updateSMSDeliveryStatus(
          sms.id,
          DeliveryStatus.failed,
        );
      }
      return sent;
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      appStateController.updateSMSDeliveryStatus(
        sms.id,
        DeliveryStatus.failed,
      );
      return false;
    }
  }
}

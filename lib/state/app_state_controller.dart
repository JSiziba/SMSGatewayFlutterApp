import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smsgateway/models/sms_message.dart';
import 'package:smsgateway/repositories/sms_messages_repository.dart';

class AppStateController extends GetxController {
  static AppStateController get to => Get.find<AppStateController>();
  final SMSMessagesRepository repository = SMSMessagesRepository.to;
  final _isLoading = false.obs;
  final _serverError = ''.obs;
  final _isConnected = false.obs;
  final _isConnecting = false.obs;
  final _isSendingSMS = false.obs;

  final _smsSes = <SMSMessage>[].obs;

  List<SMSMessage> get smsSes => _smsSes.toList();

  List<SMSMessage> get failedSMSses => _smsSes
      .where((msg) => msg.deliveryStatus == DeliveryStatus.failed)
      .toList();

  // constructor
  AppStateController() {
    initialize();
  }

  bool get isConnectedValue => _isConnected.value;

  bool get isConnectingValue => _isConnecting.value;

  bool get isSendingSMSValue => _isSendingSMS.value;

  bool get isLoadingValue => _isLoading.value;

  set isLoading(bool loading) {
    _isLoading.value = loading;
  }

  set isConnected(bool connected) {
    _isConnected.value = connected;
  }

  set isConnecting(bool connecting) {
    _isConnecting.value = connecting;
  }

  set isSendingSMS(bool sending) {
    _isSendingSMS.value = sending;
  }

  set serverError(String error) {
    _serverError.value = error;
  }

  set smsSes(List<SMSMessage> messages) {
    _smsSes.value = messages;
  }

  void initialize() {
    repository.init().then((_) {
      repository.readAll().then((messages) {
        _smsSes.value = messages;
      }).catchError((error) {
        debugPrint('Error loading SMS messages: $error');
        Get.snackbar(
          'Error',
          'Failed to load SMS messages: $error',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.8),
        );
      });
    }).catchError((error) {
      debugPrint('Error initializing repository: $error');
    });
  }

  void addSMSMessage(SMSMessage message) {
    repository.create(message).then((_) {
      _smsSes.insert(0, message);
    }).catchError((error) {
      debugPrint('Error saving SMS message: $error');
      Get.snackbar(
        'Error',
        'Failed to save SMS message: $error',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.8),
      );
    });
  }

  void updateSMSById(String id, SMSMessage updatedMessage) {
    repository.update(updatedMessage).then((_) {
      final index = _smsSes.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _smsSes[index] = updatedMessage;
      }
    }).catchError((error) {
      debugPrint('Error updating SMS message: $error');
      Get.snackbar(
        'Error',
        'Failed to update SMS message: $error',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    });
  }

  void updateSMSDeliveryStatus(String id, DeliveryStatus status) {
    final index = _smsSes.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      final updatedMessage = _smsSes[index];
      updateSMSById(id, updatedMessage);
    }
  }
}

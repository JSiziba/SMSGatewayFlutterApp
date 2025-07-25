import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../models/sms_message.dart';

class SMSMessagesRepository {
  static SMSMessagesRepository get to => Get.find<SMSMessagesRepository>();
  static const String _fileName = 'sms_messages.json';
  late String _filePath;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/$_fileName';
    final file = File(_filePath);
    if (!await file.exists()) {
      await file.writeAsString('[]');
    }
  }

  Future<void> create(SMSMessage message) async {
    final messages = await _readAllMessages();
    messages.insert(0, message);
    await _writeAllMessages(messages);
  }

  Future<List<SMSMessage>> readAll() async {
    return await _readAllMessages();
  }

  Future<SMSMessage?> readById(String id) async {
    final messages = await _readAllMessages();
    try {
      return messages.firstWhere((msg) => msg.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> update(SMSMessage updatedMessage) async {
    final messages = await _readAllMessages();
    final index = messages.indexWhere((msg) => msg.id == updatedMessage.id);

    if (index != -1) {
      messages[index] = updatedMessage;
      await _writeAllMessages(messages);
      return true;
    }
    return false;
  }

  Future<bool> delete(String id) async {
    final messages = await _readAllMessages();
    final initialLength = messages.length;
    messages.removeWhere((msg) => msg.id == id);

    if (messages.length < initialLength) {
      await _writeAllMessages(messages);
      return true;
    }
    return false;
  }

  Future<void> deleteAll() async {
    await _writeAllMessages([]);
  }

  Future<List<SMSMessage>> _readAllMessages() async {
    try {
      final file = File(_filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList
          .map((json) => SMSMessage.fromJson(jsonEncode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writeAllMessages(List<SMSMessage> messages) async {
    final file = File(_filePath);
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}

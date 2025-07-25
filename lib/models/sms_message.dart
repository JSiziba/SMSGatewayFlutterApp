import 'dart:convert';

enum DeliveryStatus {
  pending,
  sent,
  failed,
}

enum SMSType {
  otp,
  notification,
  promotional,
  other,
}

class SMSMessage {
  String id;
  String phoneNumber;
  String message;
  DateTime createdAt;
  DeliveryStatus deliveryStatus = DeliveryStatus.pending;
  SMSType type;

  SMSMessage({
    required this.id,
    required this.phoneNumber,
    required this.message,
    required this.createdAt,
    required this.type,
  });

  factory SMSMessage.fromJson(String message) {
    var json = jsonDecode(message) as Map<String, dynamic>;
    return SMSMessage(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: SMSType.values.firstWhere(
        (e) => e.toString().split('.').last == json['smsType'],
        orElse: () => SMSType.other,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'deliveryStatus': deliveryStatus.toString().split('.').last,
      'type': type.toString().split('.').last,
    };
  }
}

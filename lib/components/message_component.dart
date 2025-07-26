import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smsgateway/custom_colors.dart';
import 'package:smsgateway/models/sms_message.dart';

class MessageComponent extends StatelessWidget {
  final SMSMessage message;

  const MessageComponent({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CustomColors.borderGrey,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            spacing: 10,
            children: [
              getMessageTypeIcon(),
              Text(
                message.phoneNumber,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.headlineGrey,
                ),
              ),
            ],
          ),
          Text(
            message.message,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CustomColors.headlineGrey,
            ),
          ),
          SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              getMessageStatusIcon(),
              Spacer(),
              Text(
                getTimeAgo(message.createdAt),
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CustomColors.lightGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getTimeAgo(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    final formattedTime =
        '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday, $formattedTime';
      } else {
        if (localDateTime.year != now.year) {
          return '${localDateTime.day} ${getMonthName(localDateTime.month)}, ${localDateTime.year}, $formattedTime';
        }
        return '${localDateTime.day} ${getMonthName(localDateTime.month)}, $formattedTime';
      }
    }
    return formattedTime;
  }

  getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget getMessageStatusIcon() {
    if (message.deliveryStatus == DeliveryStatus.pending) {
      return Icon(
        size: 18,
        color: CustomColors.lightGrey,
        Icons.done_rounded,
      );
    }
    if (message.deliveryStatus == DeliveryStatus.sent) {
      return Icon(
        size: 18,
        color: CustomColors.statusBlue,
        Icons.done_all_rounded,
      );
    }
    return Icon(
      size: 18,
      color: CustomColors.errorRed,
      Icons.error_outline_rounded,
    );
  }

  Widget getMessageTypeIcon() {
    if (message.smsType == SMSType.otp) {
      return Icon(
        size: 18,
        color: CustomColors.otpColor,
        Icons.key_rounded,
      );
    }
    if (message.smsType == SMSType.notification) {
      return Icon(
        size: 18,
        color: CustomColors.notificationColor,
        Icons.notifications,
      );
    }
    if (message.smsType == SMSType.promotional) {
      return Icon(
        size: 18,
        color: CustomColors.promotionColor,
        Icons.campaign,
      );
    }
    return Icon(
      size: 18,
      color: CustomColors.generalMessageColor,
      Icons.mail,
    );
  }
}

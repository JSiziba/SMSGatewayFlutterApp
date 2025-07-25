import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smsgateway/components/custom_button.dart';
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
              if (message.deliveryStatus == DeliveryStatus.failed)
                CustomButton(
                  onTap: () {},
                  title: "Resend",
                ),
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        if (dateTime.year != now.year) {
          return '${dateTime.day} ${getMonthName(dateTime.month)}, ${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
        }
        return '${dateTime.day} ${getMonthName(dateTime.month)}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    }
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
    if (message.type == SMSType.otp) {
      return Icon(
        size: 18,
        color: CustomColors.otpColor,
        Icons.key_rounded,
      );
    }
    if (message.type == SMSType.notification) {
      return Icon(
        size: 18,
        color: CustomColors.notificationColor,
        Icons.notifications,
      );
    }
    if (message.type == SMSType.promotional) {
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

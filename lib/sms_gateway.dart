import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smsgateway/components/custom_button.dart';
import 'package:smsgateway/custom_colors.dart';
import 'package:smsgateway/models/sms_message.dart';
import 'package:smsgateway/services/web_socket_service.dart';
import 'package:smsgateway/state/app_state_controller.dart';

import 'components/message_component.dart';

class SMSGateway extends StatefulWidget {
  const SMSGateway({super.key});

  @override
  State<SMSGateway> createState() => _SMSGatewayState();
}

class _SMSGatewayState extends State<SMSGateway> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'All Messages',
    'Failed Messages',
  ];
  AppStateController appState = AppStateController.to;
  WebSocketService webSocketService = WebSocketService.to;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                for (int i = 0; i < _tabs.length; i++) buildTab(size, i),
              ],
            ),
            Obx(() {
              List<SMSMessage> messages = appState.smsSes;
              List<SMSMessage> failedMessages = appState.failedSMSses;
              if (_selectedTabIndex == 0) {
                return buildMessagesSection(messages);
              } else {
                return buildMessagesSection(failedMessages);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget buildMessagesSection(List<SMSMessage> messages) {
    if (messages.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 15,
            children: [
              Icon(
                Icons.content_paste_search_outlined,
                size: 85,
                color: CustomColors.lightGrey,
              ),
              Text(
                'Nothing to show here',
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.lightGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return MessageComponent(
            message: messages[index],
            key: ValueKey(messages[index].id),
          );
        },
      ),
    );
  }

  Widget buildTab(Size size, int index) {
    var isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      radius: 10,
      child: Container(
        width: size.width * 0.5,
        padding: EdgeInsets.only(
          left: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? CustomColors.lightPurple
                  : CustomColors.borderGrey,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
        ),
        child: Text(
          _tabs[index],
          style: GoogleFonts.raleway(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? CustomColors.lightPurple
                : CustomColors.headlineGrey,
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: CustomColors.headerGrey,
      elevation: 0,
      title: Text(
        'SMS Gateway',
        style: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: CustomColors.primaryPurple,
        ),
      ),
      centerTitle: false,
      actions: [
        Obx(() {
          if (appState.isConnectedValue) {
            return buildIsOnlineIndicator();
          } else {
            return CustomButton(
              onTap: triggerConnection,
              title: 'Connect',
              isLoading: appState.isConnectingValue,
            );
          }
        }),
        SizedBox(
          width: 18,
        ),
      ],
    );
  }

  void triggerConnection() {
    webSocketService.connectAndSubscribe();
  }

  Row buildIsOnlineIndicator() {
    return Row(
      spacing: 10,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: CustomColors.successGreen,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          'Online',
          style: GoogleFonts.raleway(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: CustomColors.headlineGrey,
          ),
        ),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }
}

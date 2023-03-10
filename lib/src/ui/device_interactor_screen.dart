import 'dart:core';
import 'dart:convert';

import 'package:blestream/src/ui/device_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:blestream/src/ble/ble_device_interactor.dart';

class DeviceInteractorScreen extends StatelessWidget {
  final String deviceId;
  const DeviceInteractorScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Center(
        child: Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, connectionStateUpdate, deviceInteractor, __) {
            if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              return DeviceInteractor(
                deviceId: deviceId,
                deviceInteractor: deviceInteractor,
              );
            } else if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connecting) {
              return PlatformText('connecting');
            } else {
              return PlatformText('error');
            }
          },
        ),
      ),
    );
  }
}

class DeviceInteractor extends StatefulWidget {
  final BleDeviceInteractor deviceInteractor;

  final String deviceId;
  const DeviceInteractor(
      {Key? key, required this.deviceInteractor, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceInteractor> createState() => _DeviceInteractorState();
}

class _DeviceInteractorState extends State<DeviceInteractor> {
  final Uuid _nordicUartServiceUuid = uartUuid;
  final Uuid _nordicUartTxUuid = uartTx;
  final Uuid _nordicUartRxUuid = uartRx;

  Stream<List<int>>? subscriptionStream;

  // tried removing async and await but the receiver subscription
  //  still misses the first packet
  sendCommand(cmd) async {
    await widget.deviceInteractor.writeCharacteristicWithoutResponse(
        QualifiedCharacteristic(
            characteristicId: _nordicUartRxUuid,
            serviceId: _nordicUartServiceUuid,
            deviceId: widget.deviceId),
        ascii.encode(cmd));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PlatformText('connected'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlatformTextButton(
              onPressed: subscriptionStream != null
                  ? null
                  : () async {
                      setState(
                        () {
                          subscriptionStream =
                              widget.deviceInteractor.subScribeToCharacteristic(
                            QualifiedCharacteristic(
                                characteristicId: _nordicUartTxUuid,
                                serviceId: _nordicUartServiceUuid,
                                deviceId: widget.deviceId),
                          );
                        },
                      );
                    },
              child: PlatformText('subscribe'),
            ),
            const SizedBox(
              width: 20,
            ),
            PlatformTextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: PlatformText('disconnect'),
            ),
            const SizedBox(
              width: 20,
            ),
            PlatformTextButton(
              onPressed: () {
                sendCommand("L");
              },
              child: PlatformText('list'),
            ),
          ],
        ),
        subscriptionStream != null
            ? StreamBuilder<List<int>>(
                stream: subscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    debugPrint(ascii.decode(snapshot.data!));
                    return PlatformText(snapshot.data.toString());
                  }
                  return PlatformText('No data yet');
                },
              )
            : PlatformText('Stream not initalized')
      ],
    );
  }
}

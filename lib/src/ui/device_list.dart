import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:blestream/src/ble/ble_device_connector.dart';
import 'package:blestream/src/ble/ble_scanner.dart';
import 'package:blestream/src/ui/device_interactor_screen.dart';

// This app uses BLE devices which advertise a Nordic UART Service (NUS) UUID
// Note: the name of the characteristic is defined from the point of view of the
//  peripheral, so uartTX would be RX to us, the central.
Uuid uartUuid = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid uartRx = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
Uuid uartTx = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, bleDeviceConnector, __) =>
            _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: bleDeviceConnector,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
  });

  final BleDeviceConnector deviceConnector;
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  @override
  __DeviceListState createState() => __DeviceListState();
}

class __DeviceListState extends State<_DeviceList> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => ListTile(
                        title: PlatformText(device.name),
                        subtitle:
                            PlatformText("${device.id}\nRSSI: ${device.rssi}"),
                        leading: const Icon(Icons.bluetooth),
                        onTap: () async {
                          widget.stopScan();
                          widget.deviceConnector.connect(device.id);
                          await Navigator.push(
                            context,
                            platformPageRoute(
                              builder: (context) =>
                                  DeviceInteractorScreen(deviceId: device.id),
                              context: context,
                            ),
                          );
                          widget.deviceConnector.disconnect(device.id);
                          widget.startScan([uartUuid]);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PlatformTextButton(
                    child: PlatformText('Scan'),
                    onPressed: !widget.scannerState.scanIsInProgress
                        ? () => widget.startScan([uartUuid])
                        : null),
                PlatformTextButton(
                  child: PlatformText('Stop'),
                  onPressed: widget.scannerState.scanIsInProgress
                      ? widget.stopScan
                      : null,
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}

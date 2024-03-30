import 'dart:convert';
import 'dart:typed_data';
import 'package:demo_nfc_wallet/apdu_response.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String tagContent = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('NfcManager Plugin Example')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    direction: Axis.vertical,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.expand(),
                          decoration: BoxDecoration(border: Border.all()),
                          child: SingleChildScrollView(
                            child: ValueListenableBuilder<dynamic>(
                              valueListenable: result,
                              builder: (context, value, _) =>
                                  Text('${value ?? ''}'),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: GridView.count(
                          padding: const EdgeInsets.all(4),
                          crossAxisCount: 2,
                          childAspectRatio: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: [
                            ElevatedButton(
                              onPressed: _tagRead,
                              child: const Text('Tag Read'),
                            ),
                            ElevatedButton(
                              onPressed: _ndefWrite,
                              child: const Text('Ndef Write'),
                            ),
                            ElevatedButton(
                              onPressed: _ndefWriteLock,
                              child: const Text('Ndef Write Lock'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _tagRead() {
    final Uint8List mJpnaid = Uint8List.fromList(
        [0xA0, 0x00, 0x00, 0x00, 0x74, 0x4A, 0x50, 0x4E, 0x00, 0x10]);
    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        try {
          Map<String, dynamic> tagData = tag.data;
          result.value = tagData;
          tagContent = tagData.toString();

          print(tagData);

         List<int> command = [0xA0, 0x00, 0x00, 0x00, 0x74, 0x4A, 0x50, 0x4E, 0x00, 0x10];
        List<int> response = await tag(command);
        // Handle the response from the NFC tag
        print('Response from NFC tag: $response');

          // List<int> apduResponse = await tag.transceive(mJpnaid);
          //   // Handle the APDU response
          //   print('APDU Response: $apduResponse');

          // decodeNfcTagInfo(tag.data);
        } catch (e) {
          result.value = 'Error reading tag: $e';
        } finally {
          NfcManager.instance.stopSession();
        }
      });
    } catch (e) {
      // Handle any errors that occur when starting the NFC session
      result.value = 'Error starting session: $e';
    }
  }

  // void decodeNfcTagInfo(Map<String, dynamic> tagData) {
  //   print(tagData);
  //   if (tagData.containsKey('nfca') &&
  //       tagData['nfca'] is Map<String, dynamic>) {
  //     Map<String, dynamic> nfcaData = tagData['nfca'] as Map<String, dynamic>;
  //     List<int> identifier =
  //         (nfcaData['identifier'] as List<dynamic>).cast<int>();
  //     List<int> atqa = (nfcaData['atqa'] as List<dynamic>).cast<int>();
  //     int maxTransceiveLength = nfcaData['maxTransceiveLength'] as int;
  //     int sak = nfcaData['sak'] as int;
  //     int timeout = nfcaData['timeout'] as int;

  //     // Decode NFC-A specific data
  //     print('NFC-A Identifier: $identifier');
  //     print('NFC-A ATQA: $atqa');
  //     print('NFC-A Max Transceive Length: $maxTransceiveLength');
  //     print('NFC-A SAK: $sak');
  //     print('NFC-A Timeout: $timeout');
  //   }

  //   if (tagData.containsKey('mifareclassic') &&
  //       tagData['mifareclassic'] is Map<String, dynamic>) {
  //     Map<String, dynamic> mifareClassicData =
  //         tagData['mifareclassic'] as Map<String, dynamic>;
  //     List<int> identifier =
  //         (mifareClassicData['identifier'] as List<dynamic>).cast<int>();
  //     int blockCount = mifareClassicData['blockCount'] as int;
  //     int maxTransceiveLength = mifareClassicData['maxTransceiveLength'] as int;
  //     int sectorCount = mifareClassicData['sectorCount'] as int;
  //     int size = mifareClassicData['size'] as int;
  //     int timeout = mifareClassicData['timeout'] as int;
  //     int type = mifareClassicData['type'] as int;

  //     // Decode MIFARE Classic specific data
  //     print('MIFARE Classic Identifier: $identifier');
  //     print('MIFARE Classic Block Count: $blockCount');
  //     print('MIFARE Classic Max Transceive Length: $maxTransceiveLength');
  //     print('MIFARE Classic Sector Count: $sectorCount');
  //     print('MIFARE Classic Size: $size');
  //     print('MIFARE Classic Timeout: $timeout');
  //     print('MIFARE Classic Type: $type');
  //   }

  //   if (tagData.containsKey('ndefformatable') &&
  //       tagData['ndefformatable'] is Map<String, dynamic>) {
  //     Map<String, dynamic> ndefformatableData =
  //         tagData['ndefformatable'] as Map<String, dynamic>;
  //     List<int> identifier =
  //         (ndefformatableData['identifier'] as List<dynamic>).cast<int>();

  //     // Decode NDEF Formattable specific data
  //     print('NDEF Formattable Identifier: $identifier');
  //   }
  // }

  // Future<void> decodeNfcTagInfo(Map<String, dynamic> tagInfo) async {
  //   final Uint8List mJpnaid = Uint8List.fromList(
  //       [0xA0, 0x00, 0x00, 0x00, 0x74, 0x4A, 0x50, 0x4E, 0x00, 0x10]);

  //   final Uint8List jpn1_1 = Uint8List(459); // This is name and basic info
  //   final Uint8List jpn1_2 = Uint8List(4011); // This is the photo
  //   final Uint8List jpn1_4 = Uint8List(171); // This is the address

  //    List<int> apduResponse = await tagInfo.transceive(mJpnaid);
  //       // Handle the APDU response
  //       print('APDU Response: $apduResponse');

  //   // print(APDUResponse(baData));

  //   // print(tagInfo['nfca']);
  //   // dynamic nfcaData = tagInfo['nfca'];
  //   // dynamic nfcaIdentify = tagInfo['nfca']['identifier'];
  //   // List<int> identifier = nfcaIdentify as List<int>;
  // }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('Hello World!'),
        NdefRecord.createUri(Uri.parse('https://flutter.dev')),
        NdefRecord.createMime(
            'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal(
            'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}

import 'dart:async';
import 'package:flutter/services.dart';

class APDU {
  final int cla;
  final int ins;
  final int p1;
  final int p2;
  final int le;
  final List<int>? data;

  APDU({
    required this.cla,
    required this.ins,
    required this.p1,
    required this.p2,
    required this.le,
    this.data,
  });

  static const platform = MethodChannel('your_channel_name');

  Future<APDUResponse> transmit() async {
    try {
      final Map<String, dynamic> params = {
        'cla': cla,
        'ins': ins,
        'p1': p1,
        'p2': p2,
        'le': le,
        'data': data,
      };

      final List<dynamic> result =
          await platform.invokeMethod('transmitAPDU', params);

      // Process the result and create an APDUResponse object
      return APDUResponse.fromList(result);
    } on PlatformException catch (e) {
      print("Failed to transmit APDU: '${e.message}'.");
      // Handle error
      return APDUResponse.error(e.message.toString());
    }
  }
}

class APDUResponse {
  final List<int> responseData;
  final int sw1;
  final int sw2;
  final bool isError;
  final String? errorMessage;

  APDUResponse({
    required this.responseData,
    required this.sw1,
    required this.sw2,
    this.isError = false,
    this.errorMessage,
  });

  factory APDUResponse.fromList(List<dynamic> data) {
    // Process the data and extract response and status words
    return APDUResponse(
      responseData: data.sublist(0, data.length - 2).cast<int>(),
      sw1: data[data.length - 2],
      sw2: data[data.length - 1],
    );
  }

  factory APDUResponse.error(String message) {
    return APDUResponse(
      responseData: [],
      sw1: 0x6F,
      sw2: 0x00, // Some error status word
      isError: true,
      errorMessage: message,
    );
  }
}

class APDUCommand {
  static const int APDU_MIN_LENGTH = 4;

  final int cla;
  final int ins;
  final int p1;
  final int p2;
  List<int>? data;
  final int le;

  APDUCommand({
    required this.cla,
    required this.ins,
    required this.p1,
    required this.p2,
    this.data,
    required this.le,
  });

  void update(APDUParam apduParam) {
    if (apduParam.useData) {
      data = List<int>.from(apduParam.data!);
    }
    if (apduParam.useLe) {
      throw UnsupportedError('Le cannot be updated in APDUCommand');
    }
    if (apduParam.useP1) {
      throw UnsupportedError('P1 cannot be updated in APDUCommand');
    }
    if (apduParam.useP2) {
      throw UnsupportedError('P2 cannot be updated in APDUCommand');
    }
    if (apduParam.useChannel) {
      throw UnsupportedError('Cla cannot be updated in APDUCommand');
    }
  }

  @override
  String toString() {
    String? strData;
    int bLc = 0;
    int bP3 = le;

    if (data != null) {
      final sData = StringBuffer();
      for (final byte in data!) {
        sData.write(byte.toRadixString(16).padLeft(2, '0'));
      }
      strData = 'Data=$sData';
      bLc = data!.length;
      bP3 = bLc;
    }

    final strApdu = StringBuffer();

    strApdu.write('Class=${cla.toRadixString(16).padLeft(2, '0')} ');
    strApdu.write('Ins=${ins.toRadixString(16).padLeft(2, '0')} ');
    strApdu.write('P1=${p1.toRadixString(16).padLeft(2, '0')} ');
    strApdu.write('P2=${p2.toRadixString(16).padLeft(2, '0')} ');
    strApdu.write('P3=${bP3.toRadixString(16).padLeft(2, '0')} ');

    if (data != null) strApdu.write(strData);

    return strApdu.toString();
  }
}

class APDUParam {
  late int _class;
  late int _channel;
  late int _p2;
  late int _p1;
  List<int>? _data;
  late int _le;

  APDUParam({
    int classValue = 0,
    int p1 = 0,
    int p2 = 0,
    List<int>? data,
    int le = -1,
  }) {
    _class = classValue;
    _p1 = p1;
    _p2 = p2;
    _data = data;
    _le = le;
  }

  APDUParam.clone(APDUParam param) {
    _class = param._class;
    _channel = param._channel;
    _p1 = param._p1;
    _p2 = param._p2;
    _data = param._data != null ? List<int>.from(param._data!) : null;
    _le = param._le;
  }

  APDUParam.reset() {
    _class = 0;
    _channel = 0;
    _p1 = 0;
    _p2 = 0;
    _data = null;
    _le = -1;
  }
  List<int>? get data => _data;

  APDUParam copy() {
    return APDUParam.clone(this);
  }

  bool get useClass => _class != 0;

  bool get useChannel => _channel != 0;

  bool get useLe => _le != -1;

  bool get useData => _data != null;

  bool get useP1 => _p1 != 0;

  bool get useP2 => _p2 != 0;

  set p1(int value) {
    _p1 = value;
  }

  set p2(int value) {
    _p2 = value;
  }

  set data(List<int>? value) {
    _data = value;
  }

  set le(int value) {
    _le = value;
  }

  set channel(int value) {
    _channel = value;
  }

  set classValue(int value) {
    _class = value;
  }

  @override
  String toString() {
    return 'Class=$_class P1=$_p1 P2=$_p2 Data=$_data Le=$_le Channel=$_channel';
  }
}

import 'package:demo_nfc_wallet/model/record.dart';
import 'package:demo_nfc_wallet/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NdefRecordPage extends StatelessWidget {
  const NdefRecordPage(this.index, this.record, {super.key});

  final int index;

  final NdefRecord record;

  @override
  Widget build(BuildContext context) {
    final info = NdefRecordInfo.fromNdef(record);
    return Scaffold(
      appBar: AppBar(
        title: Text('Record #$index'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _RecordColumn(
            title: Text(info.title),
            subtitle: Text(info.subtitle),
          ),
          const SizedBox(height: 12),
          _RecordColumn(
            title: const Text('Size'),
            subtitle: Text('${record.byteLength} bytes'),
          ),
          const SizedBox(height: 12),
          _RecordColumn(
            title: const Text('Type Name Format'),
            subtitle: Text(record.typeNameFormat.index.toHexString()),
          ),
          const SizedBox(height: 12),
          _RecordColumn(
            title: const Text('Type'),
            subtitle: Text(record.type.toHexString()),
          ),
          const SizedBox(height: 12),
          _RecordColumn(
            title: const Text('Identifier'),
            subtitle: Text(record.identifier.toHexString()),
          ),
          const SizedBox(height: 12),
          _RecordColumn(
            title: const Text('Payload'),
            subtitle: Text(record.payload.toHexString()),
          ),
        ],
      ),
    );
  }
}

class _RecordColumn extends StatelessWidget {
  const _RecordColumn({required this.title, required this.subtitle});

  final Widget title;

  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
          child: title,
        ),
        const SizedBox(height: 2),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15),
          child: subtitle,
        ),
      ],
    );
  }
}

class NdefRecordInfo {
  const NdefRecordInfo({required this.record, required this.title, required this.subtitle});

  final Record record;

  final String title;

  final String subtitle;

  static NdefRecordInfo fromNdef(NdefRecord record) {
    final record0 = Record.fromNdef(record);
    if (record0 is WellknownTextRecord) {
      return NdefRecordInfo(
        record: record0,
        title: 'Wellknown Text',
        subtitle: '(${record0.languageCode}) ${record0.text}',
      );
    }
    if (record0 is WellknownUriRecord) {
      return NdefRecordInfo(
        record: record0,
        title: 'Wellknown Uri',
        subtitle: '${record0.uri}',
      );
    }
    if (record0 is MimeRecord) {
      return NdefRecordInfo(
        record: record0,
        title: 'Mime',
        subtitle: '(${record0.type}) ${record0.dataString}',
      );
    }
    if (record0 is AbsoluteUriRecord) {
      return NdefRecordInfo(
        record: record0,
        title: 'Absolute Uri',
        subtitle: '(${record0.uriType}) ${record0.payloadString}',
      );
    }
    if (record0 is ExternalRecord) {
      return NdefRecordInfo(
        record: record0,
        title: 'External',
        subtitle: '(${record0.domainType}) ${record0.dataString}',
      );
    }
    if (record0 is UnsupportedRecord) {
      // more custom info from NdefRecord.
      if (record.typeNameFormat == NdefTypeNameFormat.empty) {
        return NdefRecordInfo(
          record: record0,
          title: _typeNameFormatToString(record0.record.typeNameFormat),
          subtitle: '-',
        );
      }
      return NdefRecordInfo(
        record: record0,
        title: _typeNameFormatToString(record0.record.typeNameFormat),
        subtitle: '(${record0.record.type.toHexString()}) ${record0.record.payload.toHexString()}',
      );
    }
    throw UnimplementedError();
  }
}

String _typeNameFormatToString(NdefTypeNameFormat format) {
  switch (format) {
    case NdefTypeNameFormat.empty:
      return 'Empty';
    case NdefTypeNameFormat.nfcWellknown:
      return 'NFC Wellknown';
    case NdefTypeNameFormat.media:
      return 'Media';
    case NdefTypeNameFormat.absoluteUri:
      return 'Absolute Uri';
    case NdefTypeNameFormat.nfcExternal:
      return 'NFC External';
    case NdefTypeNameFormat.unknown:
      return 'Unknown';
    case NdefTypeNameFormat.unchanged:
      return 'Unchanged';
  }
}

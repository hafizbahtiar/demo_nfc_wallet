import 'package:demo_nfc_wallet/model/record.dart';
import 'package:demo_nfc_wallet/model/write_record.dart';
import 'package:demo_nfc_wallet/repository/repository.dart';
import 'package:demo_nfc_wallet/view/common/form_row.dart';
import 'package:demo_nfc_wallet/view/common/nfc_session.dart';
import 'package:demo_nfc_wallet/view/edit_external.dart';
import 'package:demo_nfc_wallet/view/edit_mime.dart';
import 'package:demo_nfc_wallet/view/edit_text.dart';
import 'package:demo_nfc_wallet/view/edit_uri.dart';
import 'package:demo_nfc_wallet/view/ndef_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class NdefWriteModel with ChangeNotifier {
  NdefWriteModel(this._repo);

  final Repository _repo;

  Stream<Iterable<WriteRecord>> subscribe() {
    return _repo.subscribeWriteRecordList();
  }

  Future<void> delete(WriteRecord record) {
    return _repo.deleteWriteRecord(record);
  }

  Future<String?> handleTag(NfcTag tag, Iterable<WriteRecord> recordList) async {
    final tech = Ndef.from(tag);

    if (tech == null) {
      throw('Tag is not ndef.');
    }

    if (!tech.isWritable) {
      throw('Tag is not ndef writable.');
    }

    try {
      final message = NdefMessage(recordList.map((e) => e.record).toList());
      await tech.write(message);
    } on PlatformException catch (e) {
      throw(e.message ?? 'Some error has occurred.');
    }

    return '[Ndef - Write] is completed.';
  }
}

class NdefWritePage extends StatelessWidget {
  const NdefWritePage({super.key});

  static Widget withDependency() => ChangeNotifierProvider<NdefWriteModel>(
    create: (context) => NdefWriteModel(Provider.of(context, listen: false)),
    child: const NdefWritePage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ndef - Write'),
      ),
      body: StreamBuilder<Iterable<WriteRecord>>(
        stream: Provider.of<NdefWriteModel>(context, listen: false).subscribe(),
        builder: (context, ss) => ListView(
          padding: const EdgeInsets.all(2),
          children: [
            FormSection(children: [
              FormRow(
                title: const Text('Add Record'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Record Types'),
                      children: [
                        SimpleDialogOption(
                          child: const Text('Text'),
                          onPressed: () => Navigator.pop(context, 'text'),
                        ),
                        SimpleDialogOption(
                          child: const Text('Uri'),
                          onPressed: () => Navigator.pop(context, 'uri'),
                        ),
                        SimpleDialogOption(
                          child: const Text('Mime'),
                          onPressed: () => Navigator.pop(context, 'mime'),
                        ),
                        SimpleDialogOption(
                          child: const Text('External'),
                          onPressed: () => Navigator.pop(context, 'external'),
                        ),
                      ],
                    ),
                  );
                  switch (result) {
                    case 'text':
                      Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => EditTextPage.withDependency(),
                      ));
                      break;
                    case 'uri':
                      Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => EditUriPage.withDependency(),
                      ));
                      break;
                    case 'mime':
                      Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => EditMimePage.withDependency(),
                      ));
                      break;
                    case 'external':
                      Navigator.push(context, MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => EditExternalPage.withDependency(),
                      ));
                      break;
                    case null:
                      break;
                    default:
                      throw('unsupported: result=$result');
                  }
                },
              ),
              FormRow(
                title: Text('Start Session', style: TextStyle(color: ss.data?.isNotEmpty != true
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.primary,
                )),
                onTap: ss.data?.isNotEmpty != true
                  ? null
                  : () => startSession(
                    context: context,
                    handleTag: (tag) => Provider.of<NdefWriteModel>(context, listen: false).handleTag(tag, ss.data!),
                  ),
              ),
            ]),
            if (ss.data?.isNotEmpty == true)
              FormSection(
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECORDS'),
                    Text('${ss.data!.map((e) => e.record.byteLength).reduce((a, b) => a + b)} bytes'),
                  ],
                ),
                children: List.generate(ss.data!.length, (i) {
                  final record = ss.data!.elementAt(i);
                  return _WriteRecordFormRow(i, record);
                }),
              ),
          ],
        ),
      ),
    );
  }
}

class _WriteRecordFormRow extends StatelessWidget {
  const _WriteRecordFormRow(this.index, this.record);

  final int index;

  final WriteRecord record;

  @override
  Widget build(BuildContext context) {
    final info = NdefRecordInfo.fromNdef(record.record);
    final editPageBuilder = _editPageBuilders[info.record.runtimeType];
    return FormRow(
      title: Text('#$index ${info.title}'),
      subtitle: Text(info.subtitle),
      trailing: const Icon(Icons.more_vert),
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  title: Text(
                    '#$index ${info.title}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
                  ),
                ),
                ListTile(
                  title: const Text('View Details'),
                  onTap: () => Navigator.pop(context, 'view_details'),
                ),
                if (editPageBuilder != null)
                  ListTile(
                    title: const Text('Edit'),
                    onTap: () => Navigator.pop(context, 'edit'),
                  ),
                ListTile(
                  title: const Text('Delete'),
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
              ],
            ),
          ),
        );
        switch (result) {
          case 'view_details':
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => NdefRecordPage(index, record.record),
            ));
            break;
          case 'edit':
            assert(editPageBuilder != null);
            Navigator.push(context, MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => editPageBuilder!(record),
            ));
            break;
          case 'delete':
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Record?'),
                content: Text('#$index ${info.title}'),
                actions: [
                  TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('DELETE'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
            if (result == true) {
              Provider.of<NdefWriteModel>(context, listen: false)
                .delete(record).catchError((e) => print('=== $e ==='));
            }
            break;
          case null:
            break;
          default:
            throw('unsupported result: $result');
        }
      },
    );
  }
}

final _editPageBuilders = Map<Type, Widget Function(WriteRecord)>.unmodifiable(
  <Type, Widget Function(WriteRecord)>{
    WellknownTextRecord: (record) => EditTextPage.withDependency(record),
    WellknownUriRecord: (record) => EditUriPage.withDependency(record),
    MimeRecord: (record) => EditMimePage.withDependency(record),
    ExternalRecord: (record) => EditExternalPage.withDependency(record),
  },
);

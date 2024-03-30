import 'dart:convert';
import 'dart:typed_data';

import 'package:demo_nfc_wallet/model/record.dart';
import 'package:demo_nfc_wallet/model/write_record.dart';
import 'package:demo_nfc_wallet/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditMimeModel with ChangeNotifier {
  EditMimeModel(this._repo, this.old) {
    if (old == null) return;
    final record = MimeRecord.fromNdef(old!.record);
    typeController.text = record.type;
    dataController.text = record.dataString;
  }

  final Repository _repo;
  final WriteRecord? old;
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  Future<Object> save() async {
    if (!formKey.currentState!.validate()) {
      throw('Form is invalid.');
    }

    final record = MimeRecord(
      type: typeController.text,
      data: Uint8List.fromList(utf8.encode(dataController.text)),
    );

    return _repo.createOrUpdateWriteRecord(WriteRecord(
      id: old?.id,
      record: record.toNdef(),
    ));
  }
}

class EditMimePage extends StatelessWidget {
  const EditMimePage({super.key});

  static Widget withDependency([WriteRecord? record]) => ChangeNotifierProvider<EditMimeModel>(
    create: (context) => EditMimeModel(Provider.of(context, listen: false), record),
    child: const EditMimePage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mime'),
      ),
      body: Form(
        key: Provider.of<EditMimeModel>(context, listen: false).formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: Provider.of<EditMimeModel>(context, listen: false).typeController,
              decoration: const InputDecoration(labelText: 'Type', hintText: 'text/plain', helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) => value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: Provider.of<EditMimeModel>(context, listen: false).dataController,
              decoration: const InputDecoration(labelText: 'Data', helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) => value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => Provider.of<EditMimeModel>(context, listen: false).save()
                .then((_) => Navigator.pop(context))
                .catchError((e) => print('=== $e ===')),
            ),
          ],
        ),
      ),
    );
  }
}

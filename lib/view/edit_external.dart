import 'dart:convert';
import 'dart:typed_data';

import 'package:demo_nfc_wallet/model/record.dart';
import 'package:demo_nfc_wallet/model/write_record.dart';
import 'package:demo_nfc_wallet/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditExternalModel with ChangeNotifier {
  EditExternalModel(this._repo, this.old) {
    if (old == null) return;
    final record = ExternalRecord.fromNdef(old!.record);
    domainController.text = record.domain;
    typeController.text = record.type;
    dataController.text = record.dataString;
  }

  final Repository _repo;
  final WriteRecord? old;
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController domainController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  Future<Object> save() async {
    if (!formKey.currentState!.validate()) {
      throw('Form is invalid.');
    }

    final record = ExternalRecord(
      domain: domainController.text,
      type: typeController.text,
      data: Uint8List.fromList(utf8.encode(dataController.text)),
    );

    return _repo.createOrUpdateWriteRecord(WriteRecord(
      id: old?.id,
      record: record.toNdef(),
    ));
  }
}

class EditExternalPage extends StatelessWidget {
  const EditExternalPage({super.key});

  static Widget withDependency([WriteRecord? record]) => ChangeNotifierProvider<EditExternalModel>(
    create: (context) => EditExternalModel(Provider.of(context, listen: false), record),
    child: const EditExternalPage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit External'),
      ),
      body: Form(
        key: Provider.of<EditExternalModel>(context, listen: false).formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: Provider.of<EditExternalModel>(context, listen: false).domainController,
              decoration: const InputDecoration(labelText: 'Domain',  helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) => value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: Provider.of<EditExternalModel>(context, listen: false).typeController,
              decoration: const InputDecoration(labelText: 'Type', helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) => value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: Provider.of<EditExternalModel>(context, listen: false).dataController,
              decoration: const InputDecoration(labelText: 'Data', helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) => value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => Provider.of<EditExternalModel>(context, listen: false).save()
                .then((_) => Navigator.pop(context))
                .catchError((e) => print('=== $e ===')),
            ),
          ],
        ),
      ),
    );
  }
}

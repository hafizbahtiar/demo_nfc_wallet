import 'package:demo_nfc_wallet/view/common/form_row.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(2),
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, ss) => FormSection(children: [
              FormRow(
                title: const Text('App Name'),
                trailing: Text(ss.data?.appName ?? ''),
              ),
              FormRow(
                title: const Text('Version'),
                trailing: Text(ss.data?.version ?? ''),
              ),
              FormRow(
                title: const Text('Build Number'),
                trailing: Text(ss.data?.buildNumber ?? ''),
              ),
            ]),
          ),
          FormSection(children: [
            FormRow(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launch('https://nfcmanager.naokiokada.com/privacy-policy/'),
            ),
          ]),
        ],
      ),
    );
  }
}

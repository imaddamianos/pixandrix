// whatsapp_redirect.dart
import 'package:url_launcher/url_launcher.dart';

Future<void> redirectToWhatsApp(String phoneNumber) async {
  final Uri whatsappUri = Uri(
    scheme: 'https',
    host: 'wa.me',
    path: phoneNumber,
  );

  if (await canLaunch(whatsappUri.toString())) {
    await launch(whatsappUri.toString());
  } else {
    throw 'Could not launch $whatsappUri';
  }
}

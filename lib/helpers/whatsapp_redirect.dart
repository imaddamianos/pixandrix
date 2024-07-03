import 'package:url_launcher/url_launcher.dart';

Future<void> redirectToWhatsApp(String phoneNumber) async {
  launchUrl(Uri.parse('https://wa.me/''$phoneNumber?text=Hi'),
                    mode: LaunchMode.externalApplication);
}

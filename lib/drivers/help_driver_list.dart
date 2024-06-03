import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDriverButton extends StatelessWidget {
  final List<HelpRequestData> helpRequests;
  final VoidCallback onHelped; // Callback function to refresh the list

  const HelpDriverButton({
    Key? key,
    required this.helpRequests,
    required this.onHelped,
  }) : super(key: key);

  List<HelpRequestData> _getUnhelpedRequests() {
    return helpRequests.where((help) => !help.isHelped).toList();
  }

  Future<void> _showHelpRequestsDialog(
      BuildContext context, List<HelpRequestData> unhelpedRequests) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Requests'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unhelpedRequests.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: Text(unhelpedRequests[index].description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(unhelpedRequests[index].driverInfo),
                        Text(unhelpedRequests[index].driverNumber),
                        Text(
                            'Time: ${TimeOfDay.fromDateTime(unhelpedRequests[index].timestamp.toDate()).format(context)}'),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseOperations.changeHelpStatus(
                              true,
                              unhelpedRequests[index].description,
                            );
                            onHelped(); // Trigger refresh callback
                          },
                          child: const Text('Helped'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.navigation),
                          onPressed: () {
                            _openGoogleMaps(
                              unhelpedRequests[index].latitude,
                              unhelpedRequests[index].longitude,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<HelpRequestData> unhelpedRequests = _getUnhelpedRequests();

    if (unhelpedRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () => _showHelpRequestsDialog(context, unhelpedRequests),
      child: const Text(
        'Help Driver',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

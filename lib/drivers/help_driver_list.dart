import 'package:flutter/material.dart';
import 'package:pixandrix/firebase/firebase_operations.dart';
import 'package:pixandrix/models/helpRequest_model.dart';
import 'package:pixandrix/widgets/google_maps_view.dart';

class HelpDriverButton extends StatelessWidget {
  final List<HelpRequestData> helpRequests;
  final VoidCallback onHelped;

  const HelpDriverButton({
    super.key,
    required this.helpRequests,
    required this.onHelped,
  });

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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseOperations.changeHelpStatus(
                              true,
                              unhelpedRequests[index].description,
                            );
                            Navigator.of(context).pop();
                            onHelped(); // Trigger refresh callback
                          },
                          child: const Text('Take Help'),
                        ),
                        TextButton.icon(onPressed: (){
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoogleMapsView(
                                    latitude: unhelpedRequests[index].latitude,
                                    longitude: unhelpedRequests[index].longitude,
                                  ),
                                ),
                              );
                        }, icon: const Icon(Icons.navigation),
                         label: const Text('Open Map')),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
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

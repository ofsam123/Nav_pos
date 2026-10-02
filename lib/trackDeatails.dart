import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Models/visitationModel.dart';

class visitationDeatils extends StatelessWidget {
  const visitationDeatils({super.key, required this.visit});

  final VisitationModel visit;

  Future<void> _openInMaps(BuildContext context) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${visit.Latitude},${visit.Longitute}');
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could not open Google Maps")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitedAt = visit.visitedAt;
    final hasLocation = visit.Latitude != null &&
        visit.Longitute != null &&
        !(visit.Latitude == 0 && visit.Longitute == 0);
    final outcome = visit.Outcome_of_the_visit ?? '';
    final comment = visit.Comment ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Visitation Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(15, 86, 148, 1), Color(0xFF2E7BC4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.storefront, color: Colors.white, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.Customer_Name ?? "Unknown customer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        visit.CustomerID ?? "",
                        style: TextStyle(color: Colors.white70),
                      ),
                      if ((visit.Visitation_Type ?? '').isNotEmpty) ...[
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            visit.Visitation_Type!,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _Section(
            title: "When",
            children: [
              _DetailRow(
                icon: Icons.event,
                label: "Date",
                value: visitedAt == null
                    ? (visit.Date ?? "-")
                    : DateFormat('EEEE, d MMMM yyyy').format(visitedAt),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: "Time",
                value: visitedAt == null || (visit.Time ?? '').isEmpty
                    ? (visit.Time ?? "-")
                    : DateFormat('h:mm a').format(visitedAt),
              ),
            ],
          ),
          _Section(
            title: "Visited by",
            children: [
              _DetailRow(
                icon: Icons.person_outline,
                label: "User",
                value: visit.UserID ?? "-",
              ),
            ],
          ),
          _Section(
            title: "Visit notes",
            children: [
              _DetailRow(
                icon: Icons.flag_outlined,
                label: "Outcome of the visit",
                value: outcome.isEmpty ? "Not recorded" : outcome,
              ),
              _DetailRow(
                icon: Icons.notes,
                label: "Comment",
                value: comment.isEmpty ? "No comment" : comment,
              ),
            ],
          ),
          _Section(
            title: "Location",
            children: [
              _DetailRow(
                icon: Icons.my_location,
                label: "Latitude",
                value: visit.Latitude?.toString() ?? "-",
              ),
              _DetailRow(
                icon: Icons.explore_outlined,
                label: "Longitude",
                value: visit.Longitute?.toString() ?? "-",
              ),
              if (hasLocation)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(15, 86, 148, 1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openInMaps(context),
                      icon: Icon(Icons.map_outlined),
                      label: Text("Open in Google Maps"),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey[600],
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Color.fromRGBO(15, 86, 148, 1)),
      title: Text(
        label,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
            fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }
}

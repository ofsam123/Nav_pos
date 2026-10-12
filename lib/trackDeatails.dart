import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Models/visitationModel.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

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
    final type = visit.Visitation_Type ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visit details"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initialsOf(visit.Customer_Name),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  visit.Customer_Name ?? "Unknown customer",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  visit.CustomerID ?? "",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                  ),
                ),
                if (type.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  StatusPill(
                    text: type,
                    color: type.toLowerCase().contains("sales")
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Section(
            title: "When",
            children: [
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: "Date",
                value: visitedAt == null
                    ? (visit.Date ?? "-")
                    : DateFormat('EEEE, d MMMM yyyy').format(visitedAt),
              ),
              _DetailRow(
                icon: Icons.schedule_rounded,
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
                icon: Icons.person_outline_rounded,
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
                icon: Icons.notes_rounded,
                label: "Comment",
                value: comment.isEmpty ? "No comment" : comment,
              ),
            ],
          ),
          _Section(
            title: "Location",
            children: [
              _DetailRow(
                icon: Icons.my_location_rounded,
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
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openInMaps(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Open in Google Maps"),
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallCapsLabel(title),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconBadge(icon: icon, color: AppColors.primary, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

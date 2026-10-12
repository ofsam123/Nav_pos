import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:intl/intl.dart';
import 'package:nav_pos/trackDeatails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API.dart';
import 'Models/visitationModel.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class trackVisitation extends StatefulWidget {
  const trackVisitation({super.key});

  @override
  State<trackVisitation> createState() => _trackVisitationState();
}

class _trackVisitationState extends State<trackVisitation> {
  late Future<List<VisitationModel>> _visitsFuture;

  // null means "All dates"
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _visitsFuture = _getVisits();
  }

  Future<void> _refresh() async {
    final future = _getVisits();
    setState(() {
      _visitsFuture = future;
    });
    await future;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const Border(),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 28),
            onPressed: _refresh,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<VisitationModel>>(
          future: _visitsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppLoader());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 60),
                  EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: "Failed to load visitations",
                    message: "Check your connection and try again.",
                    action: OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry"),
                    ),
                  ),
                ],
              );
            }

            final visits = List<VisitationModel>.from(snapshot.data ?? []);
            visits.sort((a, b) {
              final aTime = a.visitedAt ?? DateTime(1900);
              final bTime = b.visitedAt ?? DateTime(1900);
              return bTime.compareTo(aTime);
            });

            final filtered = _selectedDate == null
                ? visits
                : visits
                    .where((v) => _isSameDay(v.visitedAt, _selectedDate!))
                    .toList();

            final currentOutcome = visits.isEmpty
                ? ''
                : (visits.first.Outcome_of_the_visit ?? '').trim();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              children: [
                if (visits.isNotEmpty) ...[
                  _CurrentVisitCard(
                    visit: visits.first,
                    onTap: () => _openDetails(visits.first),
                  ),
                  if (currentOutcome.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                      child: Text(
                        currentOutcome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                _buildFilterBar(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    "${filtered.length} visit${filtered.length == 1 ? '' : 's'}"
                    "${_selectedDate == null ? '' : ' ${_isSameDay(_selectedDate, DateTime.now()) ? 'today' : 'on ${_formatDay(_selectedDate!)}'}'}",
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: EmptyState(
                      icon: Icons.event_busy_rounded,
                      title: "No visitations",
                      message: _selectedDate == null
                          ? "You have not recorded any visits yet"
                          : "No visits recorded on ${_formatDay(_selectedDate!)}",
                    ),
                  )
                else
                  ..._buildGroupedList(filtered),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final today = DateTime.now();
    final isAll = _selectedDate == null;
    final isToday = !isAll && _isSameDay(_selectedDate, today);
    final isCustom = !isAll && !isToday;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _FilterPill(
          label: "All",
          selected: isAll,
          onTap: () => setState(() => _selectedDate = null),
        ),
        _FilterPill(
          label: "Today",
          selected: isToday,
          onTap: () => setState(() => _selectedDate = today),
        ),
        _FilterPill(
          label: isCustom ? _formatDay(_selectedDate!) : "Pick date",
          trailingIcon: Icons.calendar_month_outlined,
          selected: isCustom,
          onTap: _pickDate,
        ),
      ],
    );
  }

  List<Widget> _buildGroupedList(List<VisitationModel> visits) {
    final widgets = <Widget>[];
    String? currentHeader;
    for (final visit in visits) {
      final header =
          visit.visitedAt == null ? "Unknown date" : _formatDay(visit.visitedAt!);
      if (header != currentHeader) {
        currentHeader = header;
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14),
          child: SmallCapsLabel(header),
        ));
      }
      widgets.add(_VisitCard(visit: visit, onTap: () => _openDetails(visit)));
    }
    return widgets;
  }

  void _openDetails(VisitationModel visit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => visitationDeatils(visit: visit)),
    );
  }

  Future<List<VisitationModel>> _getVisits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('User_Name') ?? '';

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          ApiUrl.VisitationApi + "?\$filter=UserID eq " + "'" + userName + "'"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    );

    if (response.statusCode == 200) {
      List responseList = json.decode(response.body)["value"];
      return responseList.map((job) => VisitationModel.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load visitations');
    }
  }
}

bool _isSameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDay(DateTime date) {
  final today = DateTime.now();
  if (_isSameDay(date, today)) return "Today";
  if (_isSameDay(date, today.subtract(Duration(days: 1)))) return "Yesterday";
  return DateFormat('EEE, d MMM yyyy').format(date);
}

String _formatTime(VisitationModel visit) {
  final visitedAt = visit.visitedAt;
  if (visitedAt == null || (visit.Time ?? '').isEmpty) return "-";
  return DateFormat('h:mm a').format(visitedAt);
}

Color _typeColor(String type) => type.toLowerCase().contains("sales")
    ? AppColors.success
    : AppColors.warning;

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textDark;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, size: 20, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentVisitCard extends StatelessWidget {
  const _CurrentVisitCard({required this.visit, required this.onTap});

  final VisitationModel visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(visit.visitedAt, DateTime.now());
    final type = visit.Visitation_Type ?? '';

    Widget meta(IconData icon, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      );
    }

    Widget separator() => Container(
          width: 1,
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white.withOpacity(0.35),
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isToday ? "CURRENT VISIT" : "LAST VISIT",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                visit.Customer_Name ?? "Unknown customer",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                visit.CustomerID ?? "",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.25), height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  meta(
                    Icons.calendar_today_outlined,
                    visit.visitedAt == null ? "-" : _formatDay(visit.visitedAt!),
                  ),
                  separator(),
                  meta(Icons.schedule_rounded, _formatTime(visit)),
                  if (type.isNotEmpty) ...[
                    separator(),
                    Expanded(child: meta(Icons.work_outline_rounded, type)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.onTap});

  final VisitationModel visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final note = (visit.Outcome_of_the_visit ?? '').trim().isNotEmpty
        ? visit.Outcome_of_the_visit!.trim()
        : (visit.Comment ?? '').trim();
    final type = visit.Visitation_Type ?? '';

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: visit.Customer_Name, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.Customer_Name ?? "Unknown customer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  visit.CustomerID ?? "",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(visit),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
              ),
              if (type.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _typeColor(type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _typeColor(type) == AppColors.success
                          ? const Color(0xFF15803D)
                          : const Color(0xFFC2410C),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

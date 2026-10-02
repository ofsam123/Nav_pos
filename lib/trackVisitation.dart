import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_pos/trackDeatails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API.dart';
import 'Models/visitationModel.dart';

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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Track Visitation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<VisitationModel>>(
          future: _visitsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.cloud_off,
                title: "Oops!! 😔",
                message: "Failed to load visitations",
                action: ElevatedButton(
                  onPressed: _refresh,
                  child: Text("Retry"),
                ),
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

            return ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (visits.isNotEmpty) ...[
                  _CurrentVisitCard(
                    visit: visits.first,
                    onTap: () => _openDetails(visits.first),
                  ),
                  SizedBox(height: 20),
                ],
                _buildFilterBar(),
                SizedBox(height: 12),
                Text(
                  "${filtered.length} visit${filtered.length == 1 ? '' : 's'}"
                  "${_selectedDate == null ? '' : ' on ${_formatDay(_selectedDate!)}'}",
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _MessageView(
                      icon: Icons.event_busy,
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
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          label: Text("All"),
          selected: isAll,
          onSelected: (_) => setState(() => _selectedDate = null),
        ),
        ChoiceChip(
          label: Text("Today"),
          selected: isToday,
          onSelected: (_) => setState(() => _selectedDate = today),
        ),
        ChoiceChip(
          avatar: Icon(Icons.calendar_today, size: 16),
          label: Text(isCustom ? _formatDay(_selectedDate!) : "Pick date"),
          selected: isCustom,
          onSelected: (_) => _pickDate(),
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
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            header,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
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

String _initials(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+'));
  final letters = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
  final result = letters.join().toUpperCase();
  return result.isEmpty ? "?" : result;
}

class _CurrentVisitCard extends StatelessWidget {
  const _CurrentVisitCard({required this.visit, required this.onTap});

  final VisitationModel visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(visit.visitedAt, DateTime.now());
    final outcome = visit.Outcome_of_the_visit ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(15, 86, 148, 1), Color(0xFF2E7BC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text(
                  isToday ? "CURRENT VISIT" : "LAST VISIT",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
            SizedBox(height: 12),
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
            SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _IconLabel(
                  icon: Icons.event,
                  text: visit.visitedAt == null
                      ? "-"
                      : _formatDay(visit.visitedAt!),
                  color: Colors.white,
                ),
                _IconLabel(
                  icon: Icons.access_time,
                  text: _formatTime(visit),
                  color: Colors.white,
                ),
                if ((visit.Visitation_Type ?? '').isNotEmpty)
                  _IconLabel(
                    icon: Icons.storefront,
                    text: visit.Visitation_Type!,
                    color: Colors.white,
                  ),
              ],
            ),
            if (outcome.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                outcome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
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
    final outcome = visit.Outcome_of_the_visit ?? '';
    final type = visit.Visitation_Type ?? '';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Color.fromRGBO(15, 86, 148, 0.12),
                child: Text(
                  _initials(visit.Customer_Name),
                  style: TextStyle(
                    color: Color.fromRGBO(15, 86, 148, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            visit.Customer_Name ?? "Unknown customer",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 71, 110, 129),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(visit),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      visit.CustomerID ?? "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (type.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: type.toLowerCase().contains("sales")
                              ? Colors.green.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: type.toLowerCase().contains("sales")
                                ? Colors.green[800]
                                : Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                    if (outcome.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        outcome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel(
      {required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            if (action != null) ...[SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

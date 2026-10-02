class VisitationModel {
  // String? Visitation_No;
  String? CustomerID;
  String? Date;
  String? Time;
  String? UserID;
  double? Longitute;
  double? Latitude;
  // String? Blocked;
  String? Customer_Name;
  String? Visitation_Type;
  String? Comment;
  String? Outcome_of_the_visit;

  VisitationModel({
    // this.Visitation_No,
    this.CustomerID,
    this.Date,
    this.UserID,
    this.Longitute,
    this.Latitude,
    this.Customer_Name,
    this.Time,
    this.Visitation_Type,
    this.Comment,
    this.Outcome_of_the_visit,
  });

  VisitationModel.fromJson(Map<String, dynamic> json) {
    // Visitation_No = json['Visitation_No'];
    CustomerID = json['CustomerID'];
    Date = json['Date'];
    UserID = json['UserID'];
    Longitute = (json['Longitute'] as num?)?.toDouble();
    Latitude = (json['Latitude'] as num?)?.toDouble();
    // Blocked = json['Blocked'];
    Customer_Name = json['Customer_Name'];
    Time = json['Time'];
    Visitation_Type = json['Visitation_Type'];
    Comment = json['Comment'];
    Outcome_of_the_visit = json['Outcome_of_the_visit'];
  }

  DateTime? get visitedAt {
    final date = DateTime.tryParse(Date ?? '');
    if (date == null) return null;
    final timeParts = (Time ?? '').split('.').first.split(':');
    final hour = int.tryParse(timeParts.isNotEmpty ? timeParts[0] : '') ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '') ?? 0;
    final second = int.tryParse(timeParts.length > 2 ? timeParts[2] : '') ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }
}

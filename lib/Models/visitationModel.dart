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

  VisitationModel({
    // this.Visitation_No,
    this.CustomerID,
    this.Date,
    this.UserID,
    this.Longitute,
    this.Latitude,
    this.Customer_Name,
    this.Time,
  });

  VisitationModel.fromJson(Map<String, dynamic> json) {
    // Visitation_No = json['Visitation_No'];
    CustomerID = json['CustomerID'];
    Date = json['Date'];
    UserID = json['UserID'];
    Longitute = json['Longitute'];
    Latitude = json['Latitude'];
    // Blocked = json['Blocked'];
    Customer_Name = json['Customer_Name'];
    Time = json['Time'];
  }
}

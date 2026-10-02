class postedSaledDetailsModel {
  String? Description;
  // int? Line_No;
  String? No;
  int? Quantity;
  // String? Amount;

  double? Amount_Including_VAT;

  String? Posting_Date;

  postedSaledDetailsModel({
    this.Description,
    // this.Line_No,
    this.No,
    this.Quantity,
    this.Amount_Including_VAT,
    this.Posting_Date,
  });

  postedSaledDetailsModel.fromJson(Map<String, dynamic> json) {
    Description = json['Description'];
    // Line_No = json['Line_No'];
    No = json['No'];
    Quantity = json['Quantity'];

    Amount_Including_VAT = json['Amount_Including_VAT']?.toDouble();

    Posting_Date = json['Posting_Date'];
  }
}

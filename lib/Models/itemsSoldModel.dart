class itemsSoldModel {
  String? Document_No;
  // int? Line_No;
  String? No;
  String? Description;
  // int? Unit_Price;
  // int? Line_Amount;
  // bool? Unit_of_Measure_Code;
  // String? Amount;

  int? Quantity;
  String? Location_Code;

  double? Amount_Including_VAT;
  String? Posting_Date;

  itemsSoldModel({
    this.Document_No,
    // this.Line_No,
    this.No,
    this.Description,
    // this.Unit_Price,
    // this.Line_Amount,
    // this.Unit_of_Measure_Code,
    // this.Amount,

    this.Quantity,
    this.Location_Code,
    this.Amount_Including_VAT,
    this.Posting_Date,
  });

  itemsSoldModel.fromJson(Map<String, dynamic> json) {
    Document_No = json['Document_No'];
    // Line_No = json['Line_No'];
    No = json['No'];
    Description = json['Description'];
    // Unit_Price = json['Unit_Price'];
    // Line_Amount = json['Line_Amount'];
    // Unit_of_Measure_Code = json['Unit_of_Measure_Code'];

    Quantity = json['Quantity'];
    Location_Code = json['Location_Code'];

    Amount_Including_VAT = json['Amount_Including_VAT']?.toDouble();
    Posting_Date = json['Posting_Date'];
  }
}

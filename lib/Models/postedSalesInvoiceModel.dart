class postedSaledModel {
  String? Sell_to_Customer_No;
  // int? Line_No;
  String? No;
  String? Sell_to_Customer_Name;
  // int? Unit_Price;
  // int? Line_Amount;
  bool? Comment;
  // String? Amount;

  String? Salesperson_Code;

  String? Responsibility_Center;
  String? Posting_Date;

  postedSaledModel({
    this.Sell_to_Customer_No,
    // this.Line_No,
    this.No,
    this.Sell_to_Customer_Name,
    // this.Unit_Price,
    // this.Line_Amount,
    // this.Unit_of_Measure_Code,
    this.Comment,
    this.Salesperson_Code,
    this.Responsibility_Center,
    this.Posting_Date,
  });

  postedSaledModel.fromJson(Map<String, dynamic> json) {
    Sell_to_Customer_No = json['Sell_to_Customer_No'];
    // Line_No = json['Line_No'];
    No = json['No'];
    Sell_to_Customer_Name = json['Sell_to_Customer_Name'];
    // Unit_Price = json['Unit_Price'];
    // Line_Amount = json['Line_Amount'];
    Comment = json['Comment'];

    Salesperson_Code = json['Salesperson_Code'];

    Responsibility_Center = json['Amount_Including_VAT'];
    Posting_Date = json['Posting_Date'];
  }
}

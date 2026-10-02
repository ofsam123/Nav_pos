class salesOrderModelModel {
  String? Sell_to_Customer_No;
  String? No;
  String? Sell_to_Customer_Name;
  String? Responsibility_Center;
  String? Posting_Date;

  salesOrderModelModel({
    this.Sell_to_Customer_No,
    this.No,
    this.Sell_to_Customer_Name,
    this.Responsibility_Center,
    this.Posting_Date,
  });

  salesOrderModelModel.fromJson(Map<String, dynamic> json) {
    Sell_to_Customer_No = json['Sell_to_Customer_No'];
    No = json['No'];
    Sell_to_Customer_Name = json['Sell_to_Customer_Name'];
    Responsibility_Center = json['Amount_Including_VAT'];
    Posting_Date = json['Posting_Date'];
  }
}

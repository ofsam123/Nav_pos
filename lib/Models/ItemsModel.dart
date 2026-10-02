class itemsModel {
  String? Item_No;
  int? Quantity;
  String? Posting_Date;
  String? Document_No;
  String? Item_Description;
  String? selectedUMValue;
  itemsModel({
    this.Item_No,
    // this.Line_No,
    this.Quantity,
    this.Posting_Date,
    this.Document_No,
    this.Item_Description,
  });

  itemsModel.fromJson(Map<String, dynamic> json) {
    Quantity = json['Quantity'];
    Item_No = json['Item_No'];
    Posting_Date = json['Posting_Date'];
    Document_No = json['Document_No'];
    Item_Description = json['Item_Description'];
  }
}

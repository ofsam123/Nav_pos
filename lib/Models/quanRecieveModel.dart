class quanRecModel {
  String? Item_No;
  int? Qty_Received;
  String? Receipt_Date;
  String? Transfer_from_Code;
  String? Transfer_to_Code;

  quanRecModel({
    this.Item_No,
    this.Qty_Received,
    this.Receipt_Date,
    this.Transfer_from_Code,
    this.Transfer_to_Code,
  });

  quanRecModel.fromJson(Map<String, dynamic> json) {
    Item_No = json['Item_No'];
    Qty_Received = json['Qty_Received'];
    Receipt_Date = json['Receipt_Date'];
    Transfer_from_Code = json['Transfer_from_Code'];
    Transfer_to_Code = json['Transfer_to_Code'];
  }
}

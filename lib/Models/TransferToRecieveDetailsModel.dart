class ttrModel {
  String? Item_No;
  int? Quantity;
  String? Description;
  int? Qty_to_Receive;
  String? Receipt_Date;

  ttrModel({
    this.Item_No,
    this.Quantity,
    this.Description,
    this.Qty_to_Receive,
    this.Receipt_Date,
  });

  ttrModel.fromJson(Map<String, dynamic> json) {
    Item_No = json['Item_No'];
    Quantity = json['Quantity'];
    Description = json['Description'];
    Qty_to_Receive = json['Qty_to_Receive'];
    Receipt_Date = json['Receipt_Date'];
  }
}
